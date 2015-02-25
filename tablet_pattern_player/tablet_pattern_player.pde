import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import com.heroicrobot.dropbit.devices.pixelpusher.PixelPusher;
import com.heroicrobot.dropbit.devices.pixelpusher.PusherCommand;
import java.util.*;
import controlP5.*;
ControlP5 cp5;

int appPaddingWidth = 200;
int appPaddingHeight = 150;

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
int buttonGridY = appPaddingHeight + patternPreviewHeight;
int buttonGridX = appPaddingWidth;
int patternButtonWidth = 400;
int patternButtonHeight = 160;
int buttonGridPaddingRightWidth = 40;
int buttonGridWidth = (numPatternButtonRows * patternButtonWidth);
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

int logoX = appPaddingWidth + buttonGridWidth + buttonGridPaddingRightWidth;
int logoY = appPaddingHeight;

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
PImage logo;
PImage errorScreen;


void setup() {

  size(2560, 1600);
  patternPreviewBuffer = createGraphics(combinedPanelDisplayWidth, panelDisplayHeight, JAVA2D); // buffer with the same number of pixels as the wall

  bg = loadImage("skyflares_bg.png");
  logo = loadImage("salesforce_logo.png");
  stroke(255);
  noFill();
  strokeWeight(4); 
  PFont p = createFont("Gotham-Medium.otf", 36);
  cp5 = new ControlP5(this); // 
  cp5.setControlFont(p);
  cp5.setAutoDraw(false);
    
  
   cp5.addSlider("bright")
     .setCaptionLabel("Brightness")
     .setRange(0,100)
     .setValue(100)
     .setPosition(100, 400)
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
      int idx = (i+(j*numPatternButtonCols));
      patternButton_xyPos[idx][0] = buttonGridX + (ui_xposMultiplier * j);
      patternButton_xyPos[idx][1] = (buttonGridY + (ui_yposMultiplier * i));
      //println((idx) + " - x:"+patternButton_xyPos[idx][0]+" y:"+patternButton_xyPos[idx][1]);
    }
  }
  
  for(int b=0; b<numPatternButtons; b++) {
    String label = "Pattern #" + (b+1);
    patternButtons[b] = cp5.addButton("seq" + (b+1))
      .setCaptionLabel(label)
      .setValueLabel(label)
      .setStringValue(label)
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


void draw() {
  background(bg);
  image(logo, logoX, logoY);
  cp5.draw();
  pushMatrix();
  translate(patternButton_xyPos[whichMovie-1][0], patternButton_xyPos[whichMovie-1][1]);
  rect (0,0,patternButtonWidth,patternButtonHeight); // selection state for the buttons
  popMatrix();
 
  
  switch(whichMovie){ // sets the path and duration of the PNG sequence based on the button selection
    
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
  println("clicked controller: " + controllerName);
  println("clicked controller: " + controllerName.substring(0,3));
  int patternNum = 0;
  if(controllerName.substring(0, 3).equals("seq")) {
    whichMovie = Integer.parseInt(controllerName.substring(3));
    currentFrame = 0;
    println("chose movie #" + whichMovie);
  }
}

 

void spamCommand(PixelPusher p, PusherCommand pc) {
   for (int i=0; i<3; i++) {
    p.sendCommand(pc);
  }
}


void bright(float globalBright) { // takes a brightness value between 0 - 100 
  
  float newBright = map (globalBright,0,100,0,65535);
  
   List<PixelPusher> pushers = registry.getPushers();
  
    for (PixelPusher p: pushers) {
       PusherCommand pc = new PusherCommand(PusherCommand.GLOBALBRIGHTNESS_SET,(short) (newBright));
       spamCommand(p,  pc);
    } 
   
 // println ("brightness = " + newBright);
}




