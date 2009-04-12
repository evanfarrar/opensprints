EESchema Schematic File Version 2  date Sun 12 Apr 2009 09:58:00 AM CDT
LIBS:power,./symbols/custom_symbols,device,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,contrib,valves,./sensorWithLedArray.cache
EELAYER 24  0
EELAYER END
$Descr User 11000 8500
Sheet 1 1
Title "roller sensor progress indicator"
Date "12 apr 2009"
Rev "3.0"
Comp "www.opensprints.org"
Comment1 "OpenSprints"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	2550 4200 2200 4200
Wire Wire Line
	2550 4000 2200 4000
Wire Wire Line
	2550 3800 2200 3800
Wire Wire Line
	2550 3600 2200 3600
Wire Wire Line
	2550 3700 2200 3700
Wire Wire Line
	2550 3900 2200 3900
Wire Wire Line
	2550 4100 2200 4100
Wire Wire Line
	2550 4300 2200 4300
Text Label 2550 4300 0    60   ~ 0
LED3
Text Label 2550 4200 0    60   ~ 0
LED2
Text Label 2550 4100 0    60   ~ 0
LED1
Text Label 2550 4000 0    60   ~ 0
LED0
Text Label 2550 3900 0    60   ~ 0
START/STOP
Text Label 2550 3800 0    60   ~ 0
VOUT
Text Label 2550 3700 0    60   ~ 0
GND
Text Label 2550 3600 0    60   ~ 0
VCC
$Comp
L CONN_8 P1
U 1 1 49E1EB87
P 1850 3950
F 0 "P1" V 1800 3950 60  0000 C CNN
F 1 "CONN_8" V 1900 3950 60  0000 C CNN
	1    1850 3950
	-1   0    0    -1  
$EndComp
$Comp
L SCREW_HOLE H1
U 1 1 49E1EA07
P 1950 4700
F 0 "H1" H 1950 4800 60  0001 C CNN
F 1 "SCREW_HOLE" H 1950 4600 60  0000 C CNN
	1    1950 4700
	1    0    0    -1  
$EndComp
Wire Notes Line
	7400 4650 5500 4650
Wire Wire Line
	6550 1400 6100 1400
Wire Wire Line
	6100 1400 6100 1150
Wire Wire Line
	6100 1150 5900 1150
Wire Wire Line
	4750 1700 4750 1750
Wire Wire Line
	5250 2200 5250 2150
Wire Wire Line
	4000 3900 3550 3900
Wire Wire Line
	4000 3200 3550 3200
Wire Wire Line
	4500 3900 4650 3900
Wire Wire Line
	4500 3200 4650 3200
Connection ~ 4300 1150
Wire Wire Line
	4300 1150 4300 1200
Wire Wire Line
	5200 3100 5100 3100
Connection ~ 5100 3550
Wire Wire Line
	5050 3550 5100 3550
Wire Wire Line
	5100 3100 5100 4250
Wire Wire Line
	5100 4250 5050 4250
Wire Wire Line
	2750 1200 2200 1200
Wire Wire Line
	6150 3250 6550 3250
Wire Notes Line
	7400 4650 7400 1000
Wire Notes Line
	5500 4650 5500 1000
Wire Wire Line
	6150 3950 6550 3950
Wire Wire Line
	5250 2600 5250 2750
Wire Wire Line
	2550 1800 2200 1800
Wire Wire Line
	2550 1600 2200 1600
Wire Wire Line
	2550 1400 2200 1400
Wire Wire Line
	3550 2400 4950 2400
Wire Wire Line
	2550 1500 2200 1500
Wire Wire Line
	2550 1700 2200 1700
Wire Wire Line
	2550 1900 2200 1900
Wire Wire Line
	6150 1700 6550 1700
Wire Wire Line
	6550 2400 6150 2400
Wire Wire Line
	6550 2250 6150 2250
Wire Wire Line
	6150 2550 6550 2550
Wire Wire Line
	6150 4250 6550 4250
Connection ~ 4750 2400
Wire Wire Line
	5250 2750 3550 2750
Wire Wire Line
	4300 1700 4300 2400
Connection ~ 4300 2400
Wire Wire Line
	2550 3000 2200 3000
Wire Wire Line
	2550 2800 2200 2800
Wire Wire Line
	2550 2600 2200 2600
Wire Wire Line
	2550 2400 2200 2400
Wire Wire Line
	2550 2500 2200 2500
Wire Wire Line
	2550 2700 2200 2700
Wire Wire Line
	2550 2900 2200 2900
Wire Wire Line
	2550 3100 2200 3100
Wire Wire Line
	6550 4100 6150 4100
Wire Wire Line
	6150 3100 6550 3100
Wire Wire Line
	6150 3400 6550 3400
Wire Wire Line
	3000 1300 2200 1300
