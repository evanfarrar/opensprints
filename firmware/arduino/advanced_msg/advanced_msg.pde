#undef int
#include <stdio.h>

#define TOGGLE_IO 9 //Arduino pin to toggle in timer ISR, used for debug
#define BUTTON_PIN 6
#define SENSOR_0_PIN 2   //
#define SENSOR_1_PIN 3   //
#define SENSOR_2_PIN 4   //
#define SENSOR_3_PIN 5   //
#define TICK_PACKET_MAX_SIZE 1
#define RACE_PACKET_SIZE 55  // buffer allocation for the race packet
#define RACE_PACKET_UTIL_SIZE 54 // buffer utilization for the race packet (keep this as low as possible to reduce overrun risk)

int statusLEDPin = 13;
long statusBlinkInterval = 250;
int lastStatusLEDValue = LOW;
long lastStatusBlinkMillis = 0;

boolean val0 = true;
boolean val1 = true;
boolean val2 = true;
boolean val3 = true;
boolean buttonPinVal = true;
boolean inputChange = false;

char sensorBuff = 0;

char strDebug[2];
char* p_Debug = strDebug;
char strRacePacket[RACE_PACKET_SIZE];
char* p_RacePacket = strRacePacket;
char strTXRacePacket[RACE_PACKET_SIZE];  // the TX buffer so we can reuse the RacePacket as soon as it fills
char* p_TXRacePacket = strTXRacePacket;

boolean sendRacePacketNow = true;  // Start by sending a blank packet
boolean buttonNow = false;

int lastWinnerLEDValue = LOW;
long lastWinnerBlinkMillis = 0;

boolean raceStarted = false;
boolean raceStarting = false;
boolean mockMode = false;
unsigned long raceStartMillis;
unsigned long currentTimeMillis;
////////////////////////////////////////////////////////


boolean lastSensor0Value = true;
boolean lastSensor1Value = true;
boolean lastSensor2Value = true;
boolean lastSensor3Value = true;
boolean lastButtonValue = true;

boolean racer1TickNow = false;
boolean racer2TickNow = false;
boolean racer3TickNow = false;
boolean racer4TickNow = false;


unsigned long racer1Ticks = 0;
unsigned long racer2Ticks = 0;
unsigned long racer3Ticks = 0;
unsigned long racer4Ticks = 0;

void handleInputChange(){

  inputChange = false;
}



/////////////////////////////////////////////////////////////////////////////////////////////
// MORGAN's new version using CTC -- magic numbers from the datasheet, sorry.
//
//Setup the PCICR  --  PCIE2 for port D
//Configures pin-change interrupt on port D

void SetupPinChangeInterrupts(){

  PCICR = 0b00000100;  // pin change interrupt on port D only (the sensor pins);
  PCMSK2 = 0b00111100; // enable pin interrupts PCINT18..21 (arduino I/O pins 2 3 4 5)

}


void blinkLED() {
  long num = millis();
  if (num - lastStatusBlinkMillis > statusBlinkInterval) {
    lastStatusBlinkMillis = num;

    if (lastStatusLEDValue == LOW)
      lastStatusLEDValue = HIGH;
    else
      lastStatusLEDValue = LOW;

    digitalWrite(statusLEDPin, lastStatusLEDValue);
  }

}

