import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import com.heroicrobot.dropbit.registry.*; 
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel; 
import com.heroicrobot.dropbit.devices.pixelpusher.Strip; 
import com.heroicrobot.dropbit.devices.pixelpusher.PixelPusher; 
import com.heroicrobot.dropbit.devices.pixelpusher.PusherCommand; 
import java.util.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class tablet_pattern_player extends PApplet {

boolean debug = true;








ControlP5 cp5;

Button offButton;
Button myButton1;
Button myButton2;
Button myButton3;
Button myButton4;
Button myButton5;
Button myButton6;
Button myButton7;
Button myButton8;
Button myButton9;
Button myButton10;
Button myButton11;


int Yoffset = 100;//620; // this helps me quickly modify the position of the buttons 
int ui_xpos = 100;
int ui_yMultiplier = 100;
int buttonSizeX=500;
int buttonSizeY=60;

int sliderValue = 100;

int globalBright=100;

int[] UI_yPos = new int [12];  // an array to hold the position of buttons.


boolean noStrips = true;
int buttonYpos = 0;



int whichMovie=1;

int currentFrame = 0;

// setup file path a durations for the image sequences
String pathBase1 = "blanks";
int duration1 = 1;

String pathBase2 = "seq1";
int duration2 = 1680;

String pathBase3 = "seq2";
int duration3 = 1800;
    
String pathBase4 = "seq3";
int duration4 = 1800;
   
String pathBase5 = "seq4";
int duration5 = 1800;
   
String pathBase6 = "seq5";
int duration6 = 1800;
   
String pathBase7 = "seq6";
int duration7 = 1799;
 
String pathBase8 = "seq7";
int duration8 = 454;

String pathBase9 = "seq8";
int duration9 = 150;


String pathBase = pathBase1; // set start patern to "all off"
int numFrames = duration1;
PImage mainMovie ;



DeviceRegistry registry;
PusherObserver observer;
PGraphics offScreenBuffer;

int numPanels = 3;
int stride = 167; // number of LEDs per row aka striplength
int panelDisplayHeight = 24;
float xscale = 1; // horizontal scale factor
int combinedPanelDisplayWidth = numPanels * stride;
// define each set by group start and group end indexes
int[][] sets = {{1,4},{5,6}};

PImage bg;
PImage errorScreen;

public void setup() {


  size(1260, 1600);
  offScreenBuffer = createGraphics(combinedPanelDisplayWidth, panelDisplayHeight, JAVA2D); // buffer with the same number of pixels as the wall

  println ("starting");
  // bg = loadImage("UI_Background.jpg");

  stroke(255);
  noFill();
  strokeWeight(4); 
  PFont p = createFont("Verdana.ttf",40);
  cp5 = new ControlP5(this); // 
  cp5.setControlFont(p);
  cp5.setAutoDraw(false);
    
  
   cp5.addSlider("bright")
     .setCaptionLabel("Brightness")
     .setRange(0,100)
     .setValue(100)
     .setPosition(100,1650)
     .setSize(850,buttonSizeY)
     .setNumberOfTickMarks(20)
     .snapToTickMarks(true)
     .setDecimalPrecision(0) 
     ;
     
  // reposition the Label for controller 'slider'
  cp5.getController("bright").getValueLabel().align(ControlP5.RIGHT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("bright").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);



  frameRate(15);
  for (int i=0; i < 12; i++) {
    UI_yPos[i] = (ui_yMultiplier *i) +Yoffset;
  }
  
  offButton = cp5.addButton("offButton")
   
  .setCaptionLabel("No Lights")
  .setValue(0)
  .setPosition(ui_xpos,UI_yPos[0])
  .setSize(buttonSizeX,buttonSizeY);
 
 
 
    
 
  myButton1 = cp5.addButton("seq1")
   
  .setCaptionLabel("Light Sequence 1")
  .setValue(0)
  .setPosition(ui_xpos,UI_yPos[1])
  .setSize(buttonSizeX,buttonSizeY);
  
  myButton2 = cp5.addButton("seq2")
   
  .setCaptionLabel("Light Sequence 2")
  .setValue(0)
  .setPosition(ui_xpos,UI_yPos[2])
  .setSize(buttonSizeX,buttonSizeY);
   
  myButton3 = cp5.addButton("seq3")
   
  .setCaptionLabel("Light Sequence 3")
  .setValue(0)
  .setPosition(ui_xpos,UI_yPos[3])
  .setSize(buttonSizeX,buttonSizeY);
   
  myButton4 = cp5.addButton("seq4")
  .setCaptionLabel("Light Sequence 4")
  .setValue(0)
  .setPosition(ui_xpos,UI_yPos[4])
  .setSize(buttonSizeX,buttonSizeY);
   
   myButton5 = cp5.addButton("seq5")
  .setCaptionLabel("Light Sequence 5")
  .setValue(0)
  .setPosition(ui_xpos,UI_yPos[5])
  .setSize(buttonSizeX,buttonSizeY);
   
   
   
   myButton6 = cp5.addButton("seq6")
  .setCaptionLabel("Light Sequence 6")
  .setValue(0)
  .setPosition(ui_xpos,UI_yPos[6])
  .setSize(buttonSizeX,buttonSizeY);
   
   
   
   myButton7 = cp5.addButton("seq7")
  .setCaptionLabel("Light Sequence 7")
  .setValue(0)
  .setPosition(ui_xpos,UI_yPos[7])
  .setSize(buttonSizeX,buttonSizeY);
   
  myButton8 = cp5.addButton("seq8")
  .setCaptionLabel("Test Pattern")
  .setValue(0)
  .setPosition(ui_xpos,500) 
  .setSize(buttonSizeX,buttonSizeY);

  whichMovie=1; //default
    
 
  registry = new DeviceRegistry();
  observer = new PusherObserver();
  registry.addObserver(observer);
  registry.setAntiLog(true);
  registry.setAutoThrottle(true);
    
   
} 
   
 


public void draw() {
  // background(bg);
  cp5.draw();
  pushMatrix();
  translate(0,UI_yPos[whichMovie-1]);
  rect (100,0,buttonSizeX,buttonSizeY); // selection state for the buttons
  popMatrix();
 
  
  switch(whichMovie){ // sets the path and duration of the PNG sequence based on the button selection
    
    case 1:
      pathBase = pathBase1;
      numFrames = duration1;
      buttonYpos = 350+Yoffset;
      break;
    
    case 2:
      pathBase = pathBase2;
      numFrames = duration2;
      buttonYpos = 450+Yoffset;
      break;
    
    case 3:
      pathBase = pathBase3;
      numFrames = duration3;
      buttonYpos = 550+Yoffset;
      break;     
      
    
    case 4:
      pathBase = pathBase4;
      numFrames = duration4;
      buttonYpos = 650+Yoffset;
      break;   
    
    case 5:
      pathBase = pathBase5;
      numFrames = duration5;
      buttonYpos = 750+Yoffset;
      break;   
    
    case 6:
      pathBase = pathBase6;
      numFrames = duration6;
      buttonYpos = 850+Yoffset;
      break;  
    
    case 7:
      pathBase = pathBase7;
      numFrames = duration7;
      buttonYpos = 950+Yoffset;
      break;  
    
    case 8:
      pathBase = pathBase8;
      numFrames = duration8;
      buttonYpos = 1050+Yoffset;
      break;  
    
    case 9:
      pathBase = pathBase9;
      numFrames = duration9;
      buttonYpos = 1150+Yoffset;
      break;  
    
  }
  
  currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames and loop
  String imageName = "sequences/" + pathBase + "/pixelData" + nf(currentFrame, 5) + ".jpg";
  mainMovie = loadImage(imageName);
  if (debug) {image (mainMovie,0,0,1002,48);}
    
  
  offScreenBuffer.beginDraw();
  offScreenBuffer.image(mainMovie, 0, 0,501,24);

  // if (noStrips) {image(errorScreen, 000, 0,800,1280);} // display error if there are no stripsn detected
  scrape(); // scrape the offscreen buffer 

}





// UI selections
public void controlEvent(ControlEvent theEvent) {
  
 
}

public void offButton(int theValue) {

  whichMovie = 1;
  currentFrame = 0;

}


public void seq1(int theValue) {

  whichMovie = 2;
  currentFrame = 0;


}

public void seq2(int theValue) {

  whichMovie = 3;
  currentFrame = 0;
  
}



public void seq3(int theValue) {

  whichMovie = 4;
  currentFrame = 0;

}

public void seq4(int theValue) {

  whichMovie = 5;
  currentFrame = 0;

}

public void seq5(int theValue) {

  whichMovie = 6;
  currentFrame = 0;


}



public void seq6(int theValue) {

  whichMovie = 7;
  currentFrame = 0;

}

public void seq7(int theValue) {

  whichMovie = 8;
  currentFrame = 0;

}

public void seq8(int theValue) {

  whichMovie = 9;
  currentFrame = 0;

}


public void seq9(int theValue) {

  whichMovie = 10;
  currentFrame = 0;

}

public void seq10(int theValue) {

  whichMovie = 11;
  currentFrame = 0;

}

public void seq11(int theValue) {

  whichMovie = 12;
  currentFrame = 0;

}


 

public void spamCommand(PixelPusher p, PusherCommand pc) {
   for (int i=0; i<3; i++) {
    p.sendCommand(pc);
  }
}


public void bright(float globalBright) { // takes a brightness value between 0 - 100 
  
  float newBright = map (globalBright,0,100,0,65535);
  
   List<PixelPusher> pushers = registry.getPushers();
  
    for (PixelPusher p: pushers) {
       PusherCommand pc = new PusherCommand(PusherCommand.GLOBALBRIGHTNESS_SET,(short) (newBright));
       spamCommand(p,  pc);
    } 
   
 // println ("brightness = " + newBright);
}




class PusherObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    //println("Registry changed!");
    if (updatedDevice != null) {
      //println("Device change: " + updatedDevice);
    }
    this.hasStrips = true;
  }
};

