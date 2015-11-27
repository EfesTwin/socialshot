/*
-----------------------------------------------------------------------------
Class for Shots (Mixes)

- MyMix.arr_milliliters returns an Array of the milliliter values of the mix
- MyMix.arr_opentimes returns the opening times of the valves for this mix
- MyMix.PrintMix() prints the mix to a file and to the console
-----------------------------------------------------------------------------
*/

class FluidMix
{
  // Parameters
  float[] arr_milliliters;
  int[] arr_opentimes;
  int queueID;
  String fbID;
  float[] arr_percentages;
  
  // Constructor
  FluidMix (String userID, int itemID, float[] arr_values)
  {
    // Set ID Array
    fbID = userID;
    queueID = itemID;
    
    // Initialize Reference Value and output array
    float RefValue = 0;
    arr_percentages = new float[arr_traits.length];
    
    // Assign Reference Value
    for (int i = 0; i < arr_values.length; i++)
    {
      RefValue += arr_values[i];
    }
    
    // Get Percentages
    for (int i = 0; i < arr_values.length; i++)
    {
      arr_percentages[i] = (arr_values[i]/RefValue);
    }
    
    // Compute ML and add to milliliter array
    arr_milliliters = new float[arr_traits.length];
    for (int i = 0; i < arr_percentages.length; i++)
    {
      arr_milliliters[i] = arr_percentages[i]*FLUID_SIZE;
    }
    
    // Compute Opening Times
    arr_opentimes = new int[arr_traits.length];
    for (int i = 0; i < arr_traits.length; i++)
    {
      float opening_value_init = arr_milliliters[i]*arr_openfactors[i];
      int opening_value = int(opening_value_init);
      arr_opentimes[i] = opening_value;
    }
  }
  
  // Print the Mix
  void PrintMix() 
  { 
    OUTPUT_FILE = createWriter("data/mixes/social_shot_" + OUTPUT_FILENUMBER + ".txt");
    println("Facebook ID:" + fbID);
    // println("Queue ID:" +  queueID);
    println(" ");
    OUTPUT_FILE.println(" ");
    OUTPUT_FILE.println(PRINTFILE_SPACER + "THE SOCIAL SHOT");
    OUTPUT_FILE.println(" ");
    OUTPUT_FILE.println(PRINTFILE_SPACER + SEPERATOR);
    OUTPUT_FILE.println(" ");
    OUTPUT_FILE.println(PRINTFILE_SPACER + "Facebook ID:" + fbID);
    OUTPUT_FILE.println(PRINTFILE_SPACER + SEPERATOR);
    for (int i = 0; i < arr_real_traits.length; i++)
    {
      String progress = "";
      int processChars = ceil(arr_percentages[i] * 45.0);
      for (int j = 0; j < processChars; j++)  
      {
        progress += "|";
      }
      
      // Save File with running Filenumber
      println(arr_real_traits[i] + " / " + arr_fluids[i] + ": " + (arr_percentages[i] * 100) + " %");
      OUTPUT_FILE.println(" ");
      OUTPUT_FILE.println(PRINTFILE_SPACER + arr_real_traits[i] + " / " + arr_fluids[i] + ": " + (arr_percentages[i] * 100) + " %");
      OUTPUT_FILE.println(PRINTFILE_SPACER + progress);
      
    }
    OUTPUT_FILE.flush();
    OUTPUT_FILE.close();
  }
}

/* 
-----------------------------------------------------------------------------
This Function takes an instance of FluixMix
First, the opentime will be extracted,
Each Value is sent to the Arduino, then the function waits for an Arduino 
Exitcode response (handshake).
If the handshake is given back, the next iteration will occurr.
-----------------------------------------------------------------------------
*/

void SendSerialValveData(FluidMix mix)
{
  for (int i = 0; i < mix.arr_opentimes.length; i++)
  {
    // Wait the amount of execdelay before sending to serial port
    timer = millis();
    while (millis()-timer < execdelay)
    {
      //pass
    }
    
    // Print Execution Info
    println("Sending Valve Data for Valve " + (arr_valveorder[i]));
    println("Open time in ms: " + mix.arr_opentimes[i]);
    // Convert opentime to string
    String str_opentime = str(mix.arr_opentimes[i]);
    // Get Valve Number and send to Arduino
    int valve_number = arr_serial[arr_valveorder[i]];
    ArduinoPort.write(valve_number);
    // Loop through every character of string
    for (int c = 0; c < str_opentime.length(); c++)
    {
      // Convert character to int
      int serial_opentime = int(str_opentime.charAt(c));
      // Write Serial Value to Arduino
      ArduinoPort.write(serial_opentime);
    }
    // Write Enter to the Arduino
    ArduinoPort.write(10);
    
    // Wait for Handshake
    while(serialEventComplete == false)
    {
      serialEvent();
    }
    if(valveString.equals("9"))
    {
      println("Got End handshake. Nice!");
      println(" ");
      valveString = "";
      serialEventComplete = false;
    }
  }
  
  int mixID = mix.queueID;
  // Compose "I am finished" URL and visit it
  String HandshakeURL = FinishedURL + mixID;
  println(loadStrings(HandshakeURL));
   
  println(SEPERATOR);
}
