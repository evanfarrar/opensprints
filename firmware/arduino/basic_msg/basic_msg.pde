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

int sensorPins[4] = {2,3,4,5};
int previoussensorValues[4] = {HIGH,HIGH,HIGH,HIGH};
int values[4] = {0,0,0,0};
unsigned long racerTicks[4] = {0,0,0,0};
unsigned long racerFinishTimeMillis[4];

unsigned long lastCountDownMillis;
int lastCountDown;

int raceLengthTicks = 1400;
int previousFakeTickMillis = 0;

int updateInterval = 250;
unsigned long lastUpdateMillis = 0;

void setup() {
  Serial.begin(115200); 
  pinMode(statusLEDPin, OUTPUT);
  for(int i=0; i<=3; i++)
  {
    pinMode(sensorPins[i], INPUT);
    digitalWrite(sensorPins[i], HIGH);
  }

}

void blinkLED() {
  if (millis() - previousStatusBlinkMillis > statusBlinkInterval) {
    previousStatusBlinkMillis = millis();

    if (lastStatusLEDValue == LOW)
      lastStatusLEDValue = HIGH;
    else
      lastStatusLEDValue = LOW;
  

    digitalWrite(statusLEDPin, lastStatusLEDValue);
  }

}

void raceStart() {
  raceStartMillis = millis();
}


void checkSerial(){
  if(Serial.available()) {
    val = Serial.read();
    if(val == 'g') {
      for(int i=0; i<=3; i++)
      {
        racerTicks[i] = 0;
        racerFinishTimeMillis[i] = 0;          
      }

      raceStarting = true;
      lastCountDown = 4;
      lastCountDownMillis = millis();
    }
    if(val == 'm') {
      raceStart();
      mockMode = true;
    }
    if(val == 's') {
      raceStarted = false;
      mockMode = false;
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
    }
  }
  if (raceStarted) {
    currentTimeMillis = millis() - raceStartMillis;

    for(int i=0; i<=3; i++)
    {
      values[i] = digitalRead(sensorPins[i]);
      if(values[i] == HIGH && previoussensorValues[i] == LOW){
        racerTicks[i]++;
        if(racerFinishTimeMillis[i] == 0 && racerTicks[0] >= raceLengthTicks) {
          racerFinishTimeMillis[i] = currentTimeMillis;          
          Serial.print(i);
          Serial.print("f: ");
          Serial.println(racerFinishTimeMillis[i], DEC);
        }
      }
      previoussensorValues[i] = values[i];
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

