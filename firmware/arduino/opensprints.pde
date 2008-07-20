int statusLEDPin = 13;
long statusBlinkInterval = 1000;
int lastStatusLEDValue = LOW;
long previousStatusBlinkMillis = 0;

boolean raceStarted = false;
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

int raceLengthTicks = 8;
int previousFakeTickMillis = 0;

void turnOffLEDs() {
  digitalWrite(racer1LEDPins[0], LOW);
  digitalWrite(racer1LEDPins[1], LOW);
  digitalWrite(racer1LEDPins[2], LOW);
  digitalWrite(racer1LEDPins[3], LOW);
  digitalWrite(racer2LEDPins[0], LOW);
  digitalWrite(racer2LEDPins[1], LOW);
  digitalWrite(racer2LEDPins[2], LOW);
  digitalWrite(racer2LEDPins[3], LOW);
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

void raceStart() {
  racer1Ticks = 0;
  racer2Ticks = 0;
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
      raceStart();
      raceStarted = true;
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
  if (raceStarted) {
    currentTimeMillis = millis() - raceStartMillis;

    val1 = digitalRead(sensor1Pin);
    val2 = digitalRead(sensor2Pin);
    if(val1 == HIGH && previousSensor1Value == LOW){
      racer1Ticks++;

      Serial.print("1: ");
      Serial.println(currentTimeMillis, DEC);
    }
    if(val2 == HIGH && previousSensor2Value == LOW){
      racer2Ticks++;

      Serial.print("2: ");
      Serial.println(currentTimeMillis, DEC);
    }
    previousSensor1Value = val1;
    previousSensor2Value = val2;

    
  }
  
  updateProgressLEDs();
}
