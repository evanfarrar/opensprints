EESchema Schematic File Version 2  date Thu 28 May 2009 11:11:14 PM CDT
LIBS:power,./symbols/custom_symbols,device,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,contrib,valves
EELAYER 23  0
EELAYER END
$Descr User 11000 8500
Sheet 1 1
Title "roller sensor progress indicator"
Date "29 may 2009"
Rev "3.0"
Comp "www.opensprints.org"
Comment1 "OpenSprints"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L C-6_CIRCUIT_BOARD CB1
U 1 1 4A1F5D68
P 4100 4700
F 0 "CB1" H 4100 4700 60  0000 C CNN
F 1 "C-6_CIRCUIT_BOARD" H 4100 4800 60  0000 C CNN
	1    4100 4700
	1    0    0    -1  
$EndComp
Wire Wire Line
	5300 1250 3450 1250
Connection ~ 5300 1750
Connection ~ 4650 3300
Connection ~ 4650 2900
Connection ~ 4650 1250
Connection ~ 4650 1750
Connection ~ 4650 2150
Connection ~ 4650 2400
Wire Wire Line
	6150 1600 6550 1600
Wire Wire Line
	4650 2150 4650 2400
Wire Wire Line
	2600 1300 1800 1300
Wire Wire Line
	6150 3450 6550 3450
Wire Wire Line
	6150 3150 6550 3150
Wire Wire Line
	6550 4150 6150 4150
Wire Wire Line
	2150 4100 1800 4100
Wire Wire Line
	2150 3900 1800 3900
Wire Wire Line
	2150 3700 1800 3700
Wire Wire Line
	2150 3500 1800 3500
Wire Wire Line
	2150 3400 1800 3400
Wire Wire Line
	2150 3600 1800 3600
Wire Wire Line
	2150 3800 1800 3800
Wire Wire Line
	2150 4000 1800 4000
Wire Wire Line
	3450 3300 4650 3300
Wire Wire Line
	6150 4300 6550 4300
Wire Wire Line
	6150 2600 6550 2600
Wire Wire Line
	6550 2300 6150 2300
Wire Wire Line
	6550 2450 6150 2450
Wire Wire Line
	6150 1750 6550 1750
Wire Wire Line
	2150 1900 1800 1900
Wire Wire Line
	2150 1700 1800 1700
Wire Wire Line
	2150 1500 1800 1500
Wire Wire Line
	2150 1400 1800 1400
Wire Wire Line
	2150 1600 1800 1600
Wire Wire Line
	2150 1800 1800 1800
Wire Wire Line
	6150 4000 6550 4000
Wire Notes Line
	7400 4700 7400 1050
Wire Wire Line
	6150 3300 6550 3300
Wire Wire Line
	2350 1200 1800 1200
Wire Wire Line
	6150 1450 6550 1450
Wire Wire Line
	2150 3000 1800 3000
Wire Wire Line
	2150 2800 1800 2800
Wire Wire Line
	2150 2600 1800 2600
Wire Wire Line
	2150 2400 1800 2400
Wire Wire Line
	2150 2300 1800 2300
Wire Wire Line
	2150 2500 1800 2500
Wire Wire Line
	2150 2700 1800 2700
Wire Wire Line
	2150 2900 1800 2900
Wire Notes Line
	7400 4700 5950 4700
Wire Notes Line
	5950 4700 5950 1050
Wire Notes Line
	5950 1050 7400 1050
Wire Wire Line
	4650 2400 3450 2400
Wire Wire Line
	3450 3700 5300 3700
Wire Wire Line
	5300 3700 5300 2150
Text Label 3450 3700 0    60   ~ 0
VOUT
$Comp
L R R8
U 1 1 49E3884E
P 5300 1500
F 0 "R8" V 5380 1500 50  0000 C CNN
F 1 "68" V 5300 1500 50  0000 C CNN
	1    5300 1500
	1    0    0    -1  
$EndComp
$Comp
L LED D7
U 1 1 49E3884B
P 5300 1950
F 0 "D7" H 5300 2050 50  0000 C CNN
F 1 "WHT LED" H 5300 1850 50  0000 C CNN
	1    5300 1950
	0    1    1    0   
$EndComp
Text Notes 5950 5000 0    60   ~ 0
hall effect sensor.
Text Label 2150 3000 0    60   ~ 0
LED3
Text Label 2150 2900 0    60   ~ 0
LED2
Text Label 2150 2800 0    60   ~ 0
LED1
Text Label 2150 2700 0    60   ~ 0
LED0
Text Label 2150 2600 0    60   ~ 0
START/STOP
Text Label 2150 2500 0    60   ~ 0
VOUT
Text Label 2150 2400 0    60   ~ 0
GND
Text Label 2150 2300 0    60   ~ 0
VCC
$Comp
L CONN_8 P1
U 1 1 49E1EB87
P 1450 2650
F 0 "P1" V 1400 2650 60  0000 C CNN
F 1 "CONN_8" V 1500 2650 60  0000 C CNN
	1    1450 2650
	-1   0    0    -1  
