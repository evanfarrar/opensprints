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

int buttonPin = 11;
int lastButtonValue = HIGH;

int val = 0;

int sensor1Pin = 2;
int sensor2Pin = 3;
int previousSensor1Value = HIGH;
int previousSensor2Value = HIGH;
int val1 = 0;
int val2 = 0;
int racer1Ticks = 0;
int racer2Ticks = 0;
int racer1LEDPins[4] = {4,5,6,7};
int racer2LEDPins[4] = {8,9,10,11};
unsigned long racer1FinishTimeMillis;
unsigned long racer2FinishTimeMillis;

unsigned long lastCountDownMillis;
int lastCountDown;

int raceLengthTicks = 8;
int previousFakeTickMillis = 0;

void racer1LEDs(int height){
  digitalWrite(racer1LEDPins[0], height);
  digitalWrite(racer1LEDPins[1], height);
  digitalWrite(racer1LEDPins[2], height);
  digitalWrite(racer1LEDPins[3], height);
}


void racer2LEDs(int height){
  digitalWrite(racer2LEDPins[0], height);
  digitalWrite(racer2LEDPins[1], height);
  digitalWrite(racer2LEDPins[2], height);
  digitalWrite(racer2LEDPins[3], height);
}

void allLEDs(int height){
  racer1LEDs(height);
  racer2LEDs(height);
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
  pinMode(sensor1Pin, INPUT);
  pinMode(sensor2Pin, INPUT);
  pinMode(buttonPin, INPUT);
  pinMode(racer1LEDPins[0], OUTPUT);
  pinMode(racer1LEDPins[1], OUTPUT);
  pinMode(racer1LEDPins[2], OUTPUT);
  pinMode(racer1LEDPins[3], OUTPUT);
  pinMode(racer2LEDPins[0], OUTPUT);
  pinMode(racer2LEDPins[1], OUTPUT);
  pinMode(racer2LEDPins[2], OUTPUT);
  pinMode(racer2LEDPins[3], OUTPUT);
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

    if(racer1FinishTimeMillis < racer2FinishTimeMillis) {
      racer1LEDs(lastWinnerLEDValue);
    } else if (racer1FinishTimeMillis > racer2FinishTimeMillis) {
      racer2LEDs(lastWinnerLEDValue);
    } else if (racer1FinishTimeMillis == racer2FinishTimeMillis){
      // We're all winners! Yay!
      racer1LEDs(lastWinnerLEDValue);
      racer2LEDs(lastWinnerLEDValue);
    }
  }
}

void raceStart() {
  raceStartMillis = millis();
  turnOffLEDs();
}

void updateProgressLEDs() {
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
  if(racer2Ticks >= (raceLengthTicks * 0.25)){
    digitalWrite(racer2LEDPins[0], HIGH);
  }
  if(racer2Ticks >= (raceLengthTicks * 0.5)){
    digitalWrite(racer2LEDPins[1], HIGH);
  }
  if(racer2Ticks >= (raceLengthTicks * 0.75)){
    digitalWrite(racer2LEDPins[2], HIGH);
  }
  if(racer2Ticks >= (raceLengthTicks)){
    digitalWrite(racer2LEDPins[3], HIGH);
  }
}

void loop() {
  blinkLED();

  if(Serial.available()) {
    val = Serial.read();
    if(val == 'g') {
      racer1Ticks = 0;
      racer2Ticks = 0;
      racer1FinishTimeMillis = 0;          
      racer2FinishTimeMillis = 0;          
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

  val = digitalRead(buttonPin);
  if(lastButtonValue == LOW && val == HIGH) {
    raceStarted = true;
  } 
  lastButtonValue = val;

  if (mockMode) {
    currentTimeMillis = millis() - raceStartMillis;
    if (currentTimeMillis - previousFakeTickMillis > 250) {
      previousFakeTickMillis = currentTimeMillis;
      
      Serial.print("1: ");
      Serial.println(currentTimeMillis, DEC);
      racer1Ticks++;
      Serial.print("2: ");
      Serial.println(currentTimeMillis, DEC);
      racer2Ticks++;

    }

  }
  if (raceStarting) {
    if((millis() - lastCountDownMillis) > 1000){
      lastCountDown -= 1;
      lastCountDownMillis = millis();
      digitalWrite(racer1LEDPins[lastCountDown], LOW);
      digitalWrite(racer2LEDPins[lastCountDown], LOW);
    }
    if(lastCountDown == 0) {
      raceStart();
      raceStarting = false;
      raceStarted = true;
    }
  }
  if (raceStarted) {
    currentTimeMillis = millis() - raceStartMillis;

    val1 = digitalRead(sensor1Pin);
    val2 = digitalRead(sensor2Pin);
    if(val1 == HIGH && previousSensor1Value == LOW){
      racer1Ticks++;
      if(racer1FinishTimeMillis == 0 && racer1Ticks >= raceLengthTicks) {
        racer1FinishTimeMillis = currentTimeMillis;          
      }

      Serial.print("1: ");
      Serial.println(currentTimeMillis, DEC);
    }
    if(val2 == HIGH && previousSensor2Value == LOW){
      racer2Ticks++;
      if(racer2FinishTimeMillis == 0 && racer2Ticks >= raceLengthTicks) {
        racer2FinishTimeMillis = currentTimeMillis;
      }

      Serial.print("2: ");
      Serial.println(currentTimeMillis, DEC);
    }
    previousSensor1Value = val1;
    previousSensor2Value = val2;

    
  }
  

  if(racer1FinishTimeMillis != 0 && racer2FinishTimeMillis != 0){
    if(raceStarted) {
      raceStarted = false;
      updateProgressLEDs();
    }
    blinkWinner();
  } else {
    updateProgressLEDs();
  }
}
