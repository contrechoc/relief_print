/*******************************************
 contrechoc 2015, copyright? Do what you like with this file!
 
 Processing sketh making single layers from a gcode file, splitting on z values.
 
 input: gcode file => see line: String stlName = "charlie_top-29_layers_hilbert";
 
 output 1: layers: charlie_top-29_layers_hilbert_layer18.txt
 output 2: recombined file with selected layers (not Z correct!): charlie_top-29_layers_hilbert_total.txt
 output 3: rocombined file with selected layers corrected on first layer height: charlie_top-29_layers_hilbert_total_Z_correct.txt
 
 part of a research about making relief prints with a 3D printer
 
 This method is applied to Gcode coming from Repetier, it might be a bit different in other gcode producing software
 
 
 This sketch is very much to redesign to your own needs...
 
 
 **********************************************/

String[] lines;
String[][] layers = new String [200][90000]; // if you have a bigger gcode file, this can be increased
int index = 0;
String allLines;

String stlName = "charlie_top-29_layers_hilbert";// indcate the name of the file, this file has to be present in the sketch folder
String fileName = stlName + ".gcode"; //gcode is presumed to be the format indicator

//second layer
int patternlayer = 5; // extra layer 1: you have checked this in the layer view of Repetier

// if extraLayer is left 0, then this layer is ignored
int extraLayer = 10; // extra layer 2: you have checked this in the layer view of Repetier

void setup() {
  //nothing graphical is done, this sjetch produces just text files
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(12);

  int ssCounter = 0;
  int linesC = 0;

  //gcode file is loaded
  lines = loadStrings(fileName);
  //println(lines);

  //lines of this gcode file are scanned for "Z", the header is ignored using "M84"
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
      //println( " split layer");
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
  int total_lines = 0;
  
  if ( extraLayer > 0 ) {
    layer10 = loadStrings(stlName + "_layer"+str(extraLayer)+".txt");
  }
  else
  {
    layer10 = new String [1];
  }
    total_lines = layer1.length + layer2.length + layer3.length+ layer4.length+ layer10.length ;
 

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

 if ( extraLayer > 0 ) {
  //extra shape layer
  for (int j = 0; j < layer10.length; j++) {
    outputGcodeL[j+ layer1.length+ layer2.length+ layer3.length+ layer4.length] = layer10[j];
  }
 }

  //adding the last lines to the gcode
  outputGcodeL[  layer1.length+ layer2.length+ layer3.length+ layer10.length] = "M104 S0 ; turn off temperature";
  outputGcodeL[  layer1.length+ layer2.length+ layer3.length+ layer10.length+1] = "G92 E0 ; ------------------!!!";

  saveStrings(stlName + "_total"+ ".txt", outputGcodeL);

  // -----------------------------------------------------------------------------------------------------------------------
  //second part
  //check Z values and set right layer heights

  lines = loadStrings(stlName + "_total"+ ".txt"); //load total output file again
  int lineCounter = 0;
  float layerHeight = 0;
  for (int i = 1; i < lines.length; i++) {
    if ( (lines[i].indexOf("Z")>0) && (lines[i].indexOf("M84")<0) && (lines[i].indexOf("F5")<0))
    {
      //if a line is found containing "Z" make a split
      String[] parts = lines[i].split("Z");
      String part1 = parts[0];
      String part2 = parts[1];
      String part3 = "";
      //if this is the first height indication (ground layer) take the Z value as the layer height
      if ( lineCounter == 0 ) {
        String layerHeightStr = part2.substring(0, 5);
        layerHeight = float(layerHeightStr);
        println( layerHeight );
      }
      //in subsequent layers take the layerheight multiplied by the layer counter
      if ( lineCounter > 0 ) {
        part3 = str( (lineCounter+1) *layerHeight ) + " " + part2.substring(6, part2.length() );
        lines[i] = part1 + " Z" + part3;
        println( lines[i] );
      }
      // reconstruct the line with the right layer height
      println(lines[i] + " " + part1 + " " + part2 + " " + part3);
      lineCounter++;
    }
  }
  //save the text file with the right layer heights
  saveStrings(stlName + "_total_Z_correct"+ ".txt", lines);
}

void draw() 
{
}