Wire Wire Line
	5050 3200 5100 3200
Connection ~ 5100 3200
Wire Wire Line
	5050 3900 5100 3900
Connection ~ 5100 3900
Wire Wire Line
	5250 1200 5250 1150
Wire Wire Line
	5250 1150 4000 1150
Wire Wire Line
	4750 1150 4750 1200
Connection ~ 4750 1150
Wire Wire Line
	4500 3550 4650 3550
Wire Wire Line
	4500 4250 4650 4250
Wire Wire Line
	4000 3550 3550 3550
Wire Wire Line
	4000 4250 3550 4250
Wire Wire Line
	4750 2150 4750 2400
Wire Wire Line
	5250 1700 5250 1750
Wire Wire Line
	5900 1550 6550 1550
Wire Notes Line
	5500 1000 7400 1000
$Comp
L C C1
U 1 1 49E17373
P 5900 1350
F 0 "C1" H 5950 1450 50  0000 L CNN
F 1 "0.1uF" H 5600 1250 50  0000 L CNN
	1    5900 1350
	1    0    0    -1  
$EndComp
Text Label 4000 1150 0    60   ~ 0
VCC
Text Label 5200 3100 0    60   ~ 0
VCC
$Comp
L PWR_FLAG #FLG01
U 1 1 49E13269
P 2750 1200
F 0 "#FLG01" H 2750 1470 30  0001 C CNN
F 1 "PWR_FLAG" H 2750 1430 30  0000 C CNN
	1    2750 1200
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG02
U 1 1 49E13266
P 3000 1300
F 0 "#FLG02" H 3000 1570 30  0001 C CNN
F 1 "PWR_FLAG" H 3000 1530 30  0000 C CNN
	1    3000 1300
	1    0    0    -1  
$EndComp
Text Notes 5050 4800 0    60   ~ 0
Install only one hall effect sensor.
Text Label 6150 3400 0    60   ~ 0
VOUT
Text Label 6150 3250 0    60   ~ 0
GND
Text Label 6150 3100 0    60   ~ 0
VCC
$Comp
L SS441A U3
U 1 1 49DFC7F9
P 6750 2850
F 0 "U3" H 6750 2850 60  0000 C CNN
F 1 "SS441A" H 6900 2750 60  0000 C CNN
	1    6750 2850
	1    0    0    -1  
$EndComp
Text Label 2550 3100 0    60   ~ 0
LED3
Text Label 2550 3000 0    60   ~ 0
LED2
Text Label 2550 2900 0    60   ~ 0
LED1
Text Label 2550 2800 0    60   ~ 0
LED0
Text Label 2550 2700 0    60   ~ 0
START/STOP
Text Label 2550 2600 0    60   ~ 0
VOUT
Text Label 2550 2500 0    60   ~ 0
GND
Text Label 2550 2400 0    60   ~ 0
VCC
$Comp
L RJ45 J2
U 1 1 49DF9008
P 1750 2750
F 0 "J2" H 1950 3250 60  0000 C CNN
F 1 "RJ45" H 1600 3250 60  0000 C CNN
	1    1750 2750
	0    -1   1    0   
$EndComp
$Comp
L R R7
U 1 1 49DF8EDE
P 4250 4250
F 0 "R7" V 4330 4250 50  0000 C CNN
F 1 "100" V 4250 4250 50  0000 C CNN
	1    4250 4250
	0    1    1    0   
$EndComp
$Comp
L R R6
U 1 1 49DF8EDA
P 4250 3900
F 0 "R6" V 4330 3900 50  0000 C CNN
F 1 "100" V 4250 3900 50  0000 C CNN
	1    4250 3900
	0    1    1    0   
$EndComp
$Comp
L R R5
U 1 1 49DF8ED4
P 4250 3550
F 0 "R5" V 4330 3550 50  0000 C CNN
F 1 "100" V 4250 3550 50  0000 C CNN
	1    4250 3550
	0    1    1    0   
$EndComp
$Comp
L R R1
U 1 1 49DF8D68
P 4300 1450
F 0 "R1" V 4380 1450 50  0000 C CNN
F 1 "10k" V 4300 1450 50  0000 C CNN
	1    4300 1450
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 49DF8AA5
P 4750 1450
F 0 "R2" V 4830 1450 50  0000 C CNN
F 1 "150" V 4750 1450 50  0000 C CNN
	1    4750 1450
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 49DF899F
P 5250 1450
F 0 "R3" V 5330 1450 50  0000 C CNN
F 1 "68" V 5250 1450 50  0000 C CNN
	1    5250 1450
	1    0    0    -1  
