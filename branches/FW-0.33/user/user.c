/*********************************************************************
 *
 *                Microchip USB C18 Firmware Version 1.0
 *
 *********************************************************************
 * FileName:        user.c
 * Dependencies:    See INCLUDES section below
 * Processor:       PIC18
 * Compiler:        C18 2.30.01+
 * Company:         Microchip Technology, Inc.
 *
 * Software License Agreement
 *
 * The software supplied herewith by Microchip Technology Incorporated
 * (the “Company”) for its PICmicro® Microcontroller is intended and
 * supplied to you, the Company’s customer, for use solely and
 * exclusively on Microchip PICmicro Microcontroller products. The
 * software is owned by the Company and/or its supplier, and is
 * protected under applicable copyright laws. All rights are reserved.
 * Any use in violation of the foregoing restrictions may subject the
 * user to criminal sanctions under applicable laws, as well as to
 * civil liability for the breach of the terms and conditions of this
 * license.
 *
 * THIS SOFTWARE IS PROVIDED IN AN “AS IS” CONDITION. NO WARRANTIES,
 * WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
 * TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
 * IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
 * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 *
 * Author               Date		Comment
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Rawin Rojvanit       11/19/04	Original.
 * Brian Schmalz	03/15/06	Added user code to implement
 *									firmware version D v1.0 for UBW
 *									project. See www.greta.dhs.org/UBW
 * Brian Schmalz	05/04/06	Starting version 1.1, which will 
 * 									include several fixes. See website.
 * BPS					06/21/06	Starting v1.2 -
 * - Fixed problem with I packets (from T command) filling up TX buffer
 * 		and not letting any incoming commands be received. (strange)
 * - Adding several commands - Analog inputs being the biggest set.
 * - Also Byte read/Byte write (PEEK/POKE) anywhere in memory
 * - Individual pin I/O and direction
 * BPS			08/16/06	v1.3 - Fixed bug with USB startup
 * BPS			09/09/06	v1.4 - Starting 1.4
 * - Fixed Microchip bug with early silicon - UCONbits.PKTDIS = 0;
 * - Adding BO and BC commands for parallel output to graphics pannels
 * BPS			12/06/06	v1.4 - More work on 1.4
 * - Re-wrote all I/O buffering code for increased speed and functionality
 * - Re-wrote error handling code
 * - Added delays to BC/BO commands to help Corey
 * BPS			01/06/07	v1.4 - Added RC command for servos
 * BPS			03/07/07	v1.4.1 - Changed blink rate for SFE
 * BPS			05/24/07	v1.4.2 - Fixed RC command bug - it
 *									wouldn't shut off.
 * Luke Orland		2007/08/28	added some stuff
 * LJO			2007/09/29	v0.32 - added race test mode and timeclock
 * LJO			2008/03/31	v0.33 - cheese sandwich day! removed lots of UBW stuff,
 * 					      - added support for up to 8 rollers,
 * 					      - changed the timestamp output format.
 * 
 * To Do:
 *  - switch to milliseconds instead of centiseconds
 *  - incorporate new changes
 *    * stop after finish_tick is reached
 *    * activate specified rollers
 *    * new messages to PC sw
 *    * change timestamps to 1000ths of a second
 *  - test and debug
 *  - ECHO mode
 *  - FW sends confirmation message back to SW when receives a command.
 *  - interrupt on state change of pins
 *
 * Scratch list:
 *  - handshaking
 *    * if PC doesn't get the message in the precise format, asks for a resend
 *  - parse_RS_packet // resend
 *  - switch to sending serial data instead of ascii chars. (yaml?)
	* DONE: ISR
	* DONE: check in ProcessIO() {?} if it is time to send update
	* DONE: send update to pc
	* DONE: init pins for input on REGB
	* DONE: HW and GO commands
 *
 *************************************************************************/

/** I N C L U D E S ******************************************************/
#include <p18cxxx.h>
#include <usart.h>
#include <stdio.h>
#include <ctype.h>
#include <delays.h>
#include "system\typedefs.h"
#include "system\usb\usb.h"
#include "io_cfg.h"             // I/O pin mapping
#include "user\user.h"

/** D E F I N E S ********************************************************/
#define bitset(var,bitno) ((var) |= (1 << (bitno)))
#define bitclr(var,bitno) ((var) &= ~(1 << (bitno)))
#define bittst(var,bitno) (var& (1 << (bitno)))

