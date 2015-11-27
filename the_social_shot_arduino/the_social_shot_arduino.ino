// CONFIG -------------------------------------------------------------------------

// Status LED Pins
int statusLedGreen = 12;
int statusLedRed = 13;

// Valve Pins
int pin_valve1 = 15;        // Valve Pin 1
int pin_valve2 = 16;        // Valve Pin 2
int pin_valve3 = 17;        // Valve Pin 3
int pin_valve4 = 18;        // Valve Pin 4
int pin_valve5 = 19;        // Valve Pin 5

// Button Pin
int buttonPin = 11;

// Current Pin
int pin_current;
boolean buttonBlocked = false;
boolean buttonPressed = false;

// Runtime measurement
unsigned long currentMillis;

// Variables for Serial Input
boolean serialEventComplete = false;
String valveString = "";
String valveNumberString = "";

// Variables for Valve Number and Open Time
int valveNumber;
int waitOpen;

// SETUP ------------------------------------------------------------------------
void setup()
{
  // Begin Serial communication at 9600 Baud
  Serial.begin(9600);

  // Reserve Memory for inputstring
  valveString.reserve(200);

  // Initialize Pinmodes for LEDs
  pinMode(statusLedGreen, OUTPUT);
  pinMode(statusLedRed, OUTPUT);

  // Initialize Pinmodes for Valves
  pinMode(pin_valve1, OUTPUT);
  pinMode(pin_valve2, OUTPUT);
  pinMode(pin_valve3, OUTPUT);
  pinMode(pin_valve4, OUTPUT);
  pinMode(pin_valve5, OUTPUT);

  // Initialize Pinmode for Button
  pinMode(buttonPin, INPUT);
  // enable pullup resistors for button
  digitalWrite(buttonPin, HIGH);

  // Turn Green LED on and Red LED off
  digitalWrite(statusLedRed, LOW);
  digitalWrite(statusLedGreen, HIGH);
}

// LOOP -------------------------------------------------------------------------
void loop()
{
  // ON BUTTON PRESS -----------------------------------------
  if ((digitalRead(buttonPin) == LOW)&&(buttonPressed == false))
  {
    buttonPressed = true;
    // Blink Green LED
    digitalWrite(statusLedGreen, HIGH);
    currentMillis = millis();
    while (millis() - currentMillis < 40UL) {}
    digitalWrite(statusLedGreen, LOW);

    if (buttonBlocked == false)
    {
      // Send Start Handshake (8 - Enter) to Processing
      Serial.write(56);
      Serial.write(10);

      // 2 sec delay
      currentMillis = millis();
      while (millis() - currentMillis < 1000UL) {}
    }
  }

  if (digitalRead(buttonPin) == HIGH)
  {
    buttonPressed = false;
  }

  // ON COMPLETE SERIAL EVENT -------------------------------
  if (serialEventComplete)
  {
    // Block Button for the Time of Execution
    buttonBlocked = true;

    // Turn Green LED Off
    digitalWrite(statusLedGreen, LOW);

    // Get Valve Number
    valveNumberString += valveString.charAt(0);
    valveNumber = valveNumberString.toInt();
    valveString.remove(0, 1);

    // Get Time to Open
    waitOpen = valveString.toInt();

    // Reset inputStrings
    valveString = "";
    valveNumberString = "";

    // IF SKIP IS RECEIVED
    if (valveNumber == 0)
    {
      // Blink Red LED three times
      digitalWrite(statusLedRed, HIGH);
      currentMillis = millis();
      while (millis() - currentMillis < 200UL) {}
      digitalWrite(statusLedRed, LOW);
      currentMillis = millis();
      while (millis() - currentMillis < 200UL) {}
      digitalWrite(statusLedRed, HIGH);
      currentMillis = millis();
      while (millis() - currentMillis < 200UL) {}
      digitalWrite(statusLedRed, LOW);
      currentMillis = millis();
      while (millis() - currentMillis < 200UL) {}
      digitalWrite(statusLedRed, HIGH);
      currentMillis = millis();
      while (millis() - currentMillis < 200UL) {}
      digitalWrite(statusLedRed, LOW);
    }
    else
    {
      // Turn on Red Led
      digitalWrite(statusLedRed, HIGH);

      // SET CURRENT VALVE
      if (valveNumber == 1)
      {
        pin_current = pin_valve1;
      }
      else if (valveNumber == 2) {
        pin_current = pin_valve2;
      }
      else if (valveNumber == 3) {
        pin_current = pin_valve3;
      }
      else if (valveNumber == 4) {
        pin_current = pin_valve4;
      }
      else if (valveNumber == 5) {
        pin_current = pin_valve5;
      }
      
      // Open Valve, wait for waitOpen, Close Valve
      digitalWrite(pin_current, HIGH);
      currentMillis = millis();
      while (millis() - currentMillis < waitOpen)
      {
        // pass
      }
      digitalWrite(pin_current, LOW);

      // Wait for a Second before sending Handshake (9, Enter) to Processing
      currentMillis = millis();
      while (millis() - currentMillis < 1000UL) {}
      Serial.write(57);
      Serial.write(10);

      // Reset currentMillis
      currentMillis = 0;
    }

    // Reset Serial Event Boolean
    serialEventComplete = false;

    // Turn Red LED off and green LED on
    digitalWrite(statusLedRed, LOW);
    digitalWrite(statusLedGreen, HIGH);

    // Deblock Button
    buttonBlocked = false;
  }
}

// SERIAL EVENT ---------------------------------------------------------

void serialEvent()
{
  while (Serial.available())
  {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    valveString += inChar;
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n')
    {
      serialEventComplete = true;
    }
  }
}
