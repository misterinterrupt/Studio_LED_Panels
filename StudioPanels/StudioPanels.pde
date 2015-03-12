import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import com.heroicrobot.dropbit.devices.pixelpusher.PixelPusher;
import com.heroicrobot.dropbit.devices.pixelpusher.PusherCommand;
import android.os.Environment;
import java.util.*;
import java.io.*;
import controlP5.*;

public class Sequence {
  public int count;
  public String path;
  public String name;
  public File[] frames;

  public Sequence(String name, String path, int count, File[] frames)
  {
   this.count = count;
   this.path = path;
   this.name = name;
   this.frames = frames;
  }
  
  public String toString()
  {
    return "Sequence  [name: " + this.name + " path: " + this.path + " count: " + this.count + "]";
  }
}

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
int buttonGridY = appPaddingHeight + patternPreviewHeight;
int buttonGridX = appPaddingWidth;
int patternButtonWidth = 400;
int patternButtonHeight = 160;
int buttonGridPaddingRightWidth = 40;
int buttonGridWidth = (numPatternButtonCols * patternButtonWidth);
int buttonGridHeight = (numPatternButtonRows * patternButtonHeight);
int ui_xposMultiplier = patternButtonWidth;
int ui_yposMultiplier = patternButtonHeight;

// mode button area (color picker to pattern preview & back)
Button colorPickerModeButton;
int colorPickerModeWidth = 1200;
int colorPickerModeHeight = 140;
int colorPickerModeX = appPaddingWidth;
int colorPickerModeY = appPaddingHeight + patternPreviewHeight + (numPatternButtonRows * patternButtonHeight);
String colorPickerModeLabel = "Solid Colors";

Button patternPreviewModeButton;
int patternPreviewModeWidth = 1200;
int patternPreviewModeHeight = 140;
int patternPreviewModeX = appPaddingWidth;
int patternPreviewModeY = appPaddingHeight + patternPreviewHeight + (numPatternButtonRows * patternButtonHeight);
String patternPreviewModeLabel = "Patterns";

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
int globalBright = 100;

// brightness slider frames
int brightFrameWidth = 440;
int brightFrameHeight = brightHeight + (sendPaddingInner * 3) + sendPatternSetLabelHeight;
int bright1FrameX = sendPatternSet1LabelX;
int bright1FrameY = sendPatternSet1LabelY + sendPatternSetHeight;
int bright2FrameX = sendPatternSet2LabelX;
int bright2FrameY = sendPatternSet2LabelY + sendPatternSetHeight;

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
List<Button> patternButtons;
ArrayList<Sequence> sequencePaths;
int chosenPreviewMovie=0;
int chosenMovie1=0;
int chosenMovie2=0;
boolean colorPickerModeShowing = false; // show color picker and show picked color in preview space
boolean showColorOnSet1 = false;
boolean showColorOnSet2 = false;

int currentFrame1 = 0;
int currentFrame2 = 0;
int currentFrame3 = 0;
PImage previewMovie1;
PImage previewMovie2;
PImage previewMovie3;
PGraphics colorPickerPreviewMovie;
PGraphics colorPickerMovie1;
PGraphics colorPickerMovie2;

boolean noStrips = true;
DeviceRegistry registry;
PusherObserver observer;
PGraphics patternPreviewBuffer;
PGraphics set1Buffer;
PGraphics set2Buffer;

int numSets = 2;
int numPanelsSet1 = 3;
int numPanelsSet2 = 4;
int stride = 167; // number of LEDs per row aka striplength
int panelDisplayHeight = 24;
float xscale = 1; // horizontal scale factor
int panelDisplayWidth = (numPanelsSet1 + numPanelsSet2) * stride;
int bufferWidth = 4*stride;

// sets must be in numerical order
// define each pixel pusher powered panel set by group start and group end indexes
int[][] panelSets = {{1,4},{5,6}};
int[][] panelsInSets = {{}, {}};

// this is unused, just leaving it here for the future
// this order array will be indexed by the limits in the sets variable,
// the values represent the order that the controller groups are scraped to
//int[][] order = {{1,1}, {2,2}, {3,3}, {4,4}, {5,5}, {6,6}};

