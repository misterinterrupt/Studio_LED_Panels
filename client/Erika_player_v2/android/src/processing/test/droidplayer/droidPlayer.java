package processing.test.droidplayer;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import apwidgets.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class droidPlayer extends PApplet {

 

APVideoView videoView; 
APWidgetContainer container; 
String  p ="/sdcard/DCIM/Camera/1.mp4";

public void setup()
{
 



 
  container = new APWidgetContainer(this); //create a new widget container
        videoView = new APVideoView(0,0, 1080, 1920, false); //create a new video view, without media controller
        //videoView = new APVideoView(false); //create a new video view that fills the screen, without a media controller
        //videoView = new APVideoView(); //create a new video view that fills the screen, with a media controller
        videoView.setVideoPath(p); //specify the path to the video file
        container.addWidget(videoView); //place the video view in the container
        videoView.start(); //start playing the video
        videoView.setLooping(true); //restart the video when the end of the file is reached

}

public void draw()
{
  background(0); //black background
  
}


  public int sketchWidth() { return 1080; }
  public int sketchHeight() { return 1920; }
}
