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
 * Commands
 * --------
 * v    returns FW version basic-2
 * lXY  Initialize race distance (byte_to_decimal(X) * 256 + Y revolutions (ticks))
 * tABCDEFGH
 *      Initialize race distance (ABCDEFG is a zero-padded 8 decimal number of seconds)
 * g    Start the countdown and then the race
 * s    Stop the race
 * m    Toggle mock mode
 *
 * TODO: Error codes
 * -----------------
 * TBD
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

unsigned int charBuff[16];
unsigned int charBuffLen = 0;

boolean isDistanceRace = false;
boolean isReceivingRaceDist = false;
int raceLengthTicks = 20;
int previousFakeTickMillis = 0;

const int RACE_DURATION_DIGITS = 8;
boolean isDurationRace = false;
boolean isReceivingRaceDuration = false;
int raceDurSecs = 0;
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

    if(isReceivingRaceDist) {
      if(val != '\r') {
        charBuff[charBuffLen] = val;
        charBuffLen++;
      }
      else if(charBuffLen==2) {
        // received all the parts of the distance. time to process the value we received.
        // The maximum for 2 chars would be 65 535 ticks.
        // For a 0.25m circumference roller, that would be 16384 meters = 10.1805456 miles.
        raceLengthTicks = charBuff[1] * 256 + charBuff[0];
        isReceivingRaceDist = false;
        Serial.print("OK ");
        Serial.println(raceLengthTicks,DEC);
      }
      else {
        Serial.println("ERROR receiving tick lengths");
        charBuffLen = 0;
      }
    }

    else if(isReceivingRaceDuration) {
      if(charBuffLen <= RACE_DURATION_DIGITS) {
        // Read the next character of the race duration
        charBuff[charBuffLen] = val;
        charBuffLen++;
      }
      else {
        // All 8 characters of the race duration in seconds should have
        // arrived, so convert the input and set it to raceDurSecs.
        boolean durationSettingError = false;
        raceDurSecs = 0;
        int tensPlace = 1;
        for (int i = RACE_DURATION_DIGITS - 1; i >= 0 ; i--)
        {
          // Convert from char to int:
          int digit = charBuff[i] - '0';
          raceDurSecs = raceDurSecs + tensPl * digit;
          tensPlace = tensPlace * 10;
        }
        if (durationSettingError) {
          Serial.println("ERROR RACE DURATION seconds");
        }
        else {
          Serial.print("OK RACE DURATION ");
          Serial.println(raceDurSecs,DEC);
        }

        isReceivingRaceDuration = false;
        charBuffLen = 0;
      }
    }

    else {
      if(val == 'l') {
          charBuffLen = 0;
          isDistanceRace = true;
          isReceivingRaceDist = true;
      }
      if(val == 't') {
          charBuffLen = 0;
          isDurationRace = true;
          isReceivingRaceDuration = true;
      }
      if(val == 'v') {
        Serial.println("basic-2");
      }
      if(val == 'g') {
        // Assert proper initialization:
        // Either a duration race or a distance race can be configured,
        // but not both.
        if (isDurationRace == isDistanceRace) {
          Serial.println("ERROR initializing race");
          return;
        }

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

    for(int i=0; i<=3; i++)  // TODO: move this for loop inside, just around
    {
      if(!mockMode) {    // TODO: move mockMode logic inside.
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

// TODO: handle either duration or distance race in raceStarted block.
// TODO: ignore line ending chars from input
// TODO: Initialization routines:
//       - reset race length, duration, flags, call initCharBuff
//       - initCharBuff:
              charBuffLen = 0;
