EESchema Schematic File Version 2  date Tue Jul 28 22:35:38 2009
LIBS:power,./symbols/custom_symbols,device,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,contrib,valves
EELAYER 23  0
EELAYER END
$Descr User 11000 8500
Sheet 1 1
Title "roller sensor progress indicator"
Date "29 jul 2009"
Rev "3.0"
Comp "www.opensprints.org"
Comment1 "OpenSprints"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	9550 1450 7200 1450
Wire Wire Line
	7200 1600 9550 1600
Wire Wire Line
	9550 1750 7200 1750
Connection ~ 7750 1750
Connection ~ 8600 1750
Connection ~ 8600 1450
Connection ~ 7750 1450
Wire Notes Line
	7050 1050 7050 4950
Wire Notes Line
	8600 3300 8600 2150
Wire Notes Line
	8600 3300 7150 3300
Wire Notes Line
	7150 3300 7150 2150
Wire Notes Line
	7550 1050 10400 1050
Connection ~ 9450 3450
Wire Wire Line
	9450 1750 9450 4300
Wire Wire Line
	9450 4300 9550 4300
Connection ~ 9250 3150
Wire Wire Line
	9250 3150 9550 3150
Connection ~ 9350 2450
Wire Wire Line
	9350 3300 9550 3300
Connection ~ 9250 1450
Wire Wire Line
	9250 2300 9550 2300
Wire Wire Line
	9350 2450 9550 2450
Wire Notes Line
	3850 2750 3850 1650
Wire Notes Line
	3850 2750 5800 2750
Wire Notes Line
	3850 2600 5800 2600
Wire Notes Line
	3850 2000 5800 2000
Wire Notes Line
	3850 1650 5800 1650
Wire Notes Line
	6300 3300 6200 3300
Wire Notes Line
	6400 3100 6400 3200
Wire Notes Line
	6400 2800 6400 2900
Wire Notes Line
	6400 2500 6400 2600
Wire Notes Line
	6400 2200 6400 2300
Wire Notes Line
	6300 2150 6400 2150
Wire Wire Line
	1800 1300 2900 1300
Wire Wire Line
	1800 1200 3350 1200
Wire Notes Line
	5800 1650 5800 2000
Wire Wire Line
	4950 1250 6800 1250
Connection ~ 6150 1250
Connection ~ 6150 2400
Wire Wire Line
	6150 2150 6150 2400
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
	4950 3300 6150 3300
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
Wire Wire Line
	4950 3700 6800 3700
Wire Wire Line
	6800 3700 6800 2150
Wire Wire Line
	6150 2400 4950 2400
Wire Wire Line
	2900 1300 2900 1600
Wire Wire Line
	2900 1600 3350 1600
Connection ~ 3050 1600
Connection ~ 2550 1200
Wire Notes Line
	6150 2150 6250 2150
Wire Notes Line
	6400 2350 6400 2450
Wire Notes Line
	6400 2650 6400 2750
Wire Notes Line
	6400 2950 6400 3050
Wire Notes Line
	6400 3250 6400 3300
Wire Notes Line
	6400 3300 6350 3300
Wire Notes Line
	5100 2000 5100 2150
Wire Notes Line
	5800 2600 5800 2750
Wire Notes Line
	5100 2150 6100 2150
Wire Wire Line
	9450 2600 9550 2600
Connection ~ 9450 1750
Connection ~ 9350 1600
Connection ~ 9250 2300
Wire Wire Line
	9450 3450 9550 3450
Connection ~ 9450 2600
Wire Wire Line
	9550 4000 9250 4000
Wire Wire Line
	9250 4000 9250 1450
Wire Wire Line
	9550 4150 9350 4150
Wire Wire Line
	9350 4150 9350 1600
Connection ~ 9350 3300
Wire Notes Line
	7150 2150 8600 2150
Wire Notes Line
	10400 1050 10400 4950
Wire Notes Line
	7050 4950 9900 4950
Text Notes 7250 3250 0    60   ~ 0
P5 and P4 to P6.
Text Notes 7250 3150 0    60   ~ 0
Then connect P3 to
Text Notes 7250 2950 0    60   ~ 0
is broken.
Text Notes 7250 2850 0    60   ~ 0
between P4 and P6
Text Notes 7250 2750 0    60   ~ 0
and the connection
Text Notes 7250 2650 0    60   ~ 0
P3 and P5 is broken
Text Notes 7250 2550 0    60   ~ 0
connection between
Text Notes 7250 2450 0    60   ~ 0
backwards if the
Text Notes 7250 2350 0    60   ~ 0
may be installed
Text Notes 7250 2250 0    60   ~ 0
The hall sensors
$Comp
L JUMPER_PIN P6
U 1 1 4A6FBF09
P 8600 1800
F 0 "P6" H 8600 1750 60  0000 C CNN
F 1 "JUMPER_PIN" H 8600 1950 60  0000 C CNN
	1    8600 1800
	1    0    0    -1  
$EndComp
$Comp
L JUMPER_PIN P5
U 1 1 4A6FBF06
P 8600 1500
F 0 "P5" H 8600 1450 60  0000 C CNN
F 1 "JUMPER_PIN" H 8600 1650 60  0000 C CNN
	1    8600 1500
	1    0    0    -1  
$EndComp
$Comp
L JUMPER_PIN P4
U 1 1 4A6FBF03
P 7750 1800
F 0 "P4" H 7750 1750 60  0000 C CNN
F 1 "JUMPER_PIN" H 7750 1950 60  0000 C CNN
	1    7750 1800
	1    0    0    -1  
