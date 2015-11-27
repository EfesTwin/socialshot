import processing.serial.*;
import processing.net.*;

// CURRENT MIX
FluidMix current_mix;

// SERIAL PORT
Serial ArduinoPort;
int[] arr_serial = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };

// SETUP -------------------------------------------------------------------------

void setup()
{
  // SET ENVIROMENT
  size(400, 450);
  fill(#000000, 100);
  noStroke();
  rect(10, 10, 380, 140, 7);
  
  // Description Start Button
  textSize(16);
  fill(#ffffff, 200);
  text("Delete all Queue Items", 40, 60);
  
  // START BUTTON
  fill(#000000, 100);
  rect(270, 40, 80, 25, 7);
  textSize(16);
  fill(#ffffff, 200);
  text("Delete", 290, 60);

  // SERIAL PORT
  println("Available Ports: ");
  println(Serial.list());
  // Open the port
  ArduinoPort = new Serial(this, Serial.list()[2], 9600);
  ArduinoPort.bufferUntil(lf);
  println(SEPERATOR);
}

// DRAWING LOOP -------------------------------------------------------------------

void draw()
{ 
  
  changeCursor();
  
  // Serial Event Listener for Begin Handshake from Arduino
  while((serialEventComplete == false)&&(eventIsRunning == false))
  {
    serialEvent();
  }
  if(valveString.equals("8"))
  {
    println("Got Begin handshake. Nice!");
    println(" ");
    valveString = "";
    serialEventComplete = false;
    execJson = true;
  }
  
  // Get Execution Booleans and execute code
  if(execJson == true)
  { 
    // Increment OUTPUT_FILENUMBER
    OUTPUT_FILENUMBER += 1;
    // Get Valve Data
    println("Getting JSON Array");
    // LOAD DATA FROM JSON URL
    JSONArray jsonArray = loadJSONArray(QueueURL);
    
    // Get Size of JSON Array
    int jsonSize = jsonArray.size();
    
    // If JSON Array is empty, send skip handshake to Arduino (00Enter)
    if(jsonSize == 0)
    {
      println("No Items in Queue, sending Skip-Handshake");
      println(SEPERATOR);
      // Wait the amount of execdelay before sending to serial port
      timer = millis();
      while (millis()-timer < execdelay)
      {
        //pass
      }
      // Write 00 to the Arduino
      ArduinoPort.write(48);
      ArduinoPort.write(48);
      // Write Enter to the Arduino
      ArduinoPort.write(10);
      // Set Execution Boolean to false
      execJson = false;
    }
    else if(jsonSize == 1)
    {
      // Get first JSON Object in the Queue
      JSONObject inputObject = jsonArray.getJSONObject(0);
      
      // Get Sub Objects from Input Object
      JSONObject Predictions = inputObject.getJSONObject("predictions");
      
      // Get All Values from Predictions JSON Object
      float Extraversion = Predictions.getFloat("extraversion");
      float Agreeableness = Predictions.getFloat("agreeableness");
      float Conscientiousness = Predictions.getFloat("conscientiousness");
      float Openness = Predictions.getFloat("openness");
      float Neuroticism = Predictions.getFloat("neuroticism");
      
      // Get Queue ID and Facebook User ID
      String facebookID = inputObject.getString("fbid");
      int queueID = inputObject.getInt("_id");
      
      // Construct Array from Values
      float[] InputValues = { Neuroticism, Openness, Extraversion, Agreeableness, Conscientiousness };
      
      // Pass Values to Class
      FluidMix current_mix = new FluidMix(facebookID, queueID, InputValues);
      
      // Print Current Mix
      println(SEPERATOR);
      println("Printing Current Mix to File...");
      println("Filenumber = " + OUTPUT_FILENUMBER);
      println(" ");
      current_mix.PrintMix();
      println(SEPERATOR);
      
      // Send Valve Data
      SendSerialValveData(current_mix);
      execJson = false;
    }
    eventIsRunning = false;
  }
}

// MOUSE CURSOR AND BUTTONS --------------------------------------------------------------------
void changeCursor() 
{
  switch (mouseOverButton()) 
  {
  case 1:
    cursor(HAND);
    break;
  default:
    cursor(ARROW);
  }
}
int mouseOverButton() 
{
  if ((270 <= mouseX && mouseX <= 350) && (40 <= mouseY && mouseY <= 60)) 
  {
    return 1;
  }
  return 0;
}

void mouseClicked() 
{
  switch(mouseOverButton()) 
  {
  case 1:
    println(loadStrings("http://fbbot.joernroeder.de/cleanup"));
    break;
  }
}

// SERIAL EVENT --------------------------------------------------------------------

void serialEvent() 
{
  while (ArduinoPort.available() > 0) 
  {
    // get the new byte:
    char inChar = (char)ArduinoPort.read();
    // add it to the inputString:
    if(inChar != '\n')
    {
      valveString += inChar;
    }
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n')
    {
      println(valveString);
      serialEventComplete = true;
      eventIsRunning = true;
    }
  }
}