//////////////////////////////////////////////////////////////////////////////////
// checkSerial()
// Handles all command inputs from the PC for lighting, race start, timing, etc
// 'g' :  GO.  Resets racerTicks and should probably reset the clock or at least the Race Time.
// 'm' :  MOCK.  Starts a mock sensor data mode -- need to re-code this to output a reasonable sensor frequency
// 's'  :  STOP MOCK.  Stops the race, and turns off Mock Mode if it's on.
// 'L'  :  LIGHT.  Should be implemented to parse arbitrary light commands (format TBD)
//////////////////////////////////////////////////////////////////////////////////
void checkSerial(){
  char val;
  if(Serial.available()) {
    val = Serial.read();
    if(val == 'g') {
      Serial.println("gACK\n");
      cli();
      raceStartMillis = millis();
      sei();
      racer1Ticks = 0;
      racer2Ticks = 0;
    }
    if(val == 'm') {
      mockMode = true;
    }
    if(val == 's') {

      mockMode = false;
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// the old, busted checkButton routine was a naughty poller -- should use a GPIO Interrupt instead
// this new, hotness one acts on a flag set in the interrupt-on-change for the button.
/////////////////////////////////////////////////////////////////////////////////////////////////
void checkButton(){
  if (buttonNow){
      racer1Ticks = 0;
      racer2Ticks = 0;
  }
  buttonNow = false;
}


void clearTXRacePacket(){
  int i;
  for (i=0; i < RACE_PACKET_SIZE; i++)
  {
    strTXRacePacket[i] = 0;
  }
}


void clearRacePacket(){
  int i;
  for (i=0; i < RACE_PACKET_SIZE; i++)
  {
    strRacePacket[i] = 0;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////
// MORGAN's new version using CTC -- magic numbers from the datasheet, sorry.
//
//Setup Timer2.
//Configures the ATMega168 8-Bit Timer2 to generate an interrupt
//at a frequency of 1 millisecond exactly (to about 1% accuracy)
//No return value.
//See the example usage below.

void SetupTimer2For2Milli(){

  //Timer2 Settings: Timer Prescaler /128, mode 2 = CTC
  //Timer clock = 16MHz/128 = 125kHz or 8us ticks
  //The /128 prescale gives this increment
  //so we just hard code this for now.

  TCCR2A = 0b00000010;  // no output compare, just CTC mode set by WGM22,21,20;
  TCCR2B = 0b00000101;  // prescaler = 128
  OCR2A = 0xFA;  //7D = 125 counts for 1millisecond with /128 prescaler -- 2ms at FA
  TIMSK2 = 0b00000010;  // enable OCR2A compare interrupt (this is our 2ms interrupt), disable OCR2B and overflow
  TCNT2=0;
}

void SetupPinChangeLogic(){
  val0 = digitalRead(SENSOR_0_PIN);
    val1 = digitalRead(SENSOR_1_PIN);
    val2 = digitalRead(SENSOR_2_PIN);
    val3 = digitalRead(SENSOR_3_PIN);
    buttonPinVal = digitalRead(BUTTON_PIN);
    lastSensor0Value = val0;  // now that you've used this value of val#, make sure it's recorded as the standing value...
    lastSensor1Value = val1;
    lastSensor2Value = val2;
    lastSensor3Value = val3;
    lastButtonValue = buttonPinVal;

}

void setup() {
  cli();
  clearRacePacket();
  clearTXRacePacket();
  Serial.begin(115200);
  Serial.println("Setup starting");
  SetupTimer2For2Milli();
  SetupPinChangeInterrupts();
  pinMode(statusLEDPin, OUTPUT);
  pinMode(TOGGLE_IO, OUTPUT);
  pinMode(SENSOR_0_PIN, INPUT);
  pinMode(SENSOR_1_PIN, INPUT);
  pinMode(SENSOR_2_PIN, INPUT);
  pinMode(SENSOR_3_PIN, INPUT);
  pinMode(BUTTON_PIN, INPUT);
  digitalWrite(BUTTON_PIN, HIGH);
  SetupPinChangeLogic();
  Serial.println("Setup Complete, Starting Interrupts");
  sei();
}

// STATUS:  data is now sent raw low nibble but is suffixed with '#'



long time = 0;
char strTime[10];


void loop(void) {
  blinkLED();
  //digitalWrite(TOGGLE_IO,!digitalRead(TOGGLE_IO));
  checkSerial();
  checkButton();
 // if (digitalRead(SENSOR_0_PIN)) Serial.println("$");
  if (inputChange) handleInputChange();
  if (sendRacePacketNow == true){
     strcat(p_RacePacket, "#");
     sendRacePacketNow = false;
     clearTXRacePacket();
     strcpy(p_TXRacePacket, p_RacePacket);  // copy it to the TX buffer
     clearRacePacket(); // and zero the packet
     cli();
     time = millis() - raceStartMillis; // NOTE SPRINTF %u and %i escapes FUCK UP THE TIME -- 16 bit instead of 32 bit
     sei();
     ltoa(time, strTime, 10);
     sprintf(p_RacePacket, "!%s@", strTime);  // then put the time in milliseconds into first position plus the flag character @
//     Serial.println("this is a longer string which has more letters");  // now send the buffered copy
     Serial.println(p_TXRacePacket);  // now send the buffered copy
      //Serial.println(strTime);
  }
  //digitalWrite(TOGGLE_IO,!digitalRead(TOGGLE_IO));
}


/////////////////////////////////////////////////////////////////////////////////////////////
//Timer2 CTC (c)interrupt vector handler
/////////////////////////////////////////////////////////////////////////////////////////////
ISR(TIMER2_COMPA_vect) {
//Toggle the IO pin to the other state.  DEBUG
  digitalWrite(TOGGLE_IO,!digitalRead(TOGGLE_IO));

// Packet format is '!' + time + '@' + hexadecimal representation of tickstate for each 2 milliseconds.
//

    char m = 0;                   // build a nibble containing the tickNow info
    // NOTE on interrupt disable -- if the GPIO interrupt sets a flag between saving the tickNow
    // states in "m", it could be incorrectly cleared by the following section.
    // disable interrupts for this brief period to make sure this does not happen
    // note that we do NOT disable interrupts while performing the potentially 
    // time-consuming sprintf, strcat, and strlen calls
    // The GPIO interrupts should still generally take precedence.
    sei();  
    m |= racer1TickNow;
    m |= racer2TickNow << 1;
    m |= racer3TickNow << 2;
    m |= racer4TickNow << 3;
    racer1TickNow = false;        // reset the TickNow state so we don't duplicate ticks
    racer2TickNow = false;
    racer3TickNow = false;
    racer4TickNow = false;

    m = m + 'a';


    cli();
    
    char n = 0;
    sprintf(&n,"%c", m);        // print the nibble into HEX 0123456789ABCDEF
    strcat(p_RacePacket, &n);     // add it to the buffer -- just send it raw instead?...
    int size = strlen(p_RacePacket);
    if (size > (RACE_PACKET_SIZE - 1))
    {
                //We're out of space and lost data -- should never get here
      Serial.println("Buffer Overrun during GPIO Scan");
    }
    else if (size >= (RACE_PACKET_UTIL_SIZE - TICK_PACKET_MAX_SIZE))
    {
      // Packet is full, so just in case we end up with one more in there,
      // set the flag now to transmit the packet back in the main loop
      sendRacePacketNow = true;
    }
}







/////////////////////////////////////////////////////////////////////////////////////////////
//GPIO on-change interrupt vector handler
/////////////////////////////////////////////////////////////////////////////////////////////
ISR(PCINT2_vect) {
  // We need to disable interrupts here to ensure that subsequent ticks are processed after this round
  // Cannot allow a change in state to screw up the process of checking versus previous states.
    cli();
    
    // Read each of the pins
    // This should really be done in a faster way by reading the port once to minimize ISR execution time
    // but for whatever reason, the last attempt at doing that didn't work.
    // So we'll just use the likely non-optimizing calls from the Arduino library
    val0 = digitalRead(SENSOR_0_PIN);
    val1 = digitalRead(SENSOR_1_PIN);
    val2 = digitalRead(SENSOR_2_PIN);
    val3 = digitalRead(SENSOR_3_PIN);
    buttonPinVal = digitalRead(BUTTON_PIN);

// If the frame check interrupt hasn't yet dealt with a tickNow event, make sure you don't erase that tick
// Since nobody will ever drive the sensor faster than 500Hz (250 actual ticks/second),
// the frame check interrupt will never get multiple ticks on a single sensor.
//
// Previously this code did not check, causing ticks to be erased if another pin changed before the frame check
// interrupt serviced the appropriate tickNow flag

    if (!racer1TickNow) racer1TickNow = ((val0 == false) && (lastSensor0Value == true));
    if (!racer2TickNow) racer2TickNow = ((val1 == false) && (lastSensor1Value == true));
    if (!racer3TickNow) racer3TickNow = ((val2 == false) && (lastSensor2Value == true));
    if (!racer4TickNow) racer4TickNow = ((val3 == false) && (lastSensor3Value == true));
    if (!buttonNow) buttonNow = ((buttonPinVal == false) && (lastButtonValue == true));

    lastSensor0Value = val0;  // now that you've used this value of val#, make sure it's recorded as the standing value...
    lastSensor1Value = val1;
    lastSensor2Value = val2;
    lastSensor3Value = val3;
    lastButtonValue = buttonPinVal;
    
    inputChange = true;
    
    // Reenable interrupts
    sei();
}
