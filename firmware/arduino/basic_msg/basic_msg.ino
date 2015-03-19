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

#define VERSION "basic-1.02"
#define FALSE_START_TICKS 4

int statusLEDPin = 13;
long statusBlinkInterval = 250;
int lastStatusLEDValue = LOW;
long previousStatusBlinkMillis = 0;

boolean raceStarted = false;
boolean raceStarting = false;
boolean mockMode = false;
unsigned long raceStartMillis;
unsigned long currentTimeMillis;

char val = 0;

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

char charBuff[8];
unsigned int charBuffLen = 0;
boolean isReceivingRaceLength = false;

int raceLengthTicks = 20;
int previousFakeTickMillis = 0;

int updateInterval = 50;
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

boolean isAlphaNum(char c) {
  if(c >= '0' && c <= '9'){
    return true;
  }
  return false;
}

void checkSerial(){
  if(Serial.available() > 0) {
    val = Serial.read();
    if(val == '\r' || val == '\n') {
      if(isReceivingRaceLength){
        isReceivingRaceLength = false;
        raceLengthTicks = atoi(charBuff);
        Serial.print("L:");
        Serial.println(raceLengthTicks);  // send confirmation
      }
      
      // Ignore end-of-line characters.
      return;
    }
    if(isReceivingRaceLength) {
      charBuff[charBuffLen] = val;
      charBuffLen++;
    }
    else {
      if(val == 'l') {
          charBuffLen = 0;
          isReceivingRaceLength = true;
      }
      else if(val == 'p') {
        Serial.println("ACK");
      }
      else if(val == 'v') {
        Serial.println(VERSION);
      }
      else if(val == 'g') {
        for(int i=0; i<=3; i++)
        {
          racerTicks[i] = 0;
          racerFinishTimeMillis[i] = 0;
        }

        raceStarting = true;
        raceStarted = false;
        lastCountDown = 4;
        lastCountDownMillis = millis();
      }
      else if(val == 'm') {
        // toggle mock mode
        mockMode = !mockMode;
        if(mockMode){ Serial.println("M:ON"); }
        else{ Serial.println("M:OFF"); }
      }

      else if(val == 's') {
        raceStarted = false;
        raceStarting = false;

        digitalWrite(racer0GoLedPin,LOW);
        digitalWrite(racer1GoLedPin,LOW);
        digitalWrite(racer2GoLedPin,LOW);
        digitalWrite(racer3GoLedPin,LOW);
      }
      else {
        Serial.print("ERROR:Command invalid ");
        if(val > 32 && val < 127) {
          Serial.println(char(val));
        }
        else {
          Serial.print("ERROR:Unprintable ASCII code ");
          Serial.println(val);
        }
      }
    }
  }
}

void printStatusUpdate() {
  if(currentTimeMillis - lastUpdateMillis > updateInterval) {
    lastUpdateMillis = currentTimeMillis;
    
    Serial.print("R:");
    
    for(int i=0; i<=3; i++)
    {
      Serial.print(racerTicks[i], DEC);
      Serial.print(",");
    }
    Serial.println(currentTimeMillis, DEC);
  }
}

void loop() {
  blinkLED();

  checkSerial();

  if (raceStarting) {
    // Report false starts
    for(int i=0; i<=3; i++) {
      values[i] = digitalRead(sensorPins[i]);
      if(racerTicks[i] < FALSE_START_TICKS) {
        if(values[i] == HIGH && previoussensorValues[i] == LOW){
          racerTicks[i]++;
          if(racerTicks[i] == FALSE_START_TICKS) {
            Serial.print("FS:");
            Serial.println(i, DEC);
            digitalWrite(racer0GoLedPin+i,LOW);
          }
        }
      }
      previoussensorValues[i] = values[i];
    }

    if((millis() - lastCountDownMillis) > 1000){
      lastCountDown -= 1;
      lastCountDownMillis = millis();
      Serial.print("CD:");
      Serial.println(lastCountDown, DEC);
    }
    if(lastCountDown == 0) {
      raceStart();
      raceStarting = false;
      raceStarted = true;

      for(int i=0; i<=3; i++) {
        racerTicks[i] = 0;
        racerFinishTimeMillis[i] = 0;
      }

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
            Serial.print("F:");
            Serial.println(racerFinishTimeMillis[i], DEC);
            digitalWrite(racer0GoLedPin+i,LOW);
          }
        }
        previoussensorValues[i] = values[i];
      }
      
      // MOCK MODE
      else {
        if(currentTimeMillis - lastUpdateMillis > updateInterval) {
          racerTicks[i] += (i+1);
          
          if(racerFinishTimeMillis[i] == 0 && racerTicks[i] >= raceLengthTicks) {
            racerFinishTimeMillis[i] = currentTimeMillis;
            Serial.print(i);
            Serial.print("F:");
            Serial.println(racerFinishTimeMillis[i], DEC);
            digitalWrite(racer0GoLedPin+i,LOW);
          }
        }
      }
    }
  }
  printStatusUpdate();
}