public void scrape() {
  // scrape for the strips 501 x 24 (167 per panel)
  
  
  float xpos = 0, ypos = 0;
  offScreenBuffer.loadPixels();
  if (observer.hasStrips) {
    registry.startPushing();
    for(int panelIdx = 1; panelIdx < numPanels; panelIdx++) {

      List<Strip> strips = registry.getStrips(panelIdx);

      if (strips.size() > 0) {
        for (Strip strip : strips) {   // for each strip (y-direction)
          
          for (int stripx = 0; stripx < 334; stripx++) {  // loop through each pixel in the strip
          
            int xpixel = stripx % stride;
            int stridenumber = stripx / stride;             
            // zigzag code
            if ((stridenumber & 1) == 0) { // we are going left to right
              xpos = xpixel * xscale;
            } else { // we are going right to left
              xpos = ((stride - 1)-xpixel) * xscale;
            }
            // add 0-indexed multiplier of stride for xpos
            xpos = xpos + ((panelIdx - 1) * stride);
            //println ("Group" + panelIdx + " getting pixel from "+xpos + "," + ypos);
            int c = offScreenBuffer.get((int) xpos, (int)ypos);
            strip.setPixel(c, stripx);
            if (stripx == stride || stripx == 333) {
              ypos=ypos+1;
            } // move to the next yPos of the buffer
            
          } //end x loop
         
        } // for each strip
      } // strips.size() check for any strips

      // reset y scan
      ypos = 0;
    }
  } // observer
} // scrape
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "tablet_pattern_player" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