// For the RC command, we define a little data structure that holds the 
// values assoicated with a particular servo connection
// It's port, pin, value (position) and state (INACTIVE, PRIMED or TIMING)
// Later on we make an array of these (19 elements long - 19 pins) to track
// the values of all of the servos.
typedef enum {
	 kOFF = 1
	,kWAITING
	,kPRIMED
	,kTIMING
} tRC_state;

#define kRC_DATA_SIZE		24		// In structs, since there are 3 ports of 8 bits each

#define kTX_BUF_SIZE 		64		// In bytes
#define kRX_BUF_SIZE		64		// In bytes

#define kUSART_TX_BUF_SIZE	64		// In bytes
#define kUSART_RX_BUF_SIZE	64		// In bytes

// Enum for extract_num() function parameter
typedef enum {
	 kCHAR
	,kUCHAR
	,kINT
	,kUINT
	,kASCII_CHAR
	,kUCASE_ASCII_CHAR
} tExtractType;

#define advance_RX_buf_out()			\
{ 						\
	g_RX_buf_out++;				\
	if (kRX_BUF_SIZE == g_RX_buf_out)	\
	{					\
		g_RX_buf_out = 0;		\
	}					\
}

#define kISR_FIFO_A_DEPTH			3
#define kISR_FIFO_D_DEPTH			3
#define kPR2_RELOAD				250		// For 1ms TMR2 tick
#define kCR					0x0D
#define kLF					0x0A

// defines for the error_byte byte - each bit has a meaning
#define kERROR_BYTE_TX_BUF_OVERRUN		2
#define kERROR_BYTE_RX_BUFFER_OVERRUN		3
#define kERROR_BYTE_MISSING_PARAMETER		4
#define kERROR_BYTE_PRINTED_ERROR		5		// We've already printed out an error
#define kERROR_BYTE_PARAMETER_OUTSIDE_LIMIT	6
#define kERROR_BYTE_EXTRA_CHARACTERS 		7
#define kERROR_BYTE_UNKNOWN_COMMAND		8		// Part of command parser, not error handler

/** V A R I A B L E S ********************************************************/
#pragma udata access fast_vars

// Rate variable - how fast does interrupt fire to capture inputs?
near unsigned int time_between_updates;

near volatile unsigned int ISR_D_RepeatRate;			// How many 1ms ticks between Digital updates
near volatile unsigned char ISR_D_FIFO_in;			// In pointer
near volatile unsigned char ISR_D_FIFO_out;			// Out pointer
near volatile unsigned char ISR_D_FIFO_length;			// Current FIFO depth

near volatile unsigned int ISR_A_RepeatRate;			// How many 1ms ticks between Analog updates
near volatile unsigned char ISR_A_FIFO_in;			// In pointer
near volatile unsigned char ISR_A_FIFO_out;			// Out pointer
near volatile unsigned char ISR_A_FIFO_length;			// Current FIFO depth
near volatile unsigned char AnalogEnable;			// Maximum ADC channel to convert

// This byte has each of its bits used as a seperate error flag
near unsigned char error_byte;

// RC servo variables
// First the main array of data for each servo
near unsigned char g_RC_primed_ptr;
near unsigned char g_RC_next_ptr;
near unsigned char g_RC_timing_ptr;

// Used only in LowISR
near unsigned int D_tick_counter;
near unsigned int A_tick_counter;
near unsigned char A_cur_channel;

// ROM strings
const rom char st_OK[] = {"OK\r\n"};
const rom char st_LFCR[] = {"\r\n"};
const rom char st_version[] = {"opensprints FW 0.33 based on UBW FW D Version 1.4.2\r\n"};

#pragma udata ISR_buf=0x100
volatile unsigned int ISR_A_FIFO[12][kISR_FIFO_A_DEPTH];	// Stores the most recent analog conversions
volatile unsigned char ISR_D_FIFO[3][kISR_FIFO_D_DEPTH];	// FIFO of actual data
volatile tRC_state g_RC_state[kRC_DATA_SIZE];			// Stores states for each pin for RC command
volatile unsigned int g_RC_value[kRC_DATA_SIZE];		// Stores reload values for TMR0

#pragma udata com_buf=0x200
// USB Transmit buffer for packets (back to PC)
unsigned char g_TX_buf[kTX_BUF_SIZE];
// USB Receiving buffer for commands as they come from PC
unsigned char g_RX_buf[kRX_BUF_SIZE];

// USART Receiving buffer for data coming from the USART
unsigned char g_USART_RX_buf[kUSART_RX_BUF_SIZE];

