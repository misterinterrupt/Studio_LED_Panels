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









ControlP5 cp5;

int appPaddingWidth = 200;
int appPaddingHeight = 150;

// pattern preview buffer
int patternPreviewHeight = 200;
int patternPreviewWidth = 1200;
int patternPreviewX = appPaddingWidth;
int patternPreviewY = appPaddingHeight;


// pattern preview button grid
int numPatternButtonRows = 6;
int numPatternButtonCols = 3;
int numPatternButtons = numPatternButtonCols * numPatternButtonRows;
Button[] patternButtons = new Button[numPatternButtons];
int buttonGridY = appPaddingHeight + patternPreviewHeight;
int buttonGridX = appPaddingWidth;
int patternButtonWidth = 400;
int patternButtonHeight = 160;
int buttonGridPaddingRightWidth = 40;
int buttonGridWidth = (numPatternButtonCols * patternButtonWidth);
int ui_xposMultiplier = patternButtonWidth;
int ui_yposMultiplier = patternButtonHeight;

// mode button area (color picker to pattern preview & back)
Button colorPickerModeButton;
int colorPickerModeWidth = 1200;
int colorPickerModeHeight = 120;
int colorPickerModeX = appPaddingWidth;
int colorPickerModeY = appPaddingHeight + patternPreviewHeight + (numPatternButtonRows * patternButtonHeight);
String colorPickerModeLabel = "Color Picker";

int patternPreviewModeWidth = 1200;
int patternPreviewModeHeight = 120;
int patternPreviewModeX = appPaddingWidth;
int patternPreviewModeY = appPaddingHeight + patternPreviewHeight + (numPatternButtonRows * patternButtonHeight);

// logo & underlay
int logoX = appPaddingWidth + buttonGridWidth + buttonGridPaddingRightWidth;
int logoY = appPaddingHeight;
int logoFrameX = logoX;
int logoFrameY = logoY;
int logoFrameWidth = 920;
int logoFrameHeight = 341;

// send pattern to set buttons
Button sendPatternSet1;
Button sendPatternSet2;
String set1Label = "Set #1";
String set2Label = "Set #2";
int sendPatternSetWidth = 440;
int sendPatternSetHeight = 160;
int setPaddingInner = 40;
int setMarginTop = 40;
int sendPatternSet1X = 1440;
int sendPatternSet1Y = 530;
int sendPatternSet2X = 1920;
int sendPatternSet2Y = 530;

// brightness sliders
Slider bright1;
Slider bright2;
int bright1X = sendPatternSet1X;
int bright1Y = sendPatternSet1Y + sendPatternSetHeight + setMarginTop;
int bright2X = sendPatternSet2X;
int bright2Y = bright1Y;
int sliderValue = 100;
int globalBright=100;

int[][] patternButton_xyPos = new int[numPatternButtons][2];  // pattern button draw positions, array of [x,y]

boolean noStrips = true;
int chosenMovie=1;
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
PImage logo;
PImage errorScreen;


public void setup() {

 
  frameRate(15);
  patternPreviewBuffer = createGraphics(combinedPanelDisplayWidth, panelDisplayHeight, JAVA2D); // buffer with the same number of pixels as the wall

  bg = loadImage("skyflares_bg.png");
  logo = loadImage("salesforce_logo.png");
  stroke(255);
  noFill();
  strokeWeight(1); 
  PFont p = createFont("Gotham-Medium.otf", 30);
  cp5 = new ControlP5(this);
  cp5.setControlFont(p);
  cp5.setAutoDraw(false);
    
  // create colorpicker mode button
  colorPickerModeButton = cp5.addButton("colorPickerMode")
    .setCaptionLabel(colorPickerModeLabel)
    .setValueLabel(colorPickerModeLabel)
    .setValue(0)
    .setPosition(colorPickerModeX, colorPickerModeY)
    .setSize(colorPickerModeWidth, colorPickerModeHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorCaptionLabel(color(17, 84, 130, 255))
    ;

  // reposition the Label for controller 'colorpickermode'
  cp5.getController("colorPickerMode").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("colorPickerMode").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  
  bright1 = cp5.addSlider("bright1")
    .setRange(0,100)
    .setValue(100)
    .setPosition(bright1X, bright1Y)
    .setSize(sendPatternSetWidth, 850)
    .setNumberOfTickMarks(50)
    .snapToTickMarks(true)
    .setDecimalPrecision(0)
    ;
     
  // reposition the Label for controller 'slider'
  cp5.getController("bright1").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("bright1").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  bright2 = cp5.addSlider("bright2")
    .setRange(0,100)
    .setValue(100)
    .setPosition(bright2X, bright2Y)
    .setSize(sendPatternSetWidth, 850)
    .setNumberOfTickMarks(50)
    .snapToTickMarks(true)
    .setDecimalPrecision(0) 
    ;
     
  // reposition the Label for controller 'slider'
  cp5.getController("bright2").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("bright2").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  // create send to pattern 1 button
  sendPatternSet1 = cp5.addButton("set1")
    .setCaptionLabel(set1Label)
    .setValueLabel(set1Label)
    .setValue(0)
    .setPosition(sendPatternSet1X, sendPatternSet1Y)
    .setSize(sendPatternSetWidth, sendPatternSetHeight)
    ;

  // reposition the Label for controller 'set1'
  cp5.getController("set1").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("set1").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  // create send to pattern 2 button
  sendPatternSet1 = cp5.addButton("set2")
    .setCaptionLabel(set2Label)
    .setValueLabel(set2Label)
    .setValue(0)
    .setPosition(sendPatternSet2X, sendPatternSet2Y)
    .setSize(sendPatternSetWidth, sendPatternSetHeight)
    ;

  // reposition the Label for controller 'set2'
  cp5.getController("set2").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("set2").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);


  // calculate pattern button positions
  for(int j=0; j < numPatternButtonCols; j++) { // X
    for (int i=0; i < numPatternButtonRows; i++) { // Y
      int idx = (i+(j*numPatternButtonRows));
      patternButton_xyPos[idx][0] = (buttonGridX + (ui_xposMultiplier * j));
      patternButton_xyPos[idx][1] = (buttonGridY + (ui_yposMultiplier * i));
      //println((idx) + " - x:"+patternButton_xyPos[idx][0]+" y:"+patternButton_xyPos[idx][1]);
    }
  }

  // create & draw the button grid butrons
  for(int b=0; b<numPatternButtons; b++) {
    String label = "Pattern #" + (b+1);
    String name = "seq" + (b+1);
    patternButtons[b] = cp5.addButton(name)
      .setCaptionLabel(label)
      .setValueLabel(label)
      .setStringValue(name)
      .setValue(0)
      .setSwitch(true)
      .setPosition(patternButton_xyPos[b][0], patternButton_xyPos[b][1])
      .setSize(patternButtonWidth, patternButtonHeight)
      .setColorCaptionLabel(color(17, 84, 130, 255))
      .setColorActive(color(255,255,255,150))
      .setColorBackground(color(255,255,255,40))
      ;
      // reposition the Label for controllers named 'seq'+(b+1)
      cp5.getController(name).getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
      cp5.getController(name).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  }

  chosenMovie=1; //default
  registry = new DeviceRegistry();
  observer = new PusherObserver();
  registry.addObserver(observer);
  registry.setAntiLog(true);
  registry.setAutoThrottle(true);
  
}