$EndComp
Text Label 3450 1250 0    60   ~ 0
VCC
$Comp
L PWR_FLAG #FLG01
U 1 1 49E13269
P 2350 1200
F 0 "#FLG01" H 2350 1470 30  0001 C CNN
F 1 "PWR_FLAG" H 2350 1430 30  0000 C CNN
	1    2350 1200
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG02
U 1 1 49E13266
P 2600 1300
F 0 "#FLG02" H 2600 1570 30  0001 C CNN
F 1 "PWR_FLAG" H 2600 1530 30  0000 C CNN
	1    2600 1300
	1    0    0    -1  
$EndComp
Text Notes 5950 4850 0    60   ~ 0
Install only one
Text Label 6150 3450 0    60   ~ 0
VOUT
Text Label 6150 3300 0    60   ~ 0
GND
Text Label 6150 3150 0    60   ~ 0
VCC
$Comp
L SS441A U3
U 1 1 49DFC7F9
P 6750 2900
F 0 "U3" H 6750 2900 60  0000 C CNN
F 1 "SS441A" H 6900 2800 60  0000 C CNN
	1    6750 2900
	1    0    0    -1  
$EndComp
Text Label 2150 4100 0    60   ~ 0
LED3
Text Label 2150 4000 0    60   ~ 0
LED2
Text Label 2150 3900 0    60   ~ 0
LED1
Text Label 2150 3800 0    60   ~ 0
LED0
Text Label 2150 3700 0    60   ~ 0
START/STOP
Text Label 2150 3600 0    60   ~ 0
VOUT
Text Label 2150 3500 0    60   ~ 0
GND
Text Label 2150 3400 0    60   ~ 0
VCC
$Comp
L RJ45 J2
U 1 1 49DF9008
P 1350 3750
F 0 "J2" H 1550 4250 60  0000 C CNN
F 1 "RJ45" H 1200 4250 60  0000 C CNN
	1    1350 3750
	0    -1   1    0   
$EndComp
$Comp
L R R2
U 1 1 49DF8AA5
P 4650 1500
F 0 "R2" V 4730 1500 50  0000 C CNN
F 1 "150" V 4650 1500 50  0000 C CNN
	1    4650 1500
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 49DF899F
P 4650 2650
F 0 "R3" V 4730 2650 50  0000 C CNN
F 1 "68" V 4650 2650 50  0000 C CNN
	1    4650 2650
	1    0    0    -1  
$EndComp
Text Label 3450 3300 0    60   ~ 0
GND
Text Label 6150 4300 0    60   ~ 0
VOUT
Text Label 6150 4150 0    60   ~ 0
GND
Text Label 6150 4000 0    60   ~ 0
VCC
$Comp
L SS441A U4
U 1 1 49C83B82
P 6750 3750
F 0 "U4" H 6750 3750 60  0000 C CNN
F 1 "SS441A" H 6900 3650 60  0000 C CNN
	1    6750 3750
	1    0    0    -1  
$EndComp
Text Label 6150 2600 0    60   ~ 0
VOUT
Text Label 6150 2450 0    60   ~ 0
GND
Text Label 6150 2300 0    60   ~ 0
VCC
$Comp
L SS441A U2
U 1 1 49C83B66
P 6750 2050
F 0 "U2" H 6750 2050 60  0000 C CNN
F 1 "SS441A" H 6900 1950 60  0000 C CNN
	1    6750 2050
	1    0    0    -1  
$EndComp
Text Label 6150 1750 0    60   ~ 0
VOUT
Text Label 6150 1600 0    60   ~ 0
GND
Text Label 6150 1450 0    60   ~ 0
VCC
Text Label 3450 2400 0    60   ~ 0
START/STOP
$Comp
L LED D1
U 1 1 49C835C2
P 4650 1950
F 0 "D1" H 4650 2050 50  0000 C CNN
F 1 "RED LED" H 4650 1850 50  0000 C CNN
	1    4650 1950
	0    1    1    0   
$EndComp
$Comp
L LED D2
U 1 1 49C834FE
P 4650 3100
F 0 "D2" H 4650 3200 50  0000 C CNN
F 1 "GRN LED" H 4650 3000 50  0000 C CNN
	1    4650 3100
	0    1    1    0   
$EndComp
Text Label 2150 1900 0    60   ~ 0
LED3
Text Label 2150 1800 0    60   ~ 0
LED2
Text Label 2150 1700 0    60   ~ 0
LED1
Text Label 2150 1600 0    60   ~ 0
LED0
Text Label 2150 1500 0    60   ~ 0
START/STOP
Text Label 2150 1400 0    60   ~ 0
VOUT
Text Label 2150 1300 0    60   ~ 0
GND
Text Label 2150 1200 0    60   ~ 0
VCC
$Comp
L RJ45 J1
U 1 1 49C834DF
P 1350 1550
F 0 "J1" H 1550 2050 60  0000 C CNN
F 1 "RJ45" H 1200 2050 60  0000 C CNN
	1    1350 1550
	0    -1   1    0   
$EndComp
$Comp
L SS441A U1
U 1 1 49C59A51
P 6750 1200
F 0 "U1" H 6750 1200 60  0000 C CNN
F 1 "SS441A" H 6900 1100 60  0000 C CNN
	1    6750 1200
	1    0    0    -1  
$EndComp
$EndSCHEMATC
