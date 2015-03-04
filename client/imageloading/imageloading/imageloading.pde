String  pathBase ="/sdcard/airdroid/upload/test";
PImage mainMovie;  

int currentFrame = 0;

void setup()
{
 size (480,800);
 
}

void draw()
{
  
//  currentFrame = 1+ (currentFrame+1) % 99;  // Use % to cycle through frames and loop
   String imageName = pathBase + "/pixelData" + nf(currentFrame, 5) + ".jpg";
   println(imageName);
    mainMovie = loadImage("/sdcard/airdroid/upload/patternH/pixelData00000.jpg");  
   image(mainMovie, 0, 0);

}