$EndComp
$Comp
L JUMPER_PIN P3
U 1 1 4A6FBEFA
P 7750 1500
F 0 "P3" H 7750 1450 60  0000 C CNN
F 1 "JUMPER_PIN" H 7750 1650 60  0000 C CNN
	1    7750 1500
	1    0    0    -1  
$EndComp
$Comp
L PROTOTYPING_PINS P2
U 1 1 4A29AB13
P 5600 5100
F 0 "P2" H 5600 5100 60  0000 C CNN
F 1 "PROTOTYPING_PINS" H 5600 5200 60  0000 C CNN
	1    5600 5100
	1    0    0    -1  
$EndComp
Text Notes 3900 2700 0    60   ~ 0
and don't place D2 and R2.
$Comp
L C C1
U 1 1 4A273637
P 3350 1400
F 0 "C1" H 3400 1500 50  0000 L CNN
F 1 "C" H 3400 1300 50  0000 L CNN
	1    3350 1400
	1    0    0    -1  
$EndComp
Text Notes 3900 1950 0    60   ~ 0
GND instead of this pad
Text Notes 3900 1850 0    60   ~ 0
connect this lead to
Text Notes 3900 1750 0    60   ~ 0
To use D1 as power indicator,
$Comp
L C-6_CIRCUIT_BOARD CB1
U 1 1 4A1F5D68
P 5600 4700
F 0 "CB1" H 5600 4700 60  0000 C CNN
F 1 "C-6_CIRCUIT_BOARD" H 5600 4800 60  0000 C CNN
	1    5600 4700
	1    0    0    -1  
$EndComp
Text Label 4950 3700 0    60   ~ 0
VOUT
$Comp
L R R3
U 1 1 49E3884E
P 6800 1900
F 0 "R3" V 6880 1900 50  0000 C CNN
F 1 "68" V 6800 1900 50  0000 C CNN
	1    6800 1900
	1    0    0    -1  
$EndComp
$Comp
L LED D3
U 1 1 49E3884B
P 6800 1450
F 0 "D3" H 6800 1550 50  0000 C CNN
F 1 "WHT LED" H 6800 1350 50  0000 C CNN
	1    6800 1450
	0    1    1    0   
$EndComp
Text Notes 9150 4800 0    60   ~ 0
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
Text Label 4950 1250 0    60   ~ 0
VCC
$Comp
L PWR_FLAG #FLG01
U 1 1 49E13269
P 2550 1200
F 0 "#FLG01" H 2550 1470 30  0001 C CNN
F 1 "PWR_FLAG" H 2550 1430 30  0000 C CNN
	1    2550 1200
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG02
U 1 1 49E13266
P 3050 1600
F 0 "#FLG02" H 3050 1870 30  0001 C CNN
F 1 "PWR_FLAG" H 3050 1830 30  0000 C CNN
	1    3050 1600
	1    0    0    -1  
$EndComp
Text Notes 9150 4650 0    60   ~ 0
Install only one
$Comp
L SS441A U3
U 1 1 49DFC7F9
P 9750 2900
F 0 "U3" H 9750 2900 60  0000 C CNN
F 1 "SS441A" H 9900 2800 60  0000 C CNN
	1    9750 2900
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
L R R1
U 1 1 49DF8AA5
P 6150 1900
F 0 "R1" V 6230 1900 50  0000 C CNN
F 1 "150" V 6150 1900 50  0000 C CNN
	1    6150 1900
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 49DF899F
P 6150 3050
F 0 "R2" V 6230 3050 50  0000 C CNN
F 1 "68" V 6150 3050 50  0000 C CNN
	1    6150 3050
	1    0    0    -1  
$EndComp
Text Label 4950 3300 0    60   ~ 0
GND
$Comp
L SS441A U4
U 1 1 49C83B82
P 9750 3750
F 0 "U4" H 9750 3750 60  0000 C CNN
F 1 "SS441A" H 9900 3650 60  0000 C CNN
	1    9750 3750
	1    0    0    -1  
$EndComp
$Comp
L SS441A U2
U 1 1 49C83B66
P 9750 2050
F 0 "U2" H 9750 2050 60  0000 C CNN
F 1 "SS441A" H 9900 1950 60  0000 C CNN
	1    9750 2050
	1    0    0    -1  
$EndComp
Text Label 7200 1750 0    60   ~ 0
VOUT
Text Label 7200 1600 0    60   ~ 0
GND
Text Label 7200 1450 0    60   ~ 0
VCC
Text Label 4950 2400 0    60   ~ 0
START/STOP
$Comp
L LED D1
U 1 1 49C835C2
P 6150 1450
F 0 "D1" H 6150 1550 50  0000 C CNN
F 1 "RED LED" H 6150 1350 50  0000 C CNN
	1    6150 1450
	0    1    1    0   
$EndComp
$Comp
L LED D2
U 1 1 49C834FE
P 6150 2600
F 0 "D2" H 6150 2700 50  0000 C CNN
F 1 "GRN LED" H 6150 2500 50  0000 C CNN
	1    6150 2600
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
P 9750 1200
F 0 "U1" H 9750 1200 60  0000 C CNN
F 1 "SS441A" H 9900 1100 60  0000 C CNN
	1    9750 1200
	1    0    0    -1  
$EndComp
$EndSCHEMATC
