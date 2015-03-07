import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import javax.swing.*; 
import processing.video.*; 
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

public class SF_VideoPlayer extends PApplet {











boolean fileSelected = false;
boolean firstTime = true;
String path;

int stride = 167;
int[][] panelSets = {{1,4},{5,6}};

Movie myMovie;
DeviceRegistry registry;
PusherObserver observer;

public void setup() {
  
  size(1080, 800);
  frameRate(30);
  println("starting width: " + width);
  registry = new DeviceRegistry();
  observer = new PusherObserver();
  registry.addObserver(observer);
  registry.setAntiLog(true);
  bright (100); // sets the global brightness of the LEDs
  uiSetup();
}

public void draw() {
  
  uiDraw();

  if (fileSelected) {
    if(myMovie.time() >= myMovie.duration()) {
      println("times::::::::::::::::::::::   ");
      println("times::::::::::::::::::::::   time: " + myMovie.time());
      println("times::::::::::::::::::::::   duration: " + myMovie.duration());
      println("times::::::::::::::::::::::   ");
      myMovie.jump(0.0f);
    }
    image(myMovie, appPaddingWidth, appPaddingHeight + logoFrameHeight, width-120, 200);
    scrape();
  }
}

public void movieEvent(Movie m) {

  m.read();
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
   
  println ("brightness = " + newBright);
}





class PusherObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    println("Registry changed!");
    if (updatedDevice != null) {
      println("Device change: " + updatedDevice);
    }
    this.hasStrips = true;
  }
};

public void scrape() {
  // scrape for the strips 501 x 24 (167 per panel)
  // scrape for the strips 668 x 24 (167 per panel)  
  
  float xpos = 0, ypos = 0;
  myMovie.loadPixels();
  if (observer.hasStrips) {
    registry.startPushing();

    // each set of panels
    for(int setIdx=0; setIdx<panelSets.length; setIdx++) {

      // index into the {start,end} panel sets and scrape for those panels in order
      // we will index into the panelSetBuffers as well, to get the right stuff from them
      int panelSetFirst = panelSets[setIdx][0]; // e.g. 1
      int panelSetLast = panelSets[setIdx][1]; // e.g. 2
      int panelSetLength = (panelSetLast - panelSetFirst) + 1; // e.g. 2  number of panels in the set inclusive
      // println("panelSet " + setIdx);
      // println("panelSetFirst "+ panelSetFirst);
      // println("panelSetLast "+ panelSetLast);
      // println("panelSetLength "+ panelSetLength);

      // for each individual panel in the current set
      for(int panelIdx = 0; panelIdx < panelSetLength; panelIdx++) {
        // index + panel start gives us the actual group
        int groupIdx = (panelIdx + panelSetFirst);
        // println(panelIdx + " group: " + groupIdx);
        List<Strip> strips = registry.getStrips(groupIdx);

        if (strips.size() > 0) {
          for (Strip strip : strips) {   // for each strip (y-index)
            
            for (int stripx = 0; stripx < 334; stripx++) {  // loop through each pixel in the strip
            
              int xpixel = stripx % stride;
              int stridenumber = stripx / stride;            
              // zigzag code
              if ((stridenumber & 1) == 0) { // we are going left to right
                xpos = xpixel;
              } else { // we are going right to left
                xpos = ((stride - 1)-xpixel);
              }
              // add 0-indexed multiplier of stride for xpos
              xpos = xpos + (panelIdx * stride);
              //println ("Set: " + setIdx + " Group: " + groupIdx + " stride:" + (panelIdx * stride) + " getting pixel from "+xpos + "," + ypos);
              //int pixIndex = (int) xpos + (stride * (int) ypos);
              //color c = myMovie.pixels[pixIndex];)
              if(setIdx == 0) {
                int c = myMovie.get((int) xpos, (int) ypos);      
                strip.setPixel(c, stripx);          
              } else if (setIdx == 1) {
                int c = myMovie.get((int) xpos, (int) ypos);
                strip.setPixel(c, stripx);
              }

              if (stripx == stride || stripx == 333) {
                ypos=ypos+1;
              } // move to the next yPos of the buffer
              
            } //end x loop
           
          } // for each strip
        } // strips.size() check for any strips
        // reset y scan
        ypos = 0;
      }
    }
  } // observer
} // scrape
ControlP5 cp5;