// USART Transmit buffer for data going to the USART
unsigned char g_USART_TX_buf[kUSART_TX_BUF_SIZE];

// These variables are in normal storage space
#pragma udata

// These are used for the Fast Parallel Output routines
unsigned char g_BO_init;
unsigned char g_BO_strobe_mask;
unsigned char g_BO_wait_mask;
unsigned char g_BO_wait_delay;
unsigned char g_BO_strobe_delay;

// Pointers to USB transmit (back to PC) buffer
unsigned char g_TX_buf_in;
unsigned char g_TX_buf_out;

// Pointers to USB receive (from PC) buffer
unsigned char g_RX_buf_in;
unsigned char g_RX_buf_out;

// In and out pointers to our USART input buffer
unsigned char g_USART_RX_buf_in;
unsigned char g_USART_RX_buf_out;

// In and out pointers to our USART output buffer
unsigned char g_USART_TX_buf_in;
unsigned char g_USART_TX_buf_out;

// Normally set to TRUE. Able to set FALSE to not send "OK" message after packet recepetion
BOOL	g_ack_enable;

/** P R I V A T E  P R O T O T Y P E S ***************************************/
void BlinkUSBStatus (void);		// Handles blinking the USB status LED
BOOL SwitchIsPressed (void);		// Check to see if the user (PRG) switch is pressed
void parse_packet (void);		// Take a full packet and dispatch it to the right function
signed short long extract_number (tExtractType type); 		// Pull a number paramter out of the packet
signed char extract_digit (signed short long * acc, unsigned char digits); // Pull a character out of the packet
void parse_V_packet (void);	// V for printing version

void parse_GO_packet (void);	// start sending sensor messages to PC
void parse_ST_packet (void);	// stop sending sensor messages to PC
void parse_HW_packet (void);	// test mode. periodic sensor messages to PC

void check_and_send_TX_data (void); // See if there is any data to send to PC, and if so, do it
void print_ack (void);		// Print "OK" after packet is parsed
int _user_putc (char c);	// Our UBS based stream character printer

// sensor stuff
#define	NUM_ROLLERS		8
unsigned int finishTick;		// this value determines the length of the race in roller rotations
unsigned char activeRollers;		// 8 flags: Are the rollers active?
unsigned int refreshInterval = 66;	// default value is 15 frames per second

unsigned char prevSensorStates;		// 8 flags: Was the hall effect sensor engaged?
unsigned char currentSensorStates;	// 8 flags: Is the hall effect sensor engaged?
unsigned short long raceTime;				// in ms
unsigned short long rollerTickTimes[NUM_ROLLERS];	// in ms
unsigned int rollerTicks[NUM_ROLLERS];		// number of revolutions of each roller 

BOOL isRacing = FALSE;
BOOL raceTestMode = FALSE;
BOOL newTick = FALSE;
BOOL justBegun = TRUE;

/** D E C L A R A T I O N S **************************************************/

/** Start OpenSprints FW code ************************************************/

void SendUpdateToPc (void)
{
	char roller;

	printf((rom char *)"time: %i\n",raceTime);

	// Only print out the tick times and number of ticks for the active rollers
	for (roller=0; roller < NUM_ROLLERS && activeRollers&(1<<roller); roller++)
	{
		if(raceTestMode)
		{
			printf((rom char *)"%i:\n  last_tick_time: %i\n",roller,raceTime,raceTime/refreshInterval);
		}
		else
		{
			printf((rom char *)"%i:\n  last_tick_time: %i\n",roller,rollerTickTimes[roller],rollerTicks[roller]);
		}
	}
	printf((rom char *)"eom.\n");

}

#pragma code

#pragma interruptlow low_ISR
void low_ISR(void)
{	
}


#pragma interrupt high_ISR
void high_ISR(void)
{
	char roller;

	// Do we have a Timer2 interrupt? (1ms rate)
	if (PIR1bits.TMR2IF)
	{
		// Clear the interrupt 
		PIR1bits.TMR2IF = 0;
		if (isRacing)
		{
			raceTime++;		// add another ms to the time counter
			prevSensorStates = currentSensorStates;		// remember previous state of pins
			currentSensorStates = PORTB;			// read the pins

			for(roller=0;roller<NUM_ROLLERS;roller++)
			{
				unsigned char rollerMask;
				rollerMask = (1<<roller);
				if(rollerMask & activeRollers & (currentSensorStates^prevSensorStates) & currentSensorStates)
				// Check each active roller for a change from 0 to 1
				{
					// If so, increase the tick count for that roller and save the time
					rollerTicks[roller]++;
					rollerTickTimes[roller] = raceTime;
				}
			}
		}
	}
}

