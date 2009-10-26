/*
 * Arduino wiring:
 * 
 * Digital pin  Connected to
 * -----------  ------------
 * 2            Sensor 0
 * 3            Sensor 1
 * 4            Sensor 2
 * 5            Sensor 3
 * 
 * 9            Racer0 Start LED anode, Stop LED cathode
 * 10           Racer1 Start LED anode, Stop LED cathode
 * 11           Racer2 Start LED anode, Stop LED cathode
 * 12           Racer3 Start LED anode, Stop LED cathode
 * 
 */

int statusLEDPin = 13;
long statusBlinkInterval = 250;
int lastStatusLEDValue = LOW;
long previousStatusBlinkMillis = 0;

boolean raceStarted = false;
boolean raceStarting = false;
boolean mockMode = false;
unsigned long raceStartMillis;
unsigned long currentTimeMillis;

int val = 0;

int racer0GoLedPin = 9;
int racer1GoLedPin = 10;
int racer2GoLedPin = 11;
int racer3GoLedPin = 12;

int sensorPins[4] = {2,3,4,5};
int previoussensorValues[4] = {HIGH,HIGH,HIGH,HIGH};
int values[4] = {0,0,0,0};
unsigned long racerTicks[4] = {0,0,0,0};
unsigned long racerFinishTimeMillis[4];

unsigned long lastCountDownMillis;
int lastCountDown;

unsigned int charBuff[8];
unsigned int charBuffLen = 0;
boolean isReceivingRaceLength = false;

int raceLengthTicks = 20;
int previousFakeTickMillis = 0;

int updateInterval = 250;
unsigned long lastUpdateMillis = 0;

void setup() {
  Serial.begin(115200); 
  pinMode(statusLEDPin, OUTPUT);
  pinMode(racer0GoLedPin, OUTPUT);
  pinMode(racer1GoLedPin, OUTPUT);
  pinMode(racer2GoLedPin, OUTPUT);
  pinMode(racer3GoLedPin, OUTPUT);
  digitalWrite(racer0GoLedPin, LOW);
  digitalWrite(racer1GoLedPin, LOW);
  digitalWrite(racer2GoLedPin, LOW);
  digitalWrite(racer3GoLedPin, LOW);
  for(int i=0; i<=3; i++)
  {
    pinMode(sensorPins[i], INPUT);
    digitalWrite(sensorPins[i], HIGH);
  }

}

void blinkLED() {
  if (millis() - previousStatusBlinkMillis > statusBlinkInterval) {
    previousStatusBlinkMillis = millis();

    lastStatusLEDValue = !lastStatusLEDValue;

    digitalWrite(statusLEDPin, lastStatusLEDValue);
  }

}

void raceStart() {
  raceStartMillis = millis();
}


void checkSerial(){
  if(Serial.available()) {
    val = Serial.read();
    if(isReceivingRaceLength) {
      if(val != '\r') {
        charBuff[charBuffLen] = val;
        charBuffLen++;
      }
      else if(charBuffLen==2) {
        // received all the parts of the distance. time to process the value we received.
        // The maximum for 2 chars would be 65 535 ticks.
        // For a 0.25m circumference roller, that would be 16384 meters = 10.1805456 miles.
        raceLengthTicks = charBuff[1] * 256 + charBuff[0];
        isReceivingRaceLength = false;
        Serial.print("OK ");
        Serial.println(raceLengthTicks,DEC);
      }
      else {
        Serial.println("ERROR receiving tick lengths");
      }
    }
    else {
      if(val == 'l') {
          charBuffLen = 0;
          isReceivingRaceLength = true;
      }
      if(val == 'v') {
        Serial.print("basic-1");
      }
      if(val == 'g') {
        for(int i=0; i<=3; i++)
        {
          racerTicks[i] = 0;
          racerFinishTimeMillis[i] = 256*0;          
        }

        raceStarting = true;
        raceStarted = false;
        lastCountDown = 4;
        lastCountDownMillis = millis();
      }
          
      else if(val == 'm') {
        // toggle mock mode
        mockMode = !mockMode;
      }

      if(val == 's') {
        raceStarted = false;

        digitalWrite(racer0GoLedPin,LOW);
        digitalWrite(racer1GoLedPin,LOW);
        digitalWrite(racer2GoLedPin,LOW);
        digitalWrite(racer3GoLedPin,LOW);
      }
    }
  }
}

void printStatusUpdate() {
  if(currentTimeMillis - lastUpdateMillis > updateInterval) {
    lastUpdateMillis = currentTimeMillis;
    for(int i=0; i<=3; i++)
    {
      Serial.print(i);
      Serial.print(": ");
      Serial.println(racerTicks[i], DEC);
    }
    Serial.print("t: ");
    Serial.println(currentTimeMillis, DEC);
  }
}

void loop() {
  blinkLED();
  
  checkSerial();


  if (raceStarting) {
    if((millis() - lastCountDownMillis) > 1000){
      lastCountDown -= 1;
      lastCountDownMillis = millis();
    }
    if(lastCountDown == 0) {
      raceStart();
      raceStarting = false;
      raceStarted = true;

      digitalWrite(racer0GoLedPin,HIGH);
      digitalWrite(racer1GoLedPin,HIGH);
      digitalWrite(racer2GoLedPin,HIGH);
      digitalWrite(racer3GoLedPin,HIGH);
    }
  }
  if (raceStarted) {
    currentTimeMillis = millis() - raceStartMillis;

    for(int i=0; i<=3; i++)
    {
      if(!mockMode) {
        values[i] = digitalRead(sensorPins[i]);
        if(values[i] == HIGH && previoussensorValues[i] == LOW){
          racerTicks[i]++;
          if(racerFinishTimeMillis[i] == 0 && racerTicks[i] >= raceLengthTicks) {
            racerFinishTimeMillis[i] = currentTimeMillis;          
            Serial.print(i);
            Serial.print("f: ");
            Serial.println(racerFinishTimeMillis[i], DEC);
            digitalWrite(racer0GoLedPin+i,LOW);
          }
        }
        previoussensorValues[i] = values[i];
      }
      else {
        if(currentTimeMillis - lastUpdateMillis > updateInterval) {
          racerTicks[i]+=(i+1);
          if(racerFinishTimeMillis[i] == 0 && racerTicks[i] >= raceLengthTicks) {
            racerFinishTimeMillis[i] = currentTimeMillis;          
            Serial.print(i);
            Serial.print("f: ");
            Serial.println(racerFinishTimeMillis[i], DEC);
            digitalWrite(racer0GoLedPin+i,LOW);
          }
        }
      }
    }
  }
  

  if(racerFinishTimeMillis[0] != 0 && racerFinishTimeMillis[1] != 0 && racerFinishTimeMillis[2] != 0 && racerFinishTimeMillis[3] != 0){
    if(raceStarted) {
      raceStarted = false;
      printStatusUpdate();
    }
  } else {
    printStatusUpdate();
  }
}

