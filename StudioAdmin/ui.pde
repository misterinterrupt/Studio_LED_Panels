ControlP5 cp5;

int appPaddingWidth = 200;
int appPaddingHeight = 150;

// logo & underlay
int logoX = appPaddingWidth;
int logoY = appPaddingHeight;
int logoFrameX = logoX;
int logoFrameY = logoY;
int logoFrameWidth = 1150;
int logoFrameHeight = 426;


int loadFilesWidth = 700;
int loadFilesHeight = 150;
int loadFilesX = appPaddingWidth;
int loadFilesY = appPaddingHeight + loadFilesHeight + 500;

int loadFilesMessageWidth = 1200;
int loadFilesMessageHeight = 125;
int loadFilesMessageX = appPaddingWidth + loadFilesWidth + 160;
int loadFilesMessageY = appPaddingHeight + loadFilesMessageHeight + 500;

int configWidth = 500;
int configHeight = 150;
int config1X = appPaddingWidth;
int config1Y = loadFilesY + loadFilesHeight + 150;
int config2X = config1X + configWidth + 80;
int config2Y = config1Y;
int config3X = config2X + configWidth + 80;
int config3Y = config1Y;


PImage bg;
PImage logo;

String loadFilesLabel = "Load Sequences From Card";
String loadFilesMessageLabel = "Copying new patterns will ERASE all current patterns.";
String copyingMessage = "Copying Patterns from card..";
String finishedCopyingMessage = "New Patterns copied to tablet.";
String problemCopyingMessage = "There was a problem while copying new patterns.";

Boolean firstTimeLoad = true;
Boolean firstTimeC1 = true;
Boolean firstTimeC2 = true;
Boolean firstTimeC3 = true;

public void uiSetup() {
  
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

  // button to load the files from the card onto the tablet
  cp5.addButton("loadFiles")
    .setCaptionLabel(loadFilesLabel)
    .setValueLabel(loadFilesLabel)
    .setValue(0)
    .setPosition(loadFilesX, loadFilesY)
    .setSize(loadFilesWidth, loadFilesHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorCaptionLabel(color(255, 255, 255, 220))
    ;
  // reposition the Label for controller 'loadFiles'
  cp5.getController("loadFiles").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("loadFiles").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  // load Files leaves Messages
  cp5.addButton("loadFilesMessage")
    .setCaptionLabel(loadFilesMessageLabel)
    .setValueLabel(loadFilesMessageLabel)
    .setValue(0)
    .setPosition(loadFilesMessageX, loadFilesMessageY)
    .setSize(loadFilesMessageWidth, loadFilesMessageHeight)
    .setColorBackground(color(255,255,255,25))
    .setColorActive(color(255,255,255,25))
    .setColorCaptionLabel(color(255, 255, 255, 220))
    ;
  // reposition the Label for controller 'loadFilesMessage'
  cp5.getController("loadFilesMessage").getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);
  cp5.getController("loadFilesMessage").getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(0);

  // config buttons
  cp5.addButton("config1")
    .setCaptionLabel("2 - 4")
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
    .setCaptionLabel("3 - 3")
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
    .setCaptionLabel("4 - 2")
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


public void loadFiles(ControlEvent theEvent) {
  if(firstTimeLoad) {
    firstTimeLoad = false;
    return;
  }
  String src = extpath + File.separator + sequenceFolderName;
  String dst = path + File.separator + sequenceFolderName;
  try {
    cp5.getController("loadFilesMessage").setCaptionLabel(copyingMessage);
    deleteSequenceFiles(dst);
    File dstDir = new File(dst);
    File[] newSequences = listFiles(src);
    for( File sequenceDir : newSequences) {
      if(sequenceDir.isDirectory()) {
        File newSequenceDir = new File(dst + File.separator + sequenceDir.getName());
        newSequenceDir.mkdirs();
        //println("making directory " + newSequenceDir.getName());
        File[] frames = listFiles(src + File.separator + sequenceDir.getName());
        for( File frame : frames) {
          copy( src + File.separator + sequenceDir.getName() + File.separator + frame.getName(), 
                dst + File.separator + sequenceDir.getName() + File.separator + frame.getName());
          //println("copied sequence " + src + File.separator + sequenceDir.getName() + File.separator + frame.getName() + "to tablet");
        }
      }
    }
    cp5.getController("loadFilesMessage").setCaptionLabel(finishedCopyingMessage);
  } catch (Exception e) {
    System.err.println(e.getMessage());
    cp5.getController("loadFilesMessage").setCaptionLabel(problemCopyingMessage);
  }
}

public void config1() {
  if(firstTimeC1) {
    firstTimeC1 = false;
    return;
  }
  panelSets = panelSetConfigs[0];
  writeConfig();
}
public void config2() {
  
  if(firstTimeC2) {
    firstTimeC2 = false;
    return;
  }
  panelSets = panelSetConfigs[1];
  writeConfig();
}

public void config3() {
  
  if(firstTimeC3) {
    firstTimeC3 = false;
    return;
  }
  panelSets = panelSetConfigs[2];
  writeConfig();
}

public void writeConfig() {
  println("wrote the config as..");
  println(panelSets);
  saveStrings(path + File.separator + configFileName, panelSets);
  loadConfig();
}