void UserInit(void)
{
	char i, j;

	// Make all of 3 digital inputs
	LATA = 0x00;
	TRISA = 0xFF;
	// Turn all analog inputs into digital inputs
	ADCON1 = 0x0F;
	// Turn off the ADC
	ADCON0bits.ADON = 0;
	// Turn off our own idea of how many analog channels to convert
	AnalogEnable = 0;
	CMCON = 0x07;	// Comparators as digital inputs
	// Make all of PORTB inputs
	LATB = 0x00;
	TRISB = 0xFF;
	// Make all of PORTC inputs
	LATC = 0x00;
	TRISC = 0xFF;
#ifdef __18F4550
	// Make all of PORTD and PORTE inputs too
	LATD = 0x00;
	TRISD = 0xFF;
	LATE = 0x00;
	TRISE = 0xFF;
#endif

	// Initalize LED I/Os to outputs
	mInitAllLEDs();
	// Initalize switch as an input
	mInitSwitch();

	// Start off always using "OK" acknowledge.
	g_ack_enable = TRUE;

	// Use our own special output function for STDOUT
	stdout = _H_USER;

	// Initalize all of the ISR FIFOs
	ISR_A_FIFO_out = 0;
	ISR_A_FIFO_in = 0;
	ISR_A_FIFO_length = 0;
	ISR_D_FIFO_out = 0;
	ISR_D_FIFO_in = 0;
	ISR_D_FIFO_length = 0;

	// Make sure that our timer stuff starts out disabled
	ISR_D_RepeatRate = 0;
	ISR_A_RepeatRate = 0;
	D_tick_counter = 0;
	A_tick_counter = 0;
	A_cur_channel = 0;
	
	// Now init our registers
	// The prescaler will be at 16
	T2CONbits.T2CKPS1 = 1;
	T2CONbits.T2CKPS0 = 1;
	// We want the TMR2 post scaler to be a 3
	T2CONbits.T2OUTPS3 = 0;
	T2CONbits.T2OUTPS2 = 0;
	T2CONbits.T2OUTPS1 = 1;
	T2CONbits.T2OUTPS0 = 0;
	// Set our reload value
	PR2 = kPR2_RELOAD;

	// Inialize USB TX and RX buffer management
	g_RX_buf_in = 0;
	g_RX_buf_out = 0;
	g_TX_buf_in = 0;
	g_TX_buf_out = 0;

	// And the USART TX and RX buffer management
	g_USART_RX_buf_in = 0;
	g_USART_RX_buf_out = 0;
	g_USART_TX_buf_in = 0;
	g_USART_TX_buf_out = 0;

	// Clear out the RC servo output pointer values
	g_RC_primed_ptr = 0;
	g_RC_next_ptr = 0;
	g_RC_timing_ptr = 0;

	// Clear the RC data structure
	for (i = 0; i < kRC_DATA_SIZE; i++)
	{
		g_RC_value[i] = 0;
		g_RC_state[i] = kOFF;
	}

	// Enable TMR0 for our OpenSprints timing operation
	T0CONbits.PSA = 1;	// Do NOT use the prescaler
	T0CONbits.T0CS = 0;	// Use internal clock
	T0CONbits.T08BIT = 0;	// 16 bit timer
	INTCONbits.TMR0IF = 0;	// Clear the interrupt flag
	INTCONbits.TMR0IE = 0;	// And clear the interrupt enable
	INTCON2bits.TMR0IP = 0;	// Low priority

	// Enable interrupt priorities
	RCONbits.IPEN = 1;
	T2CONbits.TMR2ON = 0;
    
	PIE1bits.TMR2IE = 1;
	IPR1bits.TMR2IP = 0;
    
	INTCONbits.GIEH = 1;	// Turn high priority interrupts on
	INTCONbits.GIEL = 1;	// Turn low priority interrupts on

	// Turn on the Timer2
	//T2CONbits.TMR2ON = 1;    

}//end UserInit

/******************************************************************************
 * Function:        void ProcessIO(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        In this function, we check for a new packet that just
 * 					arrived via USB. We do a few checks on the packet to see
 *					if it is worthy of us trying to interpret it. If it is,
 *					we go and call the proper function based upon the first
 *					character of the packet.
 *					NOTE: We need to see everything in one packet (i.e. we
 *					won't treat the USB data as a stream and try to find our
 *					start and end of packets within the stream. We just look 
 *					at the first character of each packet for a command and
 * 					check that there's a CR as the last character of the
 *					packet.
 *
 * Note:            None
 *****************************************************************************/
