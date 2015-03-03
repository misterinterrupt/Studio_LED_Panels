import apwidgets.*; 

APVideoView videoView; 
APWidgetContainer container; 
String  p ="/sdcard/airdroid/upload/test.mp4";

void setup()
{
 



  size (480,800);
  container = new APWidgetContainer(this); //create a new widget container
        videoView = new APVideoView(0,0, 480, 800, false); //create a new video view, without media controller
        //videoView = new APVideoView(false); //create a new video view that fills the screen, without a media controller
        //videoView = new APVideoView(); //create a new video view that fills the screen, with a media controller
        videoView.setVideoPath(p); //specify the path to the video file
        container.addWidget(videoView); //place the video view in the container
        videoView.start(); //start playing the video
        videoView.setLooping(true); //restart the video when the end of the file is reached

}

void draw()
{
  background(0); //black background
  
}


     

