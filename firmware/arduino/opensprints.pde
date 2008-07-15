int statusLEDPin = 13;
long statusBlinkInterval = 1000;
int lastStatusLEDValue = LOW;
long previousStatusBlinkMillis = 0;

boolean raceStarted = false;
unsigned long raceStartMillis;
unsigned long currentTimeMillis;

int sensor1LEDPin = 6;
int sensor2LEDPin = 7;
int sensor1Pin = 4;
int sensor2Pin = 5;
int previousSensor1Value = HIGH;
int previousSensor2Value = HIGH;
int val = 0;
int val1 = 0;
int val2 = 0;


void setup() {
  Serial.begin(9600); 
  Serial.println("1:");
  delay(100);
  pinMode(statusLEDPin, OUTPUT);
  pinMode(sensor1LEDPin, OUTPUT);
  pinMode(sensor2LEDPin, OUTPUT);
  pinMode(sensor1Pin, INPUT);
  pinMode(sensor2Pin, INPUT);
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

void readSensor(int sensorPin, int sensorLEDPin) {
  int val = digitalRead(sensorPin);
  if (val == HIGH) {
    digitalWrite(sensorLEDPin, LOW);
  } else {
    digitalWrite(sensorLEDPin, HIGH);
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

  if(raceStarted == true) {
    currentTimeMillis = millis() - raceStartMillis;
    val1 = digitalRead(sensor1Pin);
    val2 = digitalRead(sensor2Pin);
    if(val1 == HIGH && previousSensor1Value == LOW){
      Serial.print("1: ");
      Serial.println(currentTimeMillis, DEC);
    }
    if(val2 == HIGH && previousSensor2Value == LOW){
      Serial.print("2: ");
      Serial.println(currentTimeMillis, DEC);
    }

    previousSensor1Value = val1;
    previousSensor2Value = val2;
  }
  
  readSensor(sensor1Pin, sensor1LEDPin);
  readSensor(sensor2Pin, sensor2LEDPin);

}