$EndComp
$Comp
L MOSFET_N Q1
U 1 1 49DF8829
P 5150 2400
F 0 "Q1" H 5160 2570 60  0000 R CNN
F 1 "MOSFET_N" H 5160 2250 60  0000 R CNN
F 4 "2N7000" H 4850 2150 60  0000 C CNN "Field1"
	1    5150 2400
	1    0    0    -1  
$EndComp
Text Label 3550 2750 0    60   ~ 0
GND
$Comp
L R R4
U 1 1 49C83C21
P 4250 3200
F 0 "R4" V 4330 3200 50  0000 C CNN
F 1 "100" V 4250 3200 50  0000 C CNN
	1    4250 3200
	0    1    1    0   
$EndComp
Text Label 6150 4250 0    60   ~ 0
VOUT
Text Label 6150 4100 0    60   ~ 0
GND
Text Label 6150 3950 0    60   ~ 0
VCC
$Comp
L SS441A U4
U 1 1 49C83B82
P 6750 3700
F 0 "U4" H 6750 3700 60  0000 C CNN
F 1 "SS441A" H 6900 3600 60  0000 C CNN
	1    6750 3700
	1    0    0    -1  
$EndComp
Text Label 6150 2550 0    60   ~ 0
VOUT
Text Label 6150 2400 0    60   ~ 0
GND
Text Label 6150 2250 0    60   ~ 0
VCC
$Comp
L SS441A U2
U 1 1 49C83B66
P 6750 2000
F 0 "U2" H 6750 2000 60  0000 C CNN
F 1 "SS441A" H 6900 1900 60  0000 C CNN
	1    6750 2000
	1    0    0    -1  
$EndComp
Text Label 6150 1700 0    60   ~ 0
VOUT
Text Label 6150 1550 0    60   ~ 0
GND
Text Label 6150 1400 0    60   ~ 0
VCC
Text Label 3550 4250 0    60   ~ 0
LED3
Text Label 3550 3900 0    60   ~ 0
LED2
Text Label 3550 3550 0    60   ~ 0
LED1
Text Label 3550 3200 0    60   ~ 0
LED0
Text Label 3550 2400 0    60   ~ 0
START/STOP
$Comp
L LED D1
U 1 1 49C835C2
P 4750 1950
F 0 "D1" H 4750 2050 50  0000 C CNN
F 1 "RED LED" H 4750 1850 50  0000 C CNN
	1    4750 1950
	0    1    1    0   
$EndComp
$Comp
L LED D2
U 1 1 49C834FE
P 5250 1950
F 0 "D2" H 5250 2050 50  0000 C CNN
F 1 "GRN LED" H 5250 1850 50  0000 C CNN
	1    5250 1950
	0    1    1    0   
$EndComp
$Comp
L LED D4
U 1 1 49C834EA
P 4850 3550
F 0 "D4" H 4850 3650 50  0000 C CNN
F 1 "LED" H 4850 3450 50  0000 C CNN
	1    4850 3550
	-1   0    0    1   
$EndComp
$Comp
L LED D3
U 1 1 49C834E9
P 4850 3200
F 0 "D3" H 4850 3300 50  0000 C CNN
F 1 "LED" H 4850 3100 50  0000 C CNN
	1    4850 3200
	-1   0    0    1   
$EndComp
Text Label 2550 1900 0    60   ~ 0
LED3
Text Label 2550 1800 0    60   ~ 0
LED2
Text Label 2550 1700 0    60   ~ 0
LED1
Text Label 2550 1600 0    60   ~ 0
LED0
Text Label 2550 1500 0    60   ~ 0
START/STOP
Text Label 2550 1400 0    60   ~ 0
VOUT
Text Label 2550 1300 0    60   ~ 0
GND
Text Label 2550 1200 0    60   ~ 0
VCC
$Comp
L RJ45 J1
U 1 1 49C834DF
P 1750 1550
F 0 "J1" H 1950 2050 60  0000 C CNN
F 1 "RJ45" H 1600 2050 60  0000 C CNN
	1    1750 1550
	0    -1   1    0   
$EndComp
$Comp
L LED D6
U 1 1 49C83284
P 4850 4250
F 0 "D6" H 4850 4350 50  0000 C CNN
F 1 "LED" H 4850 4150 50  0000 C CNN
	1    4850 4250
	-1   0    0    1   
$EndComp
$Comp
L SS441A U1
U 1 1 49C59A51
P 6750 1150
F 0 "U1" H 6750 1150 60  0000 C CNN
F 1 "SS441A" H 6900 1050 60  0000 C CNN
	1    6750 1150
	1    0    0    -1  
$EndComp
$Comp
L LED D5
U 1 1 49C597A9
P 4850 3900
F 0 "D5" H 4850 4000 50  0000 C CNN
F 1 "LED" H 4850 3800 50  0000 C CNN
	1    4850 3900
	-1   0    0    1   
$EndComp
$EndSCHEMATC
