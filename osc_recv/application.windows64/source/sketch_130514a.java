import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sketch_130514a extends PApplet {



OscP5 osc;
int a, b, c;

public void setup() {
  size(1920, 1080);
  background(140,21,21);
  osc = new OscP5(this, 33333);
}

public void draw() {
  if (mousePressed) {
    background(255,255,255);
  } else {
    background(a, b, c);
  }
  
}

public void oscEvent(OscMessage oe) {
  a = oe.get(0).intValue();  
  b = oe.get(1).intValue(); 
  c = oe.get(2).intValue(); 
  print("RGB: "+a+" "+b+" "+c+"\n");
  background(a, b, c);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "sketch_130514a" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
