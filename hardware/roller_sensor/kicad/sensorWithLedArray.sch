EESchema Schematic File Version 2  date Mon 23 Mar 2009 09:17:21 PM CDT
LIBS:power,/home/orluke/workspace/opensprints/hardware/roller_sensor/kicad/custom_symbols,device,conn,linear,regul,74xx,cmos4000,adc-dac,memory,xilinx,special,microcontrollers,dsp,microchip,analog_switches,motorola,texas,intel,audio,interface,digital-audio,philips,display,cypress,siliconi,contrib,valves
EELAYER 24  0
EELAYER END
$Descr A4 11700 8267
Sheet 1 1
Title ""
Date "17 mar 2009"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	5250 2000 4050 2000
Text Label 4050 2000 0    60   ~ 0
GND
Wire Wire Line
	5800 4250 6200 4250
Wire Wire Line
	6200 3950 5800 3950
Wire Wire Line
	6200 4100 5800 4100
Wire Wire Line
	5800 3400 6200 3400
Wire Wire Line
	6200 3100 5800 3100
Wire Wire Line
	6200 3250 5800 3250
Wire Wire Line
	5800 2550 6200 2550
Wire Wire Line
	6200 2250 5800 2250
Wire Wire Line
	6200 2400 5800 2400
Wire Wire Line
	5800 1700 6200 1700
Wire Wire Line
	6200 1400 5800 1400
Wire Wire Line
	5250 2600 5250 3750
Wire Wire Line
	2550 3350 2200 3350
Wire Wire Line
	2550 3150 2200 3150
Wire Wire Line
	2550 2950 2200 2950
Wire Wire Line
	2550 2750 2200 2750
Wire Wire Line
	2550 2650 2200 2650
Wire Wire Line
	2550 2850 2200 2850
Wire Wire Line
	2550 3050 2200 3050
Wire Wire Line
	2550 3250 2200 3250
Wire Wire Line
	2550 1900 2200 1900
Wire Wire Line
	2550 1700 2200 1700
Wire Wire Line
	2550 1500 2200 1500
Wire Wire Line
	2550 1300 2200 1300
Wire Wire Line
	4050 1600 4750 1600
Wire Wire Line
	2550 1200 2200 1200
Wire Wire Line
	2550 1400 2200 1400
Wire Wire Line
	2550 1600 2200 1600
Wire Wire Line
	2550 1800 2200 1800
Wire Wire Line
	4350 2700 4050 2700
Wire Wire Line
	4350 3050 4050 3050
Wire Wire Line
	4350 3400 4050 3400
Wire Wire Line
	4350 3750 4050 3750
Wire Wire Line
	6200 1550 5800 1550
Wire Wire Line
	5250 1200 4050 1200
$Comp
L R R?
U 1 1 49C83CBA
P 5000 1600
F 0 "R?" V 5080 1600 50  0000 C CNN
F 1 "330" V 5000 1600 50  0000 C CNN
	1    5000 1600
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 49C83C5D
P 4600 3750
F 0 "R?" V 4680 3750 50  0000 C CNN
F 1 "330" V 4600 3750 50  0000 C CNN
	1    4600 3750
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 49C83C5A
P 4600 3400
F 0 "R?" V 4680 3400 50  0000 C CNN
F 1 "330" V 4600 3400 50  0000 C CNN
	1    4600 3400
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 49C83C56
P 4600 3050
F 0 "R?" V 4680 3050 50  0000 C CNN
F 1 "330" V 4600 3050 50  0000 C CNN
	1    4600 3050
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 49C83C21
P 4600 2700
F 0 "R?" V 4680 2700 50  0000 C CNN
F 1 "330" V 4600 2700 50  0000 C CNN
	1    4600 2700
	0    1    1    0   
$EndComp
Text Label 5800 4250 0    60   ~ 0
VOUT
Text Label 5800 4100 0    60   ~ 0
GND
Text Label 5800 3950 0    60   ~ 0
VCC
$Comp
L SS441A U?
U 1 1 49C83B82
P 6400 3700
F 0 "U?" H 6400 3700 60  0000 C CNN
F 1 "SS441A" H 6550 3600 60  0000 C CNN
	1    6400 3700
	1    0    0    -1  
$EndComp
Text Label 5800 3400 0    60   ~ 0
VOUT
Text Label 5800 3250 0    60   ~ 0
GND
Text Label 5800 3100 0    60   ~ 0
VCC
$Comp
L SS441A U?
U 1 1 49C83B81
P 6400 2850
F 0 "U?" H 6400 2850 60  0000 C CNN
F 1 "SS441A" H 6550 2750 60  0000 C CNN
	1    6400 2850
	1    0    0    -1  
