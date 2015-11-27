// SHOT SIZE IN MILLILITERS
float FLUID_SIZE = 20.0;

String QueueURL = "http://fbbot.joernroeder.de/";
String FinishedURL = "http://fbbot.joernroeder.de/update/";

// DATA ARRAYS
String[] arr_fluids = { "Grenadine", "Zitronensaft", "Blue Curacao", "Basilikumlikör", "Vodka" };
String[] arr_traits = { "Neuroticism", "Extraversion", "Openness", "Agreeableness", "Conscientiousness" };
String[] arr_real_traits = { "Emotionalität", "Geselligkeit", "Offenheit", "Verträglichkeit", "Zuverlässigkeit" };

// Open Factors for different Parts of the drink, Order in which the Valves will Open
float[] arr_openfactors = { 3060.0, 3120.0, 2400.0, 3660.0, 3330.0 };
int[] arr_valveorder = { 3, 4, 2, 1, 5 };

// SEPERATOR STRING FOR PRINTING
String SEPERATOR = "---------------------------";
String PRINTFILE_SPACER = "                ";

// Serial Linefeed Buffer
int lf = 1;

// OUTPUT PRINT FILE
PrintWriter OUTPUT_FILE;
int OUTPUT_FILENUMBER = 0;

// TIMING AND EXECUTION
int timer = 0;

// Time to wait before sending serial data
int execdelay = 3000;

// Button Event Boolean
boolean eventIsRunning = false;

// execution Boolean
boolean execJson = false;

// SerialEvent Boolean
boolean serialEventComplete = false;

// Serial Event input String
String valveString = "";
