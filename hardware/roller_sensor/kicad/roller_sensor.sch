EESchema Schematic File Version 2  date Wed 03 Jun 2009 09:53:56 PM CDT
LIBS:power,./symbols/custom_symbols,device,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,contrib,valves
EELAYER 23  0
EELAYER END
$Descr User 11000 8500
Sheet 1 1
Title "roller sensor progress indicator"
Date "4 jun 2009"
Rev "3.0"
Comp "www.opensprints.org"
Comment1 "OpenSprints"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Connection ~ 2550 1200
Connection ~ 3050 1600
Wire Wire Line
	3350 1600 2900 1600
Wire Wire Line
	2900 1600 2900 1300
Wire Notes Line
	4650 2300 4650 2100
Wire Notes Line
	3150 2650 4650 2650
Wire Notes Line
	3150 2650 3150 3000
Wire Notes Line
	3150 3000 4650 3000
Wire Notes Line
	4650 3000 4650 2650
Connection ~ 4900 2400
Wire Wire Line
	3700 2400 4400 2400
Wire Wire Line
	4900 2400 5400 2400
Wire Wire Line
	6050 2150 6050 3700
Wire Wire Line
	6050 3700 4200 3700
Wire Notes Line
	6700 1050 8150 1050
Wire Notes Line
	6700 1050 6700 4700
Wire Notes Line
	6700 4700 8150 4700
Wire Wire Line
	2150 2900 1800 2900
Wire Wire Line
	2150 2700 1800 2700
Wire Wire Line
	2150 2500 1800 2500
Wire Wire Line
	2150 2300 1800 2300
Wire Wire Line
	2150 2400 1800 2400
Wire Wire Line
	2150 2600 1800 2600
Wire Wire Line
	2150 2800 1800 2800
Wire Wire Line
	2150 3000 1800 3000
Wire Wire Line
	6900 1450 7300 1450
Wire Wire Line
	6900 3300 7300 3300
Wire Notes Line
	8150 4700 8150 1050
Wire Wire Line
	6900 4000 7300 4000
Wire Wire Line
	2150 1800 1800 1800
Wire Wire Line
	2150 1600 1800 1600
Wire Wire Line
	2150 1400 1800 1400
Wire Wire Line
	2150 1500 1800 1500
Wire Wire Line
	2150 1700 1800 1700
Wire Wire Line
	2150 1900 1800 1900
Wire Wire Line
	6900 1750 7300 1750
Wire Wire Line
	7300 2450 6900 2450
Wire Wire Line
	7300 2300 6900 2300
Wire Wire Line
	6900 2600 7300 2600
Wire Wire Line
	6900 4300 7300 4300
Wire Wire Line
	4200 3300 5400 3300
Wire Wire Line
	2150 4000 1800 4000
Wire Wire Line
	2150 3800 1800 3800
Wire Wire Line
	2150 3600 1800 3600
Wire Wire Line
	2150 3400 1800 3400
Wire Wire Line
	2150 3500 1800 3500
Wire Wire Line
	2150 3700 1800 3700
Wire Wire Line
	2150 3900 1800 3900
Wire Wire Line
	2150 4100 1800 4100
Wire Wire Line
	7300 4150 6900 4150
Wire Wire Line
	6900 3150 7300 3150
Wire Wire Line
	6900 3450 7300 3450
Wire Wire Line
	5400 2400 5400 2150
Wire Wire Line
	6900 1600 7300 1600
Connection ~ 5400 2400
Connection ~ 5400 2150
Connection ~ 5400 1750
Connection ~ 5400 1250
Connection ~ 5400 2900
Connection ~ 5400 3300
Connection ~ 6050 1750
Wire Wire Line
	6050 1250 4200 1250
Wire Wire Line
	4900 2900 4900 3300
Connection ~ 4900 3300
Wire Notes Line
	4650 2100 4500 2100
Wire Notes Line
	4500 2100 4500 2000
Wire Notes Line
	5050 1650 5050 2000
Wire Notes Line
	5050 1650 3600 1650
Wire Notes Line
	3600 1650 3600 2000
Wire Notes Line
	3600 2000 5050 2000
Wire Notes Line
	4650 2700 4800 2700
Wire Wire Line
	3350 1200 1800 1200
Wire Wire Line
	2900 1300 1800 1300
$Comp
L C C1
U 1 1 4A273637
P 3350 1400
F 0 "C1" H 3400 1500 50  0000 L CNN
F 1 "C" H 3400 1300 50  0000 L CNN
	1    3350 1400
	1    0    0    -1  
$EndComp
Text Notes 3150 2950 0    60   ~ 0
 D2 as GO indicator.
