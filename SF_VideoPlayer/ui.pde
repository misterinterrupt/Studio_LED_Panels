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

void selectMovie() {

  selectInput("Select a movie to play:", "fileSelected");
}

void fileSelected(File selection) {

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
