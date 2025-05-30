#define TRIG_PIN 7
#define ECHO_PIN 6
#define IN1 8
#define IN2 9
#define ENA 10

void setup() {
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(ENA, OUTPUT);
  Serial.begin(9600);
  Serial.setTimeout(100);  // wait 100 ms then continue
}

float readDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  return duration * 0.034 / 2;
}

void loop() {
  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');  // exmp: "F128"

    if (input == "M") {
      float distance = readDistance();
      Serial.println(distance, 2);
      return;
    }

    // Motor control
    char dir = input.charAt(0);           // 'F', 'R', 'S'
    int pwm = input.substring(1).toInt(); // exmp: "128" → 128

    if (dir == 'F') {
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      analogWrite(ENA, pwm);
    } else if (dir == 'R') {
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      analogWrite(ENA, pwm);
    } else if (dir == 'S') {
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      analogWrite(ENA, 0);
    }
  }
}
