package processing.test.tablet_pattern_player;

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

int appPaddingWidth = 150;
int appPaddingHeight = 200;

// pattern preview buffer
int patternPreviewHeight = 200;
int patternPreviewWidth = 1200;
int patternPreviewX = appPaddingWidth;
int patternPreviewY = appPaddingHeight;

// send pattern to set buttons
int patternSendWidth = 440;
int patternSendHeight = 160;
int patternSend1X = 1440;
int patternSend1Y = 530;
int patternSend2X = 1920;
int patternSend2Y = 530;

// pattern preview button grid
int numPatternButtonRows = 3;
int numPatternButtonCols = 6;
int numPatternButtons = numPatternButtonCols * numPatternButtonRows;
Button[] patternButtons = new Button[numPatternButtons];
int buttonGridYoffset = appPaddingHeight + patternPreviewHeight;
int buttonGridXoffset = appPaddingWidth + patternPreviewX;
int patternButtonWidth = 400;
int patternButtonHeight = 160;
int ui_xposMultiplier = patternButtonWidth;
int ui_yposMultiplier = patternButtonHeight;

// mode button area (color picker to pattern preview & back)
int colorPickerModeWidth = 1200;
int colorPickerModeHeight = 120;
int colorPickerModeX = appPaddingWidth;
int colorPickerModeY = appPaddingHeight + patternPreviewHeight + (numPatternButtonCols * patternButtonHeight);

int patternPreviewModeWidth = 1200;
int patternPreviewModeHeight = 120;
int patternPreviewModeX = appPaddingWidth;
int patternPreviewModeY = appPaddingHeight + patternPreviewHeight + (numPatternButtonCols * patternButtonHeight);

int sliderValue = 100;
int globalBright=100;

int[][] patternButton_xyPos = new int[numPatternButtons][2];  // pattern button draw positions, array of [x,y]

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


String pathBase = pathBase1; // set start pattern to "all off"
int numFrames = duration1;
PImage previewMovie;



DeviceRegistry registry;
PusherObserver observer;
PGraphics patternPreviewBuffer;

int numPanels = 3;
int stride = 167; // number of LEDs per row aka striplength
int panelDisplayHeight = 24;
float xscale = 1; // horizontal scale factor
int combinedPanelDisplayWidth = numPanels * stride;
// define each set by group start and group end indexes
int[][] panelSets = {{1,4},{5,6}};
// this order array will be indexed by the limits in the sets variable,
// the values represent the order that the controller groups are scraped to
int[][] order = {{1,1}, {2,2}, {3,3}, {4,4}, {5,5}, {6,6}};

PImage bg;
PImage errorScreen;


public void setup() {


 
  patternPreviewBuffer = createGraphics(combinedPanelDisplayWidth, panelDisplayHeight, JAVA2D); // buffer with the same number of pixels as the wall

  println ("starting");
  // bg = loadImage("UI_Background.jpg");

  stroke(255);
  noFill();
  strokeWeight(4); 
  PFont p = createFont("Gotham-Medium.otf", 40);
  cp5 = new ControlP5(this); // 
  cp5.setControlFont(p);
  cp5.setAutoDraw(false);
    
  
   cp5.addSlider("bright")
     .setCaptionLabel("Brightness")
     .setRange(0,100)
     .setValue(100)
     .setPosition(100,1650)
     .setSize(850,patternButtonHeight)
     .setNumberOfTickMarks(20)
     .snapToTickMarks(true)
     .setDecimalPrecision(0) 
     ;
     
  // reposition the Label for controller 'slider'
  cp5.getController("bright").getValueLabel().align(ControlP5.RIGHT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("bright").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);



  frameRate(15);

  // calculate pattern button positions
  for(int j=0; j< numPatternButtonRows; j++) {
    for (int i=0; i < numPatternButtonCols; i++) {
      patternButton_xyPos[i][0] = buttonGridXoffset + (ui_xposMultiplier * j);
      patternButton_xyPos[i][1] = -1*(buttonGridYoffset + (ui_yposMultiplier * i));
      println("x:"+patternButton_xyPos[i][0]+" y:"+patternButton_xyPos[i][1]);
    }
  }
  
  for(int b=0; b<numPatternButtons; b++) {
    String label = "Pattern #" + (b+1);
    patternButtons[b] = cp5.addButton("seq" + (b+1))
      .setCaptionLabel(label)
      .setValue(0)
      .setPosition(patternButton_xyPos[b][0], patternButton_xyPos[b][1])
      .setSize(patternButtonWidth, patternButtonHeight);
  }



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
  // pushMatrix();
  // translate(0,patternButton_xyPos[whichMovie-1][1]);
  // rect (100,0,patternButtonWidth,patternButtonHeight); // selection state for the buttons
  // popMatrix();
 
  
  switch(whichMovie){ // sets the path and duration of the PNG sequence based on the button selection
    
    case 1:
      pathBase = pathBase1;
      numFrames = duration1;
      buttonYpos = 350+buttonGridYoffset;
      break;
    
    case 2:
      pathBase = pathBase2;
      numFrames = duration2;
      buttonYpos = 450+buttonGridYoffset;
      break;
    
    case 3:
      pathBase = pathBase3;
      numFrames = duration3;
      buttonYpos = 550+buttonGridYoffset;
      break;     
      
    
    case 4:
      pathBase = pathBase4;
      numFrames = duration4;
      buttonYpos = 650+buttonGridYoffset;
      break;   
    
    case 5:
      pathBase = pathBase5;
      numFrames = duration5;
      buttonYpos = 750+buttonGridYoffset;
      break;   
    
    case 6:
      pathBase = pathBase6;
      numFrames = duration6;
      buttonYpos = 850+buttonGridYoffset;
      break;  
    
    case 7:
      pathBase = pathBase7;
      numFrames = duration7;
      buttonYpos = 950+buttonGridYoffset;
      break;  
    
    case 8:
      pathBase = pathBase8;
      numFrames = duration8;
      buttonYpos = 1050+buttonGridYoffset;
      break;  
    
    case 9:
      pathBase = pathBase9;
      numFrames = duration9;
      buttonYpos = 1150+buttonGridYoffset;
      break;  
    
  }
  
  currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames and loop
  String imageName = "sequences/" + pathBase + "/pixelData" + nf(currentFrame, 5) + ".jpg";
  previewMovie = loadImage(imageName);
  image (previewMovie,200,150,1200,200);
    
  
  patternPreviewBuffer.beginDraw();
  patternPreviewBuffer.image(previewMovie, 0, 0,501,24);

  // if (noStrips) {image(errorScreen, 000, 0,800,1280);} // display error if there are no stripsn detected
  //scrape(); // scrape the offscreen buffer 

}





// UI selections
public void controlEvent(ControlEvent theEvent) {

  println(theEvent.getController().getName());
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

public void seq12(int theValue) {

  whichMovie = 13;
  currentFrame = 0;

}

public void seq13(int theValue) {

  whichMovie = 14;
  currentFrame = 0;

}

public void seq14(int theValue) {

  whichMovie = 15;
  currentFrame = 0;

}


public void seq15(int theValue) {

  whichMovie = 16;
  currentFrame = 0;

}

public void seq16(int theValue) {

  whichMovie = 17;
  currentFrame = 0;

}

public void seq17(int theValue) {

  whichMovie = 18;
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
  patternPreviewBuffer.loadPixels();
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
            int c = patternPreviewBuffer.get((int) xpos, (int)ypos);
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

  public int sketchWidth() { return 2560; }
  public int sketchHeight() { return 1600; }
}
