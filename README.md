# relief_print

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
