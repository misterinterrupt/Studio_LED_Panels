package processing.test.pixelpetal_v05;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import javax.swing.*; 
import com.heroicrobot.dropbit.registry.*; 
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel; 
import com.heroicrobot.dropbit.devices.pixelpusher.Strip; 
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

public class PixelPetal_v05 extends PApplet {

 








ControlP5 cp5;
int whichMovie=0;

int currentFrame = 0;

 String imageBase1 = "A/A";
 String previewImageBase1 = "A/preview/A_";
 int aDuration = 52;
 
  String imageBase2 = "B/B_";
  String previewImageBase2 = "B/preview/B_";
   int bDuration = 3000;
 
 String imageBase3 = "E/E";
 String previewImageBase3 = "E/preview/E";
  int eDuration = 52;
 
 
 
 String imageBase = imageBase3;
 String previewImageBase = previewImageBase3;
 int numFrames = aDuration;

PImage mainMovie ;
PImage previewImage ;


DeviceRegistry registry;
PusherObserver observer;
PGraphics offScreenBuffer;



public void setup() {
  // size(1920 / 2 ,1200 / 2);
  background(0);
   PFont p = createFont("Verdana.ttf",60);
    cp5 = new ControlP5(this); // for thr UI
     cp5.setControlFont(p);
     
    frameRate(24);
    
     // create a new buttons
  cp5.addButton("movie1")
     .setValue(0)
     .setPosition(100,100)
     .setSize(400,80)
     ;
     
  cp5.addButton("movie2")
     .setValue(0)
     .setPosition(100,250)
     .setSize(400,80)
     ;
     
     cp5.addButton("movie3")
     .setValue(0)
     .setPosition(100,400)
     .setSize(400,80)
     ;
     
  whichMovie=0;
    
  offScreenBuffer = createGraphics(7, 324, JAVA2D);// offscreen buffer to hold the pattern
  registry = new DeviceRegistry();
  observer = new PusherObserver();
  registry.addObserver(observer);
  registry.setAntiLog(true);
  
  
   
   
  } 
   

  


public void draw() {
  
   if (whichMovie == 1){
      imageBase = imageBase1;
      previewImageBase = previewImageBase1;
       numFrames = aDuration;
      }
     
      if (whichMovie == 2){
        
      imageBase = imageBase2;
      previewImageBase = previewImageBase2;
       numFrames = bDuration;
      }
      
      
      if (whichMovie == 3){
        
      imageBase = imageBase3;
      previewImageBase = previewImageBase3;
       numFrames = eDuration;
      }
 
 
 
  
  
  currentFrame = (currentFrame+1) % numFrames;  // Use % to cycle through frames
   String imageName = imageBase + nf(currentFrame, 4) + ".png";
   String previewImageName = previewImageBase + nf(currentFrame, 4) + ".png";
    mainMovie = loadImage(imageName);
    previewImage = loadImage(previewImageName);
    image(previewImage, 000, 800,1200,800);
 

    
  
offScreenBuffer.beginDraw();
offScreenBuffer.image(mainMovie, 0, 0);
scrape();
offScreenBuffer.endDraw();
}






public void controlEvent(ControlEvent theEvent) {

}


public void movie1(int theValue) {

  whichMovie = 1;
  currentFrame = 0;
   int numFrames = aDuration;
 
}

public void movie2(int theValue) {
  whichMovie = 2;
   currentFrame = 0;
  int numFrames = bDuration;
}

public void movie3(int theValue) {
  whichMovie = 3;
   currentFrame = 0;
  int numFrames = eDuration;
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
  
 int numPixels = 324; // number of pixels in the strip and the offscreen buffer
  int numStrips = 7;


  offScreenBuffer.loadPixels();
  if (observer.hasStrips) {  // check that the PixelPusher is attched
    registry.startPushing();
    registry.setAntiLog(true);
    List<Strip> strips = registry.getStrips();

  
    for (int stripX = 0; stripX < numStrips; stripX++) {
      Strip strip = strips.get(stripX);
      for (int stripY = 1; stripY < numPixels; stripY++) {
       int c = offScreenBuffer.pixels[stripX +1 * stripY +1]; // get the pixel color value
       strip.setPixel(c, stripY); // set the pixel on the strip
      } // stripY
    } // stripX
  }
  offScreenBuffer.updatePixels(); 
}



}