int appPaddingWidth = 60;
int appPaddingHeight = 60;

// logo & underlay
int logoX = appPaddingWidth;
int logoY = appPaddingHeight;
int logoFrameX = logoX;
int logoFrameY = logoY;
int logoFrameWidth = 320;
int logoFrameHeight = 341;


int chooseVideoWidth = 400;
int chooseVideoHeight = 50;
int chooseVideoX = appPaddingWidth;
int chooseVideoY = appPaddingHeight + chooseVideoHeight + 500;

int configWidth = 200;
int configHeight = 50;
int config1X = appPaddingWidth;
int config1Y = chooseVideoY + 75;
int config2X = config1X + configWidth + 40;
int config2Y = config1Y;
int config3X = config2X + configWidth + 40;
int config3Y = config1Y;


PImage bg;
PImage logo;

String chooseVideoLabel = "Choose Video";

public void uiSetup() {
  
  bg = loadImage("skyflares_bg.png");
  logo = loadImage("salesforce_logo.png");
  stroke(255);
  noFill();
  strokeWeight(1); 
  PFont p = createFont("Gotham-Medium.otf", 26);
  cp5 = new ControlP5(this);
  cp5.setControlFont(p);
  cp5.setAutoDraw(false);
  cp5.setAutoInitialization(false);

  // create colorpicker mode button
  cp5.addButton("chooseVideo")
    .setCaptionLabel(chooseVideoLabel)
    .setValueLabel(chooseVideoLabel)
    .setValue(0)
    .setPosition(chooseVideoX, chooseVideoY)
    .setSize(chooseVideoWidth, chooseVideoHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorCaptionLabel(color(255, 255, 255, 220))
    ;
  // reposition the Label for controller 'chooseVideo'
  cp5.getController("chooseVideo").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("chooseVideo").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  // config buttons
  cp5.addButton("config1")
    .setCaptionLabel("set 1")
    .setValue(0)
    .setPosition(config1X, config1Y)
    .setSize(configWidth, configHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorCaptionLabel(color(255, 255, 255, 220))
    ;
  // reposition the Label for controller 'config1'
  cp5.getController("config1").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("config1").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  cp5.addButton("config2")
    .setCaptionLabel("set 2")
    .setValue(0)
    .setPosition(config2X, config2Y)
    .setSize(configWidth, configHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorCaptionLabel(color(255, 255, 255, 220))
    ;
  // reposition the Label for controller 'config2'
  cp5.getController("config2").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("config2").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  cp5.addButton("config3")
    .setCaptionLabel("all")
    .setValue(0)
    .setPosition(config3X, config3Y)
    .setSize(configWidth, configHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorCaptionLabel(color(255, 255, 255, 220))
    ;
  // reposition the Label for controller 'config3'
  cp5.getController("config3").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("config3").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

}

public void uiDraw() {

  image(bg, 0, 0);
  image(logo, logoX, logoY);
  cp5.draw();
}

public void loadNewVideo() {

  myMovie = new Movie(this, path);
  myMovie.loop();
}

public void chooseVideo(ControlEvent theEvent) {
  if(!firstTime) {
    selectMovie();
  } else {
    firstTime = false;
  }
}

public void selectMovie() {

  selectInput("Select a movie to play:", "fileSelected");
}

public void fileSelected(File selection) {

  if (selection != null) 
  {
    path = selection.getAbsolutePath();
    println("User selected " + path);
    loadNewVideo();
    fileSelected = true;
  }
}

public void config1() {

  panelSets[0] = new int[] {1,4};
  panelSets[1] = new int[] {7,7};
}
public void config2() {

  panelSets[0] = new int[] {5,6};
  panelSets[1] = new int[] {7,7};
}

public void config3() {

  panelSets[0] = new int[] {1,6};
  panelSets[1] = new int[] {7,7};
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SF_VideoPlayer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