void ProcessIO(void)
{   
	static BOOL in_cr = FALSE;
	static byte last_fifo_size;
	unsigned char tst_char;
	BOOL	got_full_packet = FALSE;
	cdc_rx_len = 0;

	BlinkUSBStatus();

	if(raceTime%refreshInterval == 0)
	{
		SendUpdateToPc();
	}

	// User Application USB tasks
	if((usb_device_state < CONFIGURED_STATE) || (UCONbits.SUSPND == 1))
	{	
		return;
	}

	// Check for any new I packets (from T command) ready to go out
	while (ISR_D_FIFO_length > 0)
	{
		// Spit out an I packet first
//		parse_I_packet ();					// Temp commmented out by Luke

		// Then upate our I packet fifo stuff
		ISR_D_FIFO_out++;
		if (ISR_D_FIFO_out == kISR_FIFO_D_DEPTH)
		{
			ISR_D_FIFO_out = 0;
		}
		ISR_D_FIFO_length--;
	}			

	// Check for a new A packet (from T command) ready to go out
	while (ISR_A_FIFO_length > 0)
	{
		// Spit out an A packet first
//		parse_A_packet ();					// Temp commmented out by Luke

		// Then update our A packet fifo stuff
		ISR_A_FIFO_out++;
		if (ISR_A_FIFO_out == kISR_FIFO_A_DEPTH)
		{
			ISR_A_FIFO_out = 0;
		}
		ISR_A_FIFO_length--;
	}			

	// Pull in some new data if there is new data to pull in
	if(!mCDCUsartRxIsBusy())
	{
		// Copy data from dual-ram buffer to user's buffer
		for(cdc_rx_len = 0; cdc_rx_len < CDC_BULK_BD_OUT.Cnt; cdc_rx_len++)
		{
			// Check to see if we are in a CR/LF situation
			tst_char = cdc_data_rx[cdc_rx_len];
			if (
				!in_cr 
				&& 
				(
					kCR == tst_char
					||
					kLF == tst_char
				)
			)
			{
				in_cr = TRUE;
				g_RX_buf[g_RX_buf_in] = kCR;
				g_RX_buf_in++;
			
				// At this point, we know we have a full packet
				// of information from the PC to parse
				got_full_packet = TRUE;
			}
			else if (
				tst_char != kCR
				&&
				tst_char != kLF
			)
			{
				// Only add a byte if it is not a CR or LF
				g_RX_buf[g_RX_buf_in] = tst_char;
				in_cr = FALSE;
				g_RX_buf_in++;
			}
			else
			{
				continue;
			}
			// Check for buffer wraparound
			if (kRX_BUF_SIZE == g_RX_buf_in)
			{
				g_RX_buf_in = 0;
			}
			// If we hit the out pointer, then this is bad.
			if (g_RX_buf_in == g_RX_buf_out)
			{
				bitset (error_byte, kERROR_BYTE_RX_BUFFER_OVERRUN);
				break;
			}
			// Now, if we've gotten a full command (user send <CR>) then
			// go call the code that deals with that command, and then
			// keep parsing. (This allows multiple small commands per packet)
			if (got_full_packet)
			{
				parse_packet ();
				got_full_packet = FALSE;
			}
		}		

		// Prepare dual-ram buffer for next OUT transaction
		CDC_BULK_BD_OUT.Cnt = sizeof(cdc_data_rx);
		mUSBBufferReady(CDC_BULK_BD_OUT);
	}

	// Check for any errors logged in error_byte that need to be sent out
	if (error_byte)
	{
		if (bittst (error_byte, 0))
		{
			// Unused as of yet
			printf ((rom char *)"!0 \r\n");
		}
		if (bittst (error_byte, 1))
		{
			// Unused as of yet
			printf ((rom char *)"!1 \r\n");
		}
		if (bittst (error_byte, kERROR_BYTE_TX_BUF_OVERRUN))
		{
			printf ((rom char *)"!2 Err: TX Buffer overrun\r\n");
		}
		if (bittst (error_byte, kERROR_BYTE_RX_BUFFER_OVERRUN))
		{
			printf ((rom char *)"!3 Err: RX Buffer overrun\r\n");
		}
		if (bittst (error_byte, kERROR_BYTE_MISSING_PARAMETER))
		{
			printf ((rom char *)"!4 Err: Missing parameter(s)\r\n");
		}
		if (bittst (error_byte, kERROR_BYTE_PRINTED_ERROR))
		{
			// We don't need to do anything since something has already been printed out
			//printf ((rom char *)"!5\r\n");
		}
		if (bittst (error_byte, kERROR_BYTE_PARAMETER_OUTSIDE_LIMIT))
		{
			printf ((rom char *)"!6 Err: Invalid paramter value\r\n");
		}
		if (bittst (error_byte, kERROR_BYTE_EXTRA_CHARACTERS))
		{
			printf ((rom char *)"!7 Err: Extra parmater\r\n");
		}
		error_byte = 0;
	}

	// Go send any data that needs sending to PC
	check_and_send_TX_data ();
}

