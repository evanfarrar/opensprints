int statusLEDPin = 13;
long statusBlinkInterval = 1000;
int lastStatusLEDValue = LOW;
long previousStatusBlinkMillis = 0;

boolean raceStarted = false;
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


void setup() {
  Serial.begin(9600); 
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

void loop() {
  blinkLED();

  if(Serial.available()) {
    val = Serial.read();
    if(val == 'g') {
      raceStartMillis = millis();
      raceStarted = true;
    }
    if(val == 's') {
      raceStarted = false;
    }
  }

  val = digitalRead(buttonPin);
  if(lastButtonValue == LOW && val == HIGH) {
    raceStarted = true;
  } 
  lastButtonValue = val;


  if(raceStarted == true) {
    currentTimeMillis = millis() - raceStartMillis;

    val1 = digitalRead(sensor1Pin);
    val2 = digitalRead(sensor2Pin);
    if(val1 == HIGH && previousSensor1Value == LOW){
      racer1Ticks++;
      val = racer1Ticks / (raceLengthTicks / 4) - 1;
      digitalWrite(racer1LEDPins[val], HIGH);

      Serial.print("1: ");
      Serial.println(currentTimeMillis, DEC);
    }
    if(val2 == HIGH && previousSensor2Value == LOW){
      racer2Ticks++;
      val = racer2Ticks / (raceLengthTicks / 4) - 1;
      digitalWrite(racer2LEDPins[val], HIGH);

      Serial.print("2: ");
      Serial.println(currentTimeMillis, DEC);
    }
    previousSensor1Value = val1;
    previousSensor2Value = val2;

    
  }
}