Text Notes 3200 2850 0    60   ~ 0
STOP indicator and
Text Notes 3200 2750 0    60   ~ 0
Remove to use D1 as
Text Notes 3650 1950 0    60   ~ 0
and to disable D2.
Text Notes 3650 1850 0    60   ~ 0
solid power indicator
Text Notes 3650 1750 0    60   ~ 0
Remove to use D1 as
$Comp
L R R10
U 1 1 4A26021A
P 4900 2650
F 0 "R10" V 4980 2650 50  0000 C CNN
F 1 "0" V 4900 2650 50  0000 C CNN
	1    4900 2650
	1    0    0    -1  
$EndComp
$Comp
L R R9
U 1 1 4A2601FE
P 4650 2400
F 0 "R9" V 4730 2400 50  0000 C CNN
F 1 "0" V 4650 2400 50  0000 C CNN
	1    4650 2400
	0    1    1    0   
$EndComp
$Comp
L C-6_CIRCUIT_BOARD CB1
U 1 1 4A1F5D68
P 4850 4700
F 0 "CB1" H 4850 4700 60  0000 C CNN
F 1 "C-6_CIRCUIT_BOARD" H 4850 4800 60  0000 C CNN
	1    4850 4700
	1    0    0    -1  
$EndComp
Text Label 4200 3700 0    60   ~ 0
VOUT
$Comp
L R R8
U 1 1 49E3884E
P 6050 1500
F 0 "R8" V 6130 1500 50  0000 C CNN
F 1 "68" V 6050 1500 50  0000 C CNN
	1    6050 1500
	1    0    0    -1  
$EndComp
$Comp
L LED D7
U 1 1 49E3884B
P 6050 1950
F 0 "D7" H 6050 2050 50  0000 C CNN
F 1 "WHT LED" H 6050 1850 50  0000 C CNN
	1    6050 1950
	0    1    1    0   
$EndComp
Text Notes 6700 5000 0    60   ~ 0
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
Text Label 4200 1250 0    60   ~ 0
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
Text Notes 6700 4850 0    60   ~ 0
Install only one
Text Label 6900 3450 0    60   ~ 0
VOUT
Text Label 6900 3300 0    60   ~ 0
GND
Text Label 6900 3150 0    60   ~ 0
VCC
$Comp
L SS441A U3
U 1 1 49DFC7F9
P 7500 2900
F 0 "U3" H 7500 2900 60  0000 C CNN
F 1 "SS441A" H 7650 2800 60  0000 C CNN
	1    7500 2900
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
P 5400 1500
F 0 "R2" V 5480 1500 50  0000 C CNN
F 1 "150" V 5400 1500 50  0000 C CNN
	1    5400 1500
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 49DF899F
P 5400 2650
F 0 "R3" V 5480 2650 50  0000 C CNN
F 1 "68" V 5400 2650 50  0000 C CNN
	1    5400 2650
	1    0    0    -1  
$EndComp
Text Label 4200 3300 0    60   ~ 0
GND
Text Label 6900 4300 0    60   ~ 0
VOUT
Text Label 6900 4150 0    60   ~ 0
GND
Text Label 6900 4000 0    60   ~ 0
VCC
$Comp
L SS441A U4
U 1 1 49C83B82
P 7500 3750
F 0 "U4" H 7500 3750 60  0000 C CNN
F 1 "SS441A" H 7650 3650 60  0000 C CNN
	1    7500 3750
	1    0    0    -1  
$EndComp
Text Label 6900 2600 0    60   ~ 0
VOUT
Text Label 6900 2450 0    60   ~ 0
GND
Text Label 6900 2300 0    60   ~ 0
VCC
$Comp
L SS441A U2
U 1 1 49C83B66
P 7500 2050
F 0 "U2" H 7500 2050 60  0000 C CNN
F 1 "SS441A" H 7650 1950 60  0000 C CNN
	1    7500 2050
	1    0    0    -1  
$EndComp
Text Label 6900 1750 0    60   ~ 0
VOUT
Text Label 6900 1600 0    60   ~ 0
GND
Text Label 6900 1450 0    60   ~ 0
VCC
Text Label 3700 2400 0    60   ~ 0
START/STOP
$Comp
L LED D1
U 1 1 49C835C2
P 5400 1950
F 0 "D1" H 5400 2050 50  0000 C CNN
F 1 "RED LED" H 5400 1850 50  0000 C CNN
	1    5400 1950
	0    1    1    0   
$EndComp
$Comp
L LED D2
U 1 1 49C834FE
P 5400 3100
F 0 "D2" H 5400 3200 50  0000 C CNN
F 1 "GRN LED" H 5400 3000 50  0000 C CNN
	1    5400 3100
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
P 7500 1200
F 0 "U1" H 7500 1200 60  0000 C CNN
F 1 "SS441A" H 7650 1100 60  0000 C CNN
	1    7500 1200
	1    0    0    -1  
$EndComp
$EndSCHEMATC