// This is our replacement for the standard putc routine
// This enables printf() and all related functions to print to
// the UBS output (i.e. to the PC) buffer
int _user_putc (char c)
{
	// Copy the character into the output buffer
	g_TX_buf[g_TX_buf_in] = c;
	g_TX_buf_in++;

	// Check for wrap around
	if (kTX_BUF_SIZE == g_TX_buf_in)
	{
		g_TX_buf_in = 0;
	}
	
	// Also check to see if we bumped up against our output pointer
	if (g_TX_buf_in == g_TX_buf_out)
	{
		bitset (error_byte, kERROR_BYTE_TX_BUF_OVERRUN);
	}
	return (c);
}

// In this function, we check to see it is OK to transmit. If so
// we see if there is any data to transmit to PC. If so, we schedule
// it for sending.
void check_and_send_TX_data (void)
{
	char temp;

	// Only send if we're not already sending something
	if (mUSBUSARTIsTxTrfReady ())
	{
		// And only send if there's something there to send
		if (g_TX_buf_out != g_TX_buf_in)
		{
			// Now decide if we need to break it up into two parts or not
			if (g_TX_buf_in > g_TX_buf_out)
			{
				// Since IN is beyond OUT, only need one chunk
				temp = g_TX_buf_in - g_TX_buf_out;
				mUSBUSARTTxRam (&g_TX_buf[g_TX_buf_out], temp);
				// Now that we've scheduled the data for sending,
				// update the pointer
				g_TX_buf_out = g_TX_buf_in;
			}
			else
			{
				// Since IN is before OUT, we need to send from OUT to the end
				// of the buffer, then the next time around we'll catch
				// from the beginning to IN.
				temp = kTX_BUF_SIZE - g_TX_buf_out;
				mUSBUSARTTxRam (&g_TX_buf[g_TX_buf_out], temp);
				// Now that we've scheduled the data for sending,
				// update the pointer
				g_TX_buf_out = 0;
			}
		}
	}
}


// Look at the new packet, see what command it is, and 
// route it appropriately. We come in knowing that
// our packet is in g_RX_buf[], and that the beginning
// of the packet is at g_RX_buf_out, and the end (CR) is at
// g_RX_buf_in. Note that because of buffer wrapping,
// g_RX_buf_in may be less than g_RX_buf_out.
void parse_packet(void)
{
	unsigned int	command = 0;
	unsigned char	cmd1 = 0;
	unsigned char	cmd2 = 0;

	// Always grab the first character (which is the first byte of the command)
	cmd1 = toupper (g_RX_buf[g_RX_buf_out]);
	advance_RX_buf_out();
	command = cmd1;

	// Only grab second one if it is not a comma
	if (g_RX_buf[g_RX_buf_out] != ',' && g_RX_buf[g_RX_buf_out] != kCR)
	{
		cmd2 = toupper (g_RX_buf[g_RX_buf_out]);
		advance_RX_buf_out();
		command = ((unsigned int)(cmd1) << 8) + cmd2;
	}

	// Now 'command' is equal to one or two bytes of our command
	switch (command)
	{
		case 'V':
		{
			// Version command
			parse_V_packet ();
			break;
		}
		case ('G' * 256) + 'O':
		{
			parse_GO_packet ();
			break;
		}
		case ('S' * 256) + 'T':
		{
			parse_ST_packet ();
			break;
		}
		case ('H' * 256) + 'W':
		{
			parse_HW_packet();
			break;
		}
		default:
		{
			if (0 == cmd2)
			{
				// Send back 'unknown command' error
				printf (
					 (rom char *)"!8 Err: Unknown command '%c:%2X'\r\n"
					,cmd1
					,cmd1
				);
			}
			else
			{
				// Send back 'unknown command' error
				printf (
					 (rom char *)"!8 Err: Unknown command '%c%c:%2X%2X'\r\n"
					,cmd1
					,cmd2
					,cmd1
					,cmd2
				);
			}
			break;
		}
	}

	// Double check that our output pointer is now at the ending <CR>
	// If it is not, this indicates that there were extra characters that
	// the command parsing routine didn't eat. This would be an error and needs
	// to be reported. (Ignore for Reset command because FIFO pointers get cleared.)
	if (
		(g_RX_buf[g_RX_buf_out] != kCR && 0 == error_byte)
		&&
		('R' != command)
	)
	{
		bitset (error_byte, kERROR_BYTE_EXTRA_CHARACTERS);
	}

	// Clean up by skipping over any bytes we haven't eaten
	// This is safe since we parse each packet as we get a <CR>
	// (i.e. g_RX_buf_in doesn't move while we are in this routine)
	g_RX_buf_out = g_RX_buf_in;
}

