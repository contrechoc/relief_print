String[] lines;
String[][] layers = new String [200][90000];
int index = 0;
String allLines;

String stlName = "charlie_top-29_layers_hilbert";
String fileName = stlName + ".gcode";

int patternlayer = 5;

int extraLayer = 28;

void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(12);

  int ssCounter = 0;
  int linesC = 0;

  lines = loadStrings(fileName);
  //println(lines);

  for (int i = 1; i < lines.length; i++) {
    if ( (lines[i].indexOf("Z")<0) && (lines[i].indexOf("M84")<0) )
    {
      //println("\n"+ lines[i-1]);
      layers[ssCounter][linesC++] = lines[i-1];
    }
    else
    {
      layers[ssCounter][linesC] = "G92 E0 ; ------------------!!!";
      int endLine = linesC+1;
      if (ssCounter==0) {
        layers[ssCounter][linesC+1] = "G28 ; home all axes";
        endLine++;
      }
      String[] outputGcode = new String [endLine];
      for (int j = 0; j < endLine; j++) {
        outputGcode[j] = layers[ssCounter][j];
      }

      saveStrings(stlName + "_layer"+str(ssCounter)+".txt", outputGcode);
      ssCounter++;
      linesC = 0;
      println( " split layer");
    }
  }
  println( ssCounter + " layers splitted");

  //load separate lines and merge first layer

  String[] layer1;
  String[] layer2;
  String[] layer3;
   String[] layer4;
   String[] layer10;

  layer1 = loadStrings(stlName + "_layer"+str(0)+".txt");
  layer2 = loadStrings(stlName + "_layer"+str(1)+".txt");
  layer3 = loadStrings(stlName + "_layer"+str(2)+".txt");
  
   layer4 = loadStrings(stlName + "_layer"+str(patternlayer)+".txt");
   
  layer10 = loadStrings(stlName + "_layer"+str(extraLayer)+".txt");

  int total_lines = layer1.length + layer2.length + layer3.length+ layer10.length ;

  String[] outputGcodeL = new String [total_lines + 2];
  for (int j = 0; j < layer1.length; j++) {
    outputGcodeL[j] = layer1[j];
  }
  for (int j = 0; j < layer2.length; j++) {
    outputGcodeL[j+ layer1.length] = layer2[j];
  }
  
  //bottom layer
  for (int j = 0; j < layer3.length; j++) {
    outputGcodeL[j+ layer1.length+ layer2.length] = layer3[j];
  }
  
  //patternlayer
    for (int j = 0; j < layer4.length; j++) {
    outputGcodeL[j+ layer1.length+ layer2.length+ layer3.length] = layer4[j];
  }
  
  //extra shape layer
  for (int j = 0; j < layer10.length; j++) {
    outputGcodeL[j+ layer1.length+ layer2.length+ layer3.length+ layer4.length] = layer10[j];
  }

  outputGcodeL[  layer1.length+ layer2.length+ layer3.length+ layer10.length] = "M104 S0 ; turn off temperature";
  outputGcodeL[  layer1.length+ layer2.length+ layer3.length+ layer10.length+1] = "G92 E0 ; ------------------!!!";
  
   saveStrings(stlName + "_total"+ ".txt", outputGcodeL);
}

void draw() 
{
}

