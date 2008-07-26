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
int previoussensor0Value = HIGH;
int previoussensor1Value = HIGH;
int val0 = 0;
int val1 = 0;
unsigned long racer0Ticks = 0;
unsigned long racer1Ticks = 0;
int racer0LEDPins[4] = {4,5,6,7};
int racer1LEDPins[4] = {8,9,10,11};
unsigned long racer0FinishTimeMillis;
unsigned long racer1FinishTimeMillis;

unsigned long lastCountDownMillis;
int lastCountDown;

int raceLengthTicks = 700;
int previousFakeTickMillis = 0;

int updateInterval = 250;
unsigned long lastUpdateMillis = 0;

void racer0LEDs(int height){
  digitalWrite(racer0LEDPins[0], height);
  digitalWrite(racer0LEDPins[1], height);
  digitalWrite(racer0LEDPins[2], height);
  digitalWrite(racer0LEDPins[3], height);
}


void racer1LEDs(int height){
  digitalWrite(racer1LEDPins[0], height);
  digitalWrite(racer1LEDPins[1], height);
  digitalWrite(racer1LEDPins[2], height);
  digitalWrite(racer1LEDPins[3], height);
}

void allLEDs(int height){
  racer0LEDs(height);
  racer1LEDs(height);
}

void turnOffLEDs() {
  allLEDs(LOW);
}

void turnOnLEDs() {
  allLEDs(HIGH);
}

void setup() {
  Serial.begin(115200); 
  pinMode(statusLEDPin, OUTPUT);
  pinMode(sensor0Pin, INPUT);
  pinMode(sensor1Pin, INPUT);
  pinMode(buttonPin, INPUT);
  digitalWrite(buttonPin, HIGH);
  pinMode(racer0LEDPins[0], OUTPUT);
  pinMode(racer0LEDPins[1], OUTPUT);
  pinMode(racer0LEDPins[2], OUTPUT);
  pinMode(racer0LEDPins[3], OUTPUT);
  pinMode(racer1LEDPins[0], OUTPUT);
  pinMode(racer1LEDPins[1], OUTPUT);
  pinMode(racer1LEDPins[2], OUTPUT);
  pinMode(racer1LEDPins[3], OUTPUT);
  turnOffLEDs();
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

void blinkWinner() {

  if (millis() - previousWinnerBlinkMillis > statusBlinkInterval) {
    previousWinnerBlinkMillis = millis();

    if (lastWinnerLEDValue == LOW)
      lastWinnerLEDValue = HIGH;
    else
      lastWinnerLEDValue = LOW;

    if(racer0FinishTimeMillis < racer1FinishTimeMillis) {
      racer0LEDs(lastWinnerLEDValue);
    } else if (racer0FinishTimeMillis > racer1FinishTimeMillis) {
      racer1LEDs(lastWinnerLEDValue);
    } else if (racer0FinishTimeMillis == racer1FinishTimeMillis){
      // We're all winners! Yay!
      racer0LEDs(lastWinnerLEDValue);
      racer1LEDs(lastWinnerLEDValue);
    }
  }
}

void raceStart() {
  raceStartMillis = millis();
  turnOffLEDs();
}

void updateProgressLEDs() {
  if(racer0Ticks >= (raceLengthTicks * 0.25)){
    digitalWrite(racer0LEDPins[0], HIGH);
  }
  if(racer0Ticks >= (raceLengthTicks * 0.5)){
    digitalWrite(racer0LEDPins[1], HIGH);
  }
  if(racer0Ticks >= (raceLengthTicks * 0.75)){
    digitalWrite(racer0LEDPins[2], HIGH);
  }
  if(racer0Ticks >= (raceLengthTicks)){
    digitalWrite(racer0LEDPins[3], HIGH);
  }
  if(racer1Ticks >= (raceLengthTicks * 0.25)){
    digitalWrite(racer1LEDPins[0], HIGH);
  }
  if(racer1Ticks >= (raceLengthTicks * 0.5)){
    digitalWrite(racer1LEDPins[1], HIGH);
  }
  if(racer1Ticks >= (raceLengthTicks * 0.75)){
    digitalWrite(racer1LEDPins[2], HIGH);
  }
  if(racer1Ticks >= (raceLengthTicks)){
    digitalWrite(racer1LEDPins[3], HIGH);
  }
}

void checkSerial(){
  if(Serial.available()) {
    val = Serial.read();
    if(val == 'g') {
      racer0Ticks = 0;
      racer1Ticks = 0;
      racer0FinishTimeMillis = 0;          
      racer1FinishTimeMillis = 0;          
      raceStarting = true;
      lastCountDown = 4;
      lastCountDownMillis = millis();
      turnOnLEDs();
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

void checkButton(){
  val = digitalRead(buttonPin);
  if(lastButtonValue == LOW && val == HIGH) {
      racer0Ticks = 0;
      racer1Ticks = 0;
      racer0FinishTimeMillis = 0;          
      racer1FinishTimeMillis = 0;          
      raceStarting = true;
      lastCountDown = 4;
      lastCountDownMillis = millis();
      turnOnLEDs();
  } 
  lastButtonValue = val;
}

void printStatusUpdate() {
  if(currentTimeMillis - lastUpdateMillis > updateInterval) {
    lastUpdateMillis = currentTimeMillis;
    Serial.print("1: ");
    Serial.println(racer0Ticks, DEC);
    Serial.print("2: ");
    Serial.println(racer1Ticks, DEC);
  }
}

void loop() {
  blinkLED();
  
  checkSerial();
  checkButton();


  if (mockMode) {
    currentTimeMillis = millis() - raceStartMillis;
    if (currentTimeMillis - previousFakeTickMillis > 250) {
      previousFakeTickMillis = currentTimeMillis;
      
      Serial.print("0: ");
      Serial.println(currentTimeMillis, DEC);
      racer0Ticks++;
      Serial.print("1: ");
      Serial.println(currentTimeMillis, DEC);
      racer1Ticks++;

    }

  }
  if (raceStarting) {
    if((millis() - lastCountDownMillis) > 1000){
      lastCountDown -= 1;
      lastCountDownMillis = millis();
      digitalWrite(racer0LEDPins[lastCountDown], LOW);
      digitalWrite(racer1LEDPins[lastCountDown], LOW);
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
    previoussensor0Value = val0;
    previoussensor1Value = val1;

  }
  

  if(racer0FinishTimeMillis != 0 && racer1FinishTimeMillis != 0){
    if(raceStarted) {
      raceStarted = false;
      printStatusUpdate();
      updateProgressLEDs();
    }
    blinkWinner();
  } else {
    updateProgressLEDs();
    printStatusUpdate();
  }
}