// Print out the positive acknowledgement that the packet was received
// if we have acks turned on.
void print_ack(void)
{
	if (g_ack_enable)
	{
		printf ((rom char *)st_OK);
	}
}

// All we do here is just print out our version number
void parse_V_packet(void)
{
	printf ((rom char *)st_version);
}

void startRace (void)
{			
	DDRB = 0xff;			// initialize the pins
	
	isRacing = TRUE;		// make it possible to start monitoring sensors
	raceTime=0;		// restart the stopwatch
	T2CONbits.TMR2ON=1;		// turn on the timer
	ISR_D_RepeatRate = 1;		// every 10ms advance the timer
}

void parse_GO_packet (void)		// Start a race
{
	//print_ack();
	startRace();
	// Extract values of each argument.
	//finish_tick = extract_number (kUCHAR);
	activeRollers = extract_number (kUCHAR);
	refreshInterval = extract_number (kUCHAR);
	
	// Bail if we got a conversion error
	if (error_byte)
	{
		return;
	}
}	

void parse_ST_packet (void)			// Stop the race.
{
	print_ack();
	isRacing = FALSE;			// stop monitoring sensors
	raceTestMode = FALSE;
}	

void parse_HW_packet (void)			// Initiate hardware test mode.
{
	print_ack();
	raceTestMode = TRUE;
	startRace();

	// Extract values of each argument.
	//finish_tick = extract_number (kUCHAR);
	activeRollers = extract_number (kUCHAR);
	refreshInterval = extract_number (kUCHAR);
	
	// Bail if we got a conversion error
	if (error_byte)
	{
		return;
	}
}	

// Look at the string pointed to by ptr
// There should be a comma where ptr points to upon entry.
// If not, throw a comma error.
// If so, then look for up to three bytes after the
// comma for numbers, and put them all into one
// byte (0-255). If the number is greater than 255, then
// throw a range error.
// Advance the pointer to the byte after the last number
// and return.
signed short long extract_number(tExtractType type)
{
	signed short long acc;
	unsigned char neg = FALSE;

	// Check to see if we're already at the end
	if (kCR == g_RX_buf[g_RX_buf_out])
	{
		bitset (error_byte, kERROR_BYTE_MISSING_PARAMETER);
		return (0);
	}

	// Check for comma where ptr points
	if (g_RX_buf[g_RX_buf_out] != ',')
	{
		printf ((rom char *)"!5 Err: Need comma next, found: '%c'\r\n", g_RX_buf[g_RX_buf_out]);
		bitset (error_byte, kERROR_BYTE_PRINTED_ERROR);
		return (0);
	}

	// Move to the next character
	advance_RX_buf_out ();

	// Now check for a sign character if we're not looking for ASCII chars
	if (
		('-' == g_RX_buf[g_RX_buf_out]) 
		&& 
		(
			(kASCII_CHAR != type)
			&&
			(kUCASE_ASCII_CHAR != type)
		)
	)
	{
		// It's an error if we see a negative sign on an unsigned value
		if (
			(kUCHAR == type)
			||
			(kUINT == type)
		)
		{
			bitset (error_byte, kERROR_BYTE_PARAMETER_OUTSIDE_LIMIT);
			return (0);
		}
		else
		{
			neg = TRUE;
			// Move to the next character
			advance_RX_buf_out ();
		}
	}

	// If we need to get a digit, go do that
	if (
		(kASCII_CHAR != type)
		&&
		(kUCASE_ASCII_CHAR != type)
	)
	{
		extract_digit(&acc, 5);
	}
	else
	{
		// Otherwise just copy the byte
		acc = g_RX_buf[g_RX_buf_out];
	
		// Force uppercase if that's what type we have
		if (kUCASE_ASCII_CHAR == type)
		{
			acc = toupper (acc);
		}
		
		// Move to the next character
		advance_RX_buf_out ();
	}

	// Handle the negative sign
	if (neg)
	{
		acc = -acc;
	}

	// Range check the new value
	if (
		(
			kCHAR == type
			&&
			(
				(acc > 127)
				||
				(acc < -128)
			)
		)
		||
		(
			kUCHAR == type
			&&
			(
				(acc > 255)
				||
				(acc < 0)
			)
		)
		||
		(
			kINT == type
			&&
			(
				(acc > 32767)
				||
				(acc < -32768)
			)
		)
		||
		(
			kUINT == type
			&&
			(
				(acc > 65535)
				||
				(acc < 0)
			)
		)
	)
	{
		bitset (error_byte, kERROR_BYTE_PARAMETER_OUTSIDE_LIMIT);
		return (0);
	}

	return(acc);	
}

