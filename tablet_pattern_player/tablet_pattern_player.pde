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

// send pattern to set buttons and send 
Button sendPatternSet1;
Button sendPatternSet2;
String sendPattern1Label = "send";
String sendPattern2Label = "send";
int sendPatternSetLabelWidth = 440;
int sendPatternSetLabelHeight = 160;
int sendPatternSetWidth = 360;
int sendPatternSetHeight = 80;
int sendPaddingInner = 40;
int sendMarginTop = 40;
int sendPatternSet1LabelX = 1440;
int sendPatternSet1LabelY = 530;
int sendPatternSet2LabelX = 1920;
int sendPatternSet2LabelY = 530;
int sendPatternSet1X = sendPatternSet1LabelX + sendPaddingInner;
int sendPatternSet1Y = sendPatternSet1LabelY + sendPatternSetLabelHeight + 40;
int sendPatternSet2X = sendPatternSet2LabelX + sendPaddingInner;
int sendPatternSet2Y = sendPatternSet2LabelY + sendPatternSetLabelHeight + 40;

// brightness sliders
Slider bright1;
Slider bright2;
int sliderPaddingInner = 20;
int brightWidth = sendPatternSetWidth - (sliderPaddingInner*2);
int brightHeight = 560;
int bright1X = sendPatternSet1X + sliderPaddingInner;
int bright1Y = sendPatternSet1Y + sendPatternSetHeight + sendMarginTop;
int bright2X = sendPatternSet2X + sliderPaddingInner;
int bright2Y = bright1Y;
int brightHandlesSize = 35;
int sliderValue = 100;
int globalBright=100;

// send to set section components
int setLabelWidth = 440;
int setLabelHeight = 160;
int set1LabelX = logoFrameX;
int set1LabelY = logoFrameY + logoFrameHeight + sendMarginTop;
int set2LabelX = set1LabelX + setLabelWidth + sendMarginTop;
int set2LabelY = set1LabelY;
Button setLabel1;
Button setLabel2;



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
PGraphics set1Buffer;
PGraphics set2Buffer;

int numPanelsSet1 = 3;
int numPanelsSet2 = 3;
int stride = 167; // number of LEDs per row aka striplength
int panelDisplayHeight = 24;
float xscale = 1; // horizontal scale factor
int combinedPanelDisplayWidth = (numPanelsSet1 + numPanelsSet2) * stride;
int set1DisplayWidth = numPanelsSet1 * stride;
int set2DisplayWidth = numPanelsSet2 * stride;

// sets must be in numerical order
// define each pixel pusher powered panel set by group start and group end indexes
int[][] panelSets = {{1,4},{5,6}};
int[][] panelSetBuffers = {set1Buffer, set2Buffer};

// this is unused, just leaving it here for the future
// this order array will be indexed by the limits in the sets variable,
// the values represent the order that the controller groups are scraped to
//int[][] order = {{1,1}, {2,2}, {3,3}, {4,4}, {5,5}, {6,6}};

PImage bg;
PImage logo;
PImage errorScreen;


