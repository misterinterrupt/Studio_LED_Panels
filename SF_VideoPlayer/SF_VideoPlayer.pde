import javax.swing.*;
import processing.video.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import com.heroicrobot.dropbit.devices.pixelpusher.PixelPusher;
import com.heroicrobot.dropbit.devices.pixelpusher.PusherCommand;
import java.util.*;
import controlP5.*;

boolean fileSelected = false;
boolean firstTime = true;
String path;

int stride = 167;
int[][] panelSets = {{1,4},{5,6}};

Movie myMovie;
DeviceRegistry registry;
PusherObserver observer;

void setup() {
  
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

void draw() {
  
  uiDraw();

  if (fileSelected) {
    if(myMovie.time() >= myMovie.duration()) {
      println("times::::::::::::::::::::::   ");
      println("times::::::::::::::::::::::   time: " + myMovie.time());
      println("times::::::::::::::::::::::   duration: " + myMovie.duration());
      println("times::::::::::::::::::::::   ");
      myMovie.jump(0.0);
    }
    image(myMovie, appPaddingWidth, appPaddingHeight + logoFrameHeight, width-120, 200);
    scrape();
  }
}

void movieEvent(Movie m) {

  m.read();
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
   
  println ("brightness = " + newBright);
}





