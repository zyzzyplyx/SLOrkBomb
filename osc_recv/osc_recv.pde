import oscP5.*;

OscP5 osc;
int a, b, c;

void setup() {
  size(640, 480);
  background(140,21,21);
  osc = new OscP5(this, 12345);
}

void draw() {
  if (mousePressed) {
    background(255,255,255);
  } else {
    background(a, b, c);
  }
  
}

void oscEvent(OscMessage oe) {
  a = oe.get(0).intValue();  
  b = oe.get(1).intValue(); 
  c = oe.get(2).intValue(); 
  print("RGB: "+a+" "+b+" "+c+"\n");
  background(a, b, c);
}