void setup() {

  size(2560, 1600);
  frameRate(15);

  patternPreviewBuffer = createGraphics(combinedPanelDisplayWidth, panelDisplayHeight, JAVA2D); // buffer with the same number of pixels as the wall
  set1Buffer = createGraphics(combinedPanelDisplayWidth, panelDisplayHeight, JAVA2D);
  set2Buffer = createGraphics(combinedPanelDisplayWidth, panelDisplayHeight, JAVA2D);

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
    .setLabelVisible(false)
    .setPosition(bright1X, bright1Y)
    .setSize(brightWidth, brightHeight)
    .setHandleSize(brightHandlesSize)
    .setColorActive(color(255,255,255,150))
    .setColorForeground(color(255,255,255,150))
    .setColorBackground(color(255,255,255,0))
    .setDecimalPrecision(0)
    .setSliderMode(controlP5.Slider.FLEXIBLE)
    ;
  // reposition the Label for controller 'bright1'
  cp5.getController("bright1").getValueLabel().align(ControlP5.CENTER, ControlP5.BOTTOM).setPaddingX(0);
  cp5.getController("bright1").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  bright2 = cp5.addSlider("bright2")
    .setRange(0,100)
    .setValue(100)
    .setLabelVisible(false)
    .setPosition(bright2X, bright2Y)
    .setSize(brightWidth, brightHeight)
    .setHandleSize(brightHandlesSize)
    .setColorActive(color(255,255,255,150))
    .setColorForeground(color(255,255,255,150))
    .setColorBackground(color(255,255,255,0))
    .setDecimalPrecision(0)
    .setSliderMode(controlP5.Slider.FLEXIBLE)
    ;
  // reposition the Label for controller 'bright2'
  cp5.getController("bright2").getValueLabel().align(ControlP5.CENTER, ControlP5.BOTTOM).setPaddingX(0);
  cp5.getController("bright2").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);


  setLabel1 = cp5.addButton("setLabel1")
    .setPosition(set1LabelX, set1LabelY)
    .setCaptionLabel("Set #1")
    .setColorCaptionLabel(color(24, 118, 183, 255))
    .setSize(setLabelWidth, setLabelHeight)
    .setColorActive(color(255,255,255,150))
    .setColorForeground(color(255,255,255,150))
    .setColorBackground(color(255,255,255,255))
    ;
  // reposition the Label for controller 'setLabel1'
  cp5.getController("setLabel1").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("setLabel1").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  setLabel2 = cp5.addButton("setLabel2")
    .setPosition(set2LabelX, set2LabelY)
    .setCaptionLabel("Set #2")
    .setColorCaptionLabel(color(24, 118, 183, 255))
    .setSize(setLabelWidth, setLabelHeight)
    .setColorActive(color(255,255,255,150))
    .setColorForeground(color(255,255,255,150))
    .setColorBackground(color(255,255,255,255))
    ;
  // reposition the Label for controller 'setLabel2'
  cp5.getController("setLabel2").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("setLabel2").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);


  // create send to pattern 1 button
  sendPatternSet1 = cp5.addButton("send1")
    .setCaptionLabel(sendPattern1Label)
    .setValue(0)
    .setPosition(sendPatternSet1X, sendPatternSet1Y)
    .setSize(sendPatternSetWidth, sendPatternSetHeight)
    .setColorCaptionLabel(color(17, 84, 130, 255))
    .setColorActive(color(255,255,255,150))
    .setColorForeground(color(255,255,255, 150))
    .setColorBackground(color(255,255,255,75))
    ;
  // reposition the Label for controller 'send1'
  cp5.getController("send1").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("send1").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  // create send to pattern 2 button
  sendPatternSet1 = cp5.addButton("send2")
    .setCaptionLabel(sendPattern2Label)
    .setValue(0)
    .setPosition(sendPatternSet2X, sendPatternSet2Y)
    .setSize(sendPatternSetWidth, sendPatternSetHeight)
    ;
  // reposition the Label for controller 'set2'
  cp5.getController("send2").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("send2").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);


  // calculate pattern button positions
  for(int j=0; j < numPatternButtonCols; j++) { // X
    for (int i=0; i < numPatternButtonRows; i++) { // Y
      int idx = (i+(j*numPatternButtonRows));
      patternButton_xyPos[idx][0] = (buttonGridX + (ui_xposMultiplier * j));
      patternButton_xyPos[idx][1] = (buttonGridY + (ui_yposMultiplier * i));
      //println((idx) + " - x:"+patternButton_xyPos[idx][0]+" y:"+patternButton_xyPos[idx][1]);
    }
  }

  // TODO:: make seq names dynamic
  

  // create & draw the button grid buttons
  for(int b=0; b<numPatternButtons; b++) {
    String label = "Pattern #" + (b+1);
    String name = "seq" + (b+1);
    patternButtons[b] = cp5.addButton(name)
      .setCaptionLabel(label)
      .setValueLabel(label)
      .setStringValue(name)
      .setValue(0)
      //.setSwitch(true)
      .activateBy(ControlP5.RELEASE)
      .setPosition(patternButton_xyPos[b][0], patternButton_xyPos[b][1])
      .setSize(patternButtonWidth, patternButtonHeight)
      .setColorCaptionLabel(color(17, 84, 130, 255))
      .setColorActive(color(255,255,255,150))
      //.setColorForeground(color(255,255,255, 150))
      .setColorBackground(color(255,255,255,60))
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


void draw() {
  background(bg);
  image(logo, logoX, logoY);
  cp5.draw();
  // draw a selected state
  pushMatrix();
    fill(255, 255, 255, 80);
    translate(patternButton_xyPos[chosenMovie-1][0], patternButton_xyPos[chosenMovie-1][1]);
    rect (0, 0, patternButtonWidth, patternButtonHeight); // selection state for the buttons
    // TODO:: make an overlay text 
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
  println("clicked controller: " + controllerName);
  if(controllerName.substring(0, 3).equals("seq")) {
    onPreviewButtonPress(theEvent);
  }
}

public void onPreviewButtonPress(ControlEvent buttonEvent) {

  // for(int i=0; i<patternButtons.length; i++) {
    
  //   if(patternButtons[i].getName() != buttonEvent.getController().getName()) {
  //     if(patternButtons[i].getBooleanValue()) {
  //       println(buttonEvent.getController().getName() + " and " + patternButtons[i].getName() + " set on, setting off " + patternButtons[i].toString());
  //       patternButtons[i].setOff();
  //     }
  //   }
  // }
  // cp5.getController(buttonEvent.getController().getName()).setOn();
  int patternNum = Integer.parseInt(buttonEvent.getController().getName().substring(3));
  chosenMovie = patternNum;
  currentFrame = 0;
  //println("chose movie #" + chosenMovie);
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




