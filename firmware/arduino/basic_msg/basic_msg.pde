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
 * 11           Start LED
 * 12           Stop LED
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

int startPin = 11;
int stopPin = 12;
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

int raceLengthTicks = 16;
int previousFakeTickMillis = 0;

int updateInterval = 250;
unsigned long lastUpdateMillis = 0;

void setup() {
  Serial.begin(115200); 
  pinMode(statusLEDPin, OUTPUT);
  pinMode(startPin, OUTPUT);
  pinMode(stopPin, OUTPUT);
  digitalWrite(startPin, LOW);
  digitalWrite(stopPin, LOW);
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
        raceStart();
        mockMode = true;

      }
      if(val == 's') {
        raceStarted = false;
        mockMode = false;

        digitalWrite(startPin,LOW);
        digitalWrite(stopPin,HIGH);
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
    if((millis() - lastCountDownMillis) > 500){
      digitalWrite(stopPin,LOW);
    }
    if((millis() - lastCountDownMillis) > 1000){
      digitalWrite(stopPin,HIGH);
      lastCountDown -= 1;
      lastCountDownMillis = millis();
    }
    if(lastCountDown == 0) {
      raceStart();
      raceStarting = false;
      raceStarted = true;

      digitalWrite(startPin,HIGH);
      digitalWrite(stopPin,LOW);

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