ColorPicker cp;

int[][] colors = {
    {127, 0, 0},
    {0, 127, 0},
    {0, 0, 127}
  };

PImage bg;
PImage logo;
PImage errorScreen;


void setup() {

  loadConfig();
  brightnessGroups();
  loadSequences();

  println("starting");
  size(2560, 1600);
  frameRate(30);

  patternPreviewBuffer = createGraphics(bufferWidth, panelDisplayHeight, JAVA2D); // buffer with the same number of pixels as the wall
  set1Buffer = createGraphics(bufferWidth, panelDisplayHeight, JAVA2D);
  set2Buffer = createGraphics(bufferWidth, panelDisplayHeight, JAVA2D);

  bg = loadImage("skyflares_bg.png");
  logo = loadImage("salesforce_logo.png");
  stroke(255);
  noFill();
  strokeWeight(1); 
  PFont p = createFont("Gotham-Medium.otf", 30);
  cp5 = new ControlP5(this);
  cp5.setControlFont(p);
  cp5.setAutoDraw(false);
  cp5.setAutoInitialization(false);
  
  // create colorpicker mode button
  colorPickerModeButton = cp5.addButton("colorPickerMode")
    .setCaptionLabel(colorPickerModeLabel)
    .setValueLabel(colorPickerModeLabel)
    .setValue(0)
    .setPosition(colorPickerModeX, colorPickerModeY)
    .setSize(colorPickerModeWidth, colorPickerModeHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorCaptionLabel(color(255, 255, 255, 220))
    ;
  // reposition the Label for controller 'colorPickerMode'
  cp5.getController("colorPickerMode").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("colorPickerMode").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  // create pattern preview mode button
  patternPreviewModeButton = cp5.addButton("patternPreviewMode")
    .setCaptionLabel(patternPreviewModeLabel)
    .setValueLabel(patternPreviewModeLabel)
    .setValue(0)
    .setPosition(patternPreviewModeX, patternPreviewModeY)
    .setSize(patternPreviewWidth, patternPreviewModeHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorCaptionLabel(color(255, 255, 255, 220))
    ;
  // reposition the Label for controller 'patternPreviewMode'
  cp5.getController("patternPreviewMode").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("patternPreviewMode").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("patternPreviewMode").setVisible(false);
  
  bright1 = cp5.addSlider("bright1")
    .setRange(0,100)
    .setValue(100)
    .setLabelVisible(false)
    .setPosition(bright1X, bright1Y)
    .setSize(brightWidth, brightHeight)
    .setHandleSize(brightHandlesSize)
    .setColorActive(color(255,255,255,50))
    .setColorForeground(color(255,255,255,50))
    .setColorBackground(color(255,255,255,50))
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
    .setColorActive(color(255,255,255,50))
    .setColorForeground(color(255,255,255,50))
    .setColorBackground(color(255,255,255,50))
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
    .setColorActive(color(255,255,255,255))
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
    .setColorActive(color(255,255,255,255))
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
    .setColorCaptionLabel(color(17, 84, 130, 255))
    .setColorActive(color(255,255,255,150))
    .setColorForeground(color(255,255,255, 150))
    .setColorBackground(color(255,255,255,75))
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

  // numPatternButtons = sequencePaths.size();
  // create & draw the button grid buttons
  for(int b=0; b<numPatternButtons; b++) {
    String label;
    String name;
    color activeColor;
    color bgColor = color(255,255,255,80);
    if(b <sequencePaths.size()) {
      label = sequencePaths.get(b).name;
      name = "seq" + b;
      activeColor = color(255,255,255,120);
    } else {
      label = "";
      name = "empty" + b;
      activeColor = bgColor;
    }
    cp5.addButton(name)
      .setCaptionLabel(label)
      .setValueLabel(label)
      .setStringValue(name)
      .setValue(0)
      // .setSwitch(true)
      // .activateBy(ControlP5.RELEASE)
      .setPosition(patternButton_xyPos[b][0], patternButton_xyPos[b][1])
      .setSize(patternButtonWidth, patternButtonHeight)
      .setColorCaptionLabel(color(17, 84, 130, 255))
      .setColorActive(activeColor)
      //.setColorForeground(color(255,255,255, 150))
      .setColorBackground(bgColor)
      ;
      // reposition the Label for controllers named 'seq'+(b+1)
      cp5.getController(name).getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
      cp5.getController(name).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  }

  registry = new DeviceRegistry();
  observer = new PusherObserver();
  registry.addObserver(observer);
  registry.setAntiLog(true);
  registry.setAutoThrottle(true);

  // create the color picker instance
  colorPickerModeShowing = false; // show color picker and show picked color in preview space
  colorPickerMovie1 = createGraphics(patternPreviewWidth, patternPreviewHeight);
  colorPickerMovie2 = createGraphics(patternPreviewWidth, patternPreviewHeight);
  cp = new ColorPicker( buttonGridX, buttonGridY, buttonGridWidth, buttonGridHeight, 255, patternPreviewWidth, patternPreviewHeight );

}


void draw() {

  background(bg);
  image(logo, logoX, logoY);
  cp5.draw();
  
  // draw a selected state
  pushMatrix();
    fill(255, 255, 255, 80);
    translate(patternButton_xyPos[chosenPreviewMovie][0], patternButton_xyPos[chosenPreviewMovie][1]);
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

  // draw bright1 frame
  pushMatrix();
    translate(bright1FrameX, bright1FrameY);
    noStroke();
    fill(255, 255, 255, 25);
    rect(0, 0, brightFrameWidth, brightFrameHeight);
  popMatrix();

  // draw bright1 frame
  pushMatrix();
    translate(bright2FrameX, bright2FrameY);
    noStroke();
    fill(255, 255, 255, 25);
    rect(0, 0, brightFrameWidth, brightFrameHeight);
  popMatrix();

  // draw grid lines
  pushMatrix();
    noFill();
    stroke(0, 0, 0, 50);
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

  //println(sequencePaths.get(chosenPreviewMovie).path + "/pixelData" + nf(currentFrame1, 5) + ".jpg");
  // println(sequencePaths.get(chosenPreviewMovie).frames[currentFrame1].getPath());

  // get the modulo, so the frame is in range, then use ++ to increment it after using it
  currentFrame1 = (currentFrame1) % (sequencePaths.get(chosenPreviewMovie).count);  // Use % to cycle through frames and loop
  currentFrame2 = (currentFrame2) % (sequencePaths.get(chosenMovie1).count);  // Use % to cycle through frames and loop
  currentFrame3 = (currentFrame3) % (sequencePaths.get(chosenMovie2).count);  // Use % to cycle through frames and loop
  

  // show color picker and show picked color in preview space
  if(colorPickerModeShowing == true) {
    // when rendering the cp, also make a solid color graphic for the preview
    cp.render();
    colorPickerPreviewMovie = cp.colorMovie;
    image(colorPickerPreviewMovie, 200, 150, 1200, 200);
    patternPreviewBuffer.image(colorPickerPreviewMovie, 0, 0,668,24);
  } else {
    String imageName1 = sequencePaths.get(chosenPreviewMovie).frames[currentFrame1++].getPath();
    previewMovie1 = loadImage(imageName1);
    image(previewMovie1, 200, 150, 1200, 200);
    patternPreviewBuffer.image(previewMovie1, 0, 0,668,24);
  }


  if(showColorOnSet1 == true) {
    set1Buffer.image(colorPickerMovie1, 0, 0,668,24);
    image(colorPickerMovie1, set1LabelX, set1LabelY, setLabelWidth, setLabelHeight);
  } else {
    String imageName2 = sequencePaths.get(chosenMovie1).frames[currentFrame2++].getPath();
    previewMovie2 = loadImage(imageName2);
    set1Buffer.image(previewMovie2, 0, 0,668,24);
    image(previewMovie2, set1LabelX, set1LabelY, setLabelWidth, setLabelHeight);
  }


  if(showColorOnSet2 == true) {
    set2Buffer.image(colorPickerMovie2, 0, 0,668,24);
    image(colorPickerMovie2, set2LabelX, set2LabelY, setLabelWidth, setLabelHeight);
  } else {
    String imageName3 = sequencePaths.get(chosenMovie2).frames[currentFrame3++].getPath();
    previewMovie3 = loadImage(imageName3);
    set2Buffer.image(previewMovie3, 0, 0,668,24);
    image(previewMovie3, set2LabelX, set2LabelY, setLabelWidth, setLabelHeight);
  }

  // if (noStrips) {image(errorScreen, 000, 0,800,1280);} // display error if there are no strips detected
  scrape(); // scrape the offscreen buffer
}

public void brightnessGroups() {
  // make array of set groups
  for(int setIdx=0; setIdx<panelSets.length; setIdx++) {

    int panelSetFirst = panelSets[setIdx][0]; // e.g. 1
    int panelSetLast = panelSets[setIdx][1]; // e.g. 2
    int panelSetLength = (panelSetLast - panelSetFirst)+1; // e.g. 2  number of panels in the set inclusive
    panelsInSets[setIdx] = new int[panelSetLength];
    for(int i=0;i<panelSetLength; i++) {
      panelsInSets[setIdx][i] = panelSetFirst + i;
    }
  }
}

public void bright1(ControlEvent globalBright) {
  float val = globalBright.getValue();
  if(val > 0 || val < 100) {
    //println ("brightness = " + val);
    bright(0, val);
  }
}

public void bright2(ControlEvent globalBright) {
  float val = globalBright.getValue();
  if(val > 0 || val < 100) {
    //println ("brightness = " + val);
    bright(1, val);
  }
}

public void bright(int setIdx, float globalBright) { // takes a brightness value between 0 - 100 

  if (observer.hasStrips) {
    float newBright = map (globalBright,0,100,0,65535);
    
    List<PixelPusher> pushers = new ArrayList<PixelPusher>();
    for(int i=0; i<panelsInSets[setIdx].length; i++) {
      pushers.addAll(registry.getPushers(panelsInSets[setIdx][i]));
    }
    for (PixelPusher p: pushers) {
       PusherCommand pc = new PusherCommand(PusherCommand.GLOBALBRIGHTNESS_SET,(short) (newBright));
       spamCommand(p,  pc);
    }
    println ("brightness = " + newBright);
  }
}

public void colorPickerMode(ControlEvent buttonEvent) {
  if(buttonEvent == null) { return; }
  colorPickerModeShowing = true; // show color picker and show picked color in preview space
  colorPickerModeButton.setVisible(false);
  patternPreviewModeButton.setVisible(true);
}

// UI selections
public void controlEvent(ControlEvent theEvent) {

  if(theEvent == null) { return; }
  String controllerName = theEvent.getController().getName();
  //println("clicked controller: " + controllerName);
  if(controllerName.substring(0, 3).equals("seq")) {
    onPreviewButtonPress(theEvent);
  }
  if(controllerName.substring(0, 4).equals("send")) {
    onSendButtonPress(theEvent);
  }
}

// public File getMovieStorageDir() {
//     // Get the directory for the user's public pictures directory.
//     File file = new File(Environment.getExternalStoragePublicDirectory(
//             Environment.DIRECTORY_MOVIES),"");
//     if (!file.mkdirs()) {
//         println("Directory not created");
//     }
//     return file;
// }

public void loadConfig() {
  // load configs
  String setConfig[];
  try {
    setConfig = loadStrings("/sdcard/airdroid/upload/setconfig.txt");
  } catch(Exception e) {
    // load a default config
    setConfig = loadStrings("setconfig.txt");
  }
  println("there are " + setConfig.length + " sets");
  for (int i = 0 ; i < numSets; i++) {
    String[] savedset = setConfig[i].split(",");
    panelSets[i] = new int[] {Integer.parseInt(savedset[0]), Integer.parseInt(savedset[1])};
    println(setConfig[i]);
  }
  //println("panelSets.length:" + panelSets.length);
  // String lastSends[] = loadStrings("lastsends.txt");
  // println("there was " + lines.length + " saved send(s)");
  // for (int i = 0 ; i < lines.length; i++) {
  //   println(lines[i]);
  // }
}

public void loadSequences() {
  
  // load sequence paths and count their durations 
  // File folder = new File(sketchPath("sequences"));
  // File folder = getMovieStorageDir();
  // File folder = new File("//sdcard/Movies");
  File folder = new File("/sdcard/airdroid/upload/sequences");
  //println(folder.getPath());
  String[] seqs = folder.list();

  if(seqs != null) {
    sequencePaths = new ArrayList<Sequence>(seqs.length);
    int seqIdx = 0; // keep our own count for indexing into the sequencePaths array since hidden files will make our loop skip 
      for (int i = 0; i < seqs.length; i++) {
        File f = new File(seqs[i]);
        int count = 0;
        println("name: " + f.getName());
        if( !f.isHidden() ) {
          String frameDir = folder.getPath() + f.separatorChar + f.getPath();
          File[] frames = new File(frameDir).listFiles();
          if(null != frames) {
            count = frames.length;
          }
          // println(seqIdx + " " + frameDir);
          sequencePaths.add(seqIdx++, new Sequence(f.getPath(), frameDir, count, frames));
          // println(f.getPath());
        }
      }
    sequencePaths.trimToSize();
  } else {
   println("no sequences");
   System.exit(0);
  }
}

public void onSendButtonPress(ControlEvent buttonEvent) {

  int setToSendTo = Integer.parseInt(buttonEvent.getController().getName().substring(4));
  if(setToSendTo == 1) {
    if(colorPickerModeShowing == true) {
      // println("changing color picker for set 1");
      colorPickerMovie1 = createGraphics(patternPreviewWidth, patternPreviewHeight);
      colorPickerMovie1.loadPixels();
      cp.colorMovie.loadPixels();
      arrayCopy(cp.colorMovie.pixels, colorPickerMovie1.pixels);
      colorPickerMovie1.updatePixels();
      showColorOnSet1 = true;
    } else {
      showColorOnSet1 = false;
      chosenMovie1 = chosenPreviewMovie;
      currentFrame2 = 0;
      // println("sent movie #" + chosenPreviewMovie + " to set #" + setToSendTo);
    }
  } else if(setToSendTo == 2) {
    if(colorPickerModeShowing == true) {
      // println("changing color picker for set 2");
      colorPickerMovie2 = createGraphics(patternPreviewWidth, patternPreviewHeight);
      colorPickerMovie2.loadPixels();
      cp.colorMovie.loadPixels();
      arrayCopy(cp.colorMovie.pixels, colorPickerMovie2.pixels);
      colorPickerMovie2.updatePixels();
      showColorOnSet2 = true;
    } else {
      showColorOnSet2 = false;
      chosenMovie2 = chosenPreviewMovie;
      currentFrame3 = 0;
      // println("sent movie #" + chosenPreviewMovie + " to set #" + setToSendTo);
    }
  }
}

public void onPreviewButtonPress(ControlEvent buttonEvent) {

  Button butt = ((Button)buttonEvent.getController());
  if(butt != null) {
    //println(butt.getName());
    //println(butt.toString());
    List<Button> patternButtons = cp5.getAll(Button.class);
    // for(Button b:patternButtons) {
    //   //println(b.toString());
    //   String name = ((String)b.getName());
    //   if(b != null) {
    //     if(name.substring(0, 3).equals("seq")) {
    //       if(name != butt.getName()) {
    //         //println(butt.getName() + " pressed and " + b.getName() + " is set on, setting off " + b.toString());
    //         b.setOff();
    //       } else {
    //         b.setOn();
    //       }
    //     }
    //   }
    // }

    int patternNum = Integer.parseInt(((String)butt.getName()).substring(3));
    chosenPreviewMovie = patternNum;
    currentFrame1 = 0;
    // println("chose movie #" + chosenPreviewMovie);
  }
}

public void patternPreviewMode(ControlEvent buttonEvent) {
  if(buttonEvent == null) { return; }
  colorPickerModeShowing = false; // show color picker and show picked color in preview space
  colorPickerModeButton.setVisible(true);
  patternPreviewModeButton.setVisible(false);
}

public void spamCommand(PixelPusher p, PusherCommand pc) {
   for (int i=0; i<3; i++) {
    p.sendCommand(pc);
  }
}