public void draw() {
  background(bg);
  image(logo, logoX, logoY);
  cp5.draw();
  // draw selected state
  pushMatrix();
    translate(patternButton_xyPos[chosenMovie-1][0], patternButton_xyPos[chosenMovie-1][1]);
    rect (0, 0, patternButtonWidth,patternButtonHeight); // selection state for the buttons
  popMatrix();
  // draw logo frame
  pushMatrix();
    translate(logoFrameX, logoFrameY);
    noStroke();
    fill(255, 255, 255, 25);
    rect(0, 0, logoFrameWidth, logoFrameHeight);
  popMatrix();

  // draw grid lines
  pushMatrix();
    noFill();
    stroke(0, 0, 0, 25);
    translate(buttonGridX, buttonGridY);
    // vertical lines
    for(int j=0; j<numPatternButtonCols; j++) {
      if((j > 0) && (j < numPatternButtonCols)) {
        line(patternButtonWidth*j, 0, patternButtonWidth*j, numPatternButtonRows * patternButtonHeight);
      }
    }
    // horizontal lines
    for(int k=0; k<numPatternButtonRows; k++) {
      if((k > 0) && (k < numPatternButtonRows)) {
        line(0, patternButtonHeight*k, numPatternButtonCols * patternButtonWidth, patternButtonHeight*k);
      }
    }
  popMatrix();
  
  
  switch(chosenMovie){ // sets the path and duration of the PNG sequence based on the button selection
    
    case 1:
      pathBase = pathBase1;
      numFrames = duration1;
      break;
    
    case 2:
      pathBase = pathBase2;
      numFrames = duration2;
      break;
    
    case 3:
      pathBase = pathBase3;
      numFrames = duration3;
      break;     
      
    
    case 4:
      pathBase = pathBase4;
      numFrames = duration4;
      break;   
    
    case 5:
      pathBase = pathBase5;
      numFrames = duration5;
      break;   
    
    case 6:
      pathBase = pathBase6;
      numFrames = duration6;
      break;  
    
    case 7:
      pathBase = pathBase7;
      numFrames = duration7;
      break;  
    
    case 8:
      pathBase = pathBase8;
      numFrames = duration8;
      break;  
    
    case 9:
      pathBase = pathBase9;
      numFrames = duration9;
      break;  
    
  }
  
  currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames and loop
  String imageName = "sequences/" + pathBase + "/pixelData" + nf(currentFrame, 5) + ".jpg";
  previewMovie = loadImage(imageName);
  image (previewMovie,200,150,1200,200);
    
  
  patternPreviewBuffer.beginDraw();
  patternPreviewBuffer.image(previewMovie, 0, 0,501,24);

  // if (noStrips) {image(errorScreen, 000, 0,800,1280);} // display error if there are no strips detected
  //scrape(); // scrape the offscreen buffer 

}

// UI selections
public void controlEvent(ControlEvent theEvent) {

  String controllerName = theEvent.getController().getName();
  //println("clicked controller: " + controllerName);
  if(controllerName.substring(0, 3).equals("seq")) {
    onPreviewButtonPress(theEvent, controllerName);
  }
}

public void onPreviewButtonPress(ControlEvent buttonEvent, String controllerName) {

  // for(int i=0; i<patternButtons.length; i++) {
    
  //   if(patternButtons[i].isOn()) {
    
  //     patternButtons[i].setOff();
  //     println("setting off.. " + patternButtons[i].getStringValue());
  //   }
  //   if(patternButtons[i].getStringValue() == controllerName) {
    
  //     println("pressed " + controllerName);
  //     patternButtons[i].setOn();
  //   }
  // }
  int patternNum = Integer.parseInt(buttonEvent.getController().getName().substring(3));
  chosenMovie = patternNum;
  currentFrame = 0;
  //println("chose movie #" + chosenMovie);
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