$EndComp
Text Label 5800 2550 0    60   ~ 0
VOUT
Text Label 5800 2400 0    60   ~ 0
GND
Text Label 5800 2250 0    60   ~ 0
VCC
$Comp
L SS441A U?
U 1 1 49C83B66
P 6400 2000
F 0 "U?" H 6400 2000 60  0000 C CNN
F 1 "SS441A" H 6550 1900 60  0000 C CNN
	1    6400 2000
	1    0    0    -1  
$EndComp
Text Label 5800 1700 0    60   ~ 0
VOUT
Text Label 5800 1550 0    60   ~ 0
GND
Text Label 5800 1400 0    60   ~ 0
VCC
Text Label 4050 3750 0    60   ~ 0
LED4
Text Label 4050 3400 0    60   ~ 0
LED3
Text Label 4050 3050 0    60   ~ 0
LED2
Text Label 4050 2700 0    60   ~ 0
LED1
Text Label 5250 2600 0    60   ~ 0
VCC
Text Label 2550 3350 0    60   ~ 0
LED4
Text Label 2550 3250 0    60   ~ 0
LED3
Text Label 2550 3150 0    60   ~ 0
LED2
Text Label 2550 3050 0    60   ~ 0
LED1
Text Label 2550 2950 0    60   ~ 0
START/STOP
Text Label 2550 2850 0    60   ~ 0
VOUT
Text Label 2550 2750 0    60   ~ 0
GND
Text Label 2550 2650 0    60   ~ 0
VCC
$Comp
L RJ45 J?
U 1 1 49C8384F
P 1750 3000
F 0 "J?" H 1950 3500 60  0000 C CNN
F 1 "RJ45" H 1600 3500 60  0000 C CNN
	1    1750 3000
	0    -1   1    0   
$EndComp
Text Label 4050 1200 0    60   ~ 0
VCC
Text Label 4050 1600 0    60   ~ 0
START/STOP
$Comp
L LED D?
U 1 1 49C835C2
P 5250 1800
F 0 "D?" H 5250 1900 50  0000 C CNN
F 1 "LED" H 5250 1700 50  0000 C CNN
	1    5250 1800
	0    1    1    0   
$EndComp
$Comp
L LED D?
U 1 1 49C834FE
P 5250 1400
F 0 "D?" H 5250 1500 50  0000 C CNN
F 1 "LED" H 5250 1300 50  0000 C CNN
	1    5250 1400
	0    1    1    0   
$EndComp
$Comp
L LED D?
U 1 1 49C834EA
P 5050 3050
F 0 "D?" H 5050 3150 50  0000 C CNN
F 1 "LED" H 5050 2950 50  0000 C CNN
	1    5050 3050
	-1   0    0    1   
$EndComp
$Comp
L LED D?
U 1 1 49C834E9
P 5050 2700
F 0 "D?" H 5050 2800 50  0000 C CNN
F 1 "LED" H 5050 2600 50  0000 C CNN
	1    5050 2700
	-1   0    0    1   
$EndComp
Text Label 2550 1900 0    60   ~ 0
LED4
Text Label 2550 1800 0    60   ~ 0
LED3
Text Label 2550 1700 0    60   ~ 0
LED2
Text Label 2550 1600 0    60   ~ 0
LED1
Text Label 2550 1500 0    60   ~ 0
START/STOP
Text Label 2550 1400 0    60   ~ 0
VOUT
Text Label 2550 1300 0    60   ~ 0
GND
Text Label 2550 1200 0    60   ~ 0
VCC
$Comp
L RJ45 J?
U 1 1 49C834DF
P 1750 1550
F 0 "J?" H 1950 2050 60  0000 C CNN
F 1 "RJ45" H 1600 2050 60  0000 C CNN
	1    1750 1550
	0    -1   1    0   
$EndComp
$Comp
L LED D?
U 1 1 49C83284
P 5050 3750
F 0 "D?" H 5050 3850 50  0000 C CNN
F 1 "LED" H 5050 3650 50  0000 C CNN
	1    5050 3750
	-1   0    0    1   
$EndComp
$Comp
L SS441A U?
U 1 1 49C59A51
P 6400 1150
F 0 "U?" H 6400 1150 60  0000 C CNN
F 1 "SS441A" H 6550 1050 60  0000 C CNN
	1    6400 1150
	1    0    0    -1  
$EndComp
$Comp
L LED D?
U 1 1 49C597A9
P 5050 3400
F 0 "D?" H 5050 3500 50  0000 C CNN
F 1 "LED" H 5050 3300 50  0000 C CNN
	1    5050 3400
	-1   0    0    1   
$EndComp
$EndSCHEMATC