// Loop 'digits' number of times, looking at the
// byte in input_buffer index *ptr, and if it is
// a digit, adding it to acc. Take care of 
// powers of ten as well. If you hit a non-numerical
// char, then return FALSE, otherwise return TRUE.
// Store result as you go in *acc.
signed char extract_digit(signed short long * acc,	unsigned char digits)
{
	unsigned char val;
	unsigned char digit_cnt;
	
	*acc = 0;

	for (digit_cnt = 0; digit_cnt < digits; digit_cnt++)
	{
		val = g_RX_buf[g_RX_buf_out];
		if ((val >= 48) && (val <= 57))
		{
			*acc = (*acc * 10) + (val - 48);
			// Move to the next character
			advance_RX_buf_out ();
		}
		else
		{
			return (FALSE);
		}
	}
	return (TRUE);
}

// For debugging, this command will spit out a bunch of values.
void print_status(void)
{
	printf( 
		(rom char*)"Status=%i\r\n"
		,ISR_D_FIFO_length
	);
}

/******************************************************************************
 * Function:        void BlinkUSBStatus(void)
 *
 * PreCondition:    None
 *
 * Input:           None
 *
 * Output:          None
 *
 * Side Effects:    None
 *
 * Overview:        BlinkUSBStatus turns on and off LEDs corresponding to
 *                  the USB device state.
 *
 * Note:            mLED macros can be found in io_cfg.h
 *                  usb_device_state is declared in usbmmap.c and is modified
 *                  in usbdrv.c, usbctrltrf.c, and usb9.c
 *****************************************************************************/
void BlinkUSBStatus(void)
{
	static word LEDCount = 0;
	static unsigned char LEDState = 0;
    
    	if (
		usb_device_state == DETACHED_STATE
       	||
       	1 == UCONbits.SUSPND
    	)
    	{
		mLED_1_Off();
    	}
    	else if (
		usb_device_state == ATTACHED_STATE
		||
		usb_device_state == POWERED_STATE		
		||
		usb_device_state == DEFAULT_STATE
		||
		usb_device_state == ADDRESS_STATE
	)
	{
		mLED_1_On();
    	}
	else if (usb_device_state == CONFIGURED_STATE)
    	{
		LEDCount--;
		if (0 == LEDState)
		{
			if (0 == LEDCount)
			{
				mLED_1_On();
				LEDCount = 10000U;				
				LEDState = 1;
			}
		}
		else if (1 == LEDState)
		{
			if (0 == LEDCount)
			{
				mLED_1_Off();
				LEDCount = 10000U;				
				LEDState = 2;
			}
		}
		else if (2 == LEDState)
		{
			if (0 == LEDCount)
			{
				mLED_1_On();
				LEDCount = 100000U;				
				LEDState = 3;
			}
		}
		else if (LEDState >= 3)
		{
			if (0 == LEDCount)
			{
				mLED_1_Off();
				LEDCount = 10000U;				
				LEDState = 0;
			}
		}
    	}
}

BOOL SwitchIsPressed(void)
{
	if( 0 == UserSW)                   	// If pressed
	{
	    return (TRUE);                	// Was pressed
	}
	else
	{
		return (FALSE);			// Was not pressed
	}
}

/** EOF user.c ***************************************************************/
