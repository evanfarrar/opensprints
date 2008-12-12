int statusLEDPin = 13;
long statusBlinkInterval = 250;
int lastStatusLEDValue = LOW;
long previousStatusBlinkMillis = 0;

int lastWinnerLEDValue = LOW;
long previousWinnerBlinkMillis = 0;

boolean raceStarted = false;
boolean raceStarting = false;
boolean mockMode = false;
unsigned long raceStartMillis;
unsigned long currentTimeMillis;

int buttonPin = 12;
int lastButtonValue = HIGH;

int val = 0;

int sensor0Pin = 2;
int sensor1Pin = 3;
int sensor2Pin = 4;
int sensor3Pin = 5;
int previoussensor0Value = HIGH;
int previoussensor1Value = HIGH;
int previoussensor2Value = HIGH;
int previoussensor3Value = HIGH;
int val0 = 0;
int val1 = 0;
int val2 = 0;
int val3 = 0;
unsigned long racer0Ticks = 0;
unsigned long racer1Ticks = 0;
unsigned long racer2Ticks = 0;
unsigned long racer3Ticks = 0;
unsigned long racer0FinishTimeMillis;
unsigned long racer1FinishTimeMillis;
unsigned long racer2FinishTimeMillis;
unsigned long racer3FinishTimeMillis;

unsigned long lastCountDownMillis;
int lastCountDown;

int raceLengthTicks = 1400;
int previousFakeTickMillis = 0;

int updateInterval = 250;
unsigned long lastUpdateMillis = 0;

void setup() {
  Serial.begin(115200); 
  pinMode(statusLEDPin, OUTPUT);
  pinMode(sensor0Pin, INPUT);
  pinMode(sensor1Pin, INPUT);
  pinMode(buttonPin, INPUT);
  digitalWrite(buttonPin, HIGH);
  digitalWrite(sensor0Pin, HIGH);
  digitalWrite(sensor1Pin, HIGH);
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
      racer0Ticks = 0;
      racer1Ticks = 0;
      racer2Ticks = 0;
      racer3Ticks = 0;
      racer0FinishTimeMillis = 0;          
      racer1FinishTimeMillis = 0;          
      racer2FinishTimeMillis = 0;          
      racer3FinishTimeMillis = 0;          
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
    Serial.print("1: ");
    Serial.println(racer0Ticks, DEC);
    Serial.print("2: ");
    Serial.println(racer1Ticks, DEC);
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

    val0 = digitalRead(sensor0Pin);
    val1 = digitalRead(sensor1Pin);
    val2 = digitalRead(sensor1Pin);
    val3 = digitalRead(sensor1Pin);
    if(val0 == HIGH && previoussensor0Value == LOW){
      racer0Ticks++;
      if(racer0FinishTimeMillis == 0 && racer0Ticks >= raceLengthTicks) {
        racer0FinishTimeMillis = currentTimeMillis;          
        Serial.print("1f: ");
        Serial.println(racer0FinishTimeMillis, DEC);
      }
    }
    if(val1 == HIGH && previoussensor1Value == LOW){
      racer1Ticks++;
      if(racer1FinishTimeMillis == 0 && racer1Ticks >= raceLengthTicks) {
        racer1FinishTimeMillis = currentTimeMillis;
        Serial.print("2f: ");
        Serial.println(racer1FinishTimeMillis, DEC);
      }
    }
    if(val2 == HIGH && previoussensor2Value == LOW){
      racer2Ticks++;
      if(racer2FinishTimeMillis == 0 && racer2Ticks >= raceLengthTicks) {
        racer2FinishTimeMillis = currentTimeMillis;
        Serial.print("3f: ");
        Serial.println(racer2FinishTimeMillis, DEC);
      }
    }
    if(val3 == HIGH && previoussensor3Value == LOW){
      racer3Ticks++;
      if(racer3FinishTimeMillis == 0 && racer3Ticks >= raceLengthTicks) {
        racer3FinishTimeMillis = currentTimeMillis;
        Serial.print("4f: ");
        Serial.println(racer3FinishTimeMillis, DEC);
      }
    }
    previoussensor0Value = val0;
    previoussensor1Value = val1;
    previoussensor2Value = val2;
    previoussensor3Value = val3;

  }
  

  if(racer0FinishTimeMillis != 0 && racer1FinishTimeMillis != 0 && racer2FinishTimeMillis != 0 && racer3FinishTimeMillis != 0){
    if(raceStarted) {
      raceStarted = false;
      printStatusUpdate();
    }
  } else {
    printStatusUpdate();
  }
}

