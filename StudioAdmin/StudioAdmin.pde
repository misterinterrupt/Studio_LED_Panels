import java.util.Date;
import javax.swing.*;
import java.util.*;
import controlP5.*;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;


public boolean folderSelected = false;

public String[][] panelSetConfigs = {
    {"1,2", "3,6"},
    {"1,3", "4,6"},
    {"1,4", "5,6"}
  };
public String[] panelSets = {"", ""};
public String path = "/sdcard/airdroid/upload";
public String extpath = "/storage/extSdCard";
public String configFileName = "setconfig.txt";
public String sequenceFolderName = "sequences";
public boolean hasConfig = false;
public File config;

// ------ default folder path ------
//String defaultFolderPath = System.getProperty("user.home")+"/Desktop";
//String defaultFolderPath = "/Users/admin/Desktop";
//String defaultFolderPath = "//storage/extSdCard/salesforcelive";
/**
 * Listing files in directories and subdirectories
 * by Daniel Shiffman.  
 * 
 * This example has three functions:<br />
 * 1) List the names of files in a directory<br />
 * 2) List the names along with metadata (size, lastModified)<br /> 
 *    of files in a directory<br />
 * 3) List the names along with metadata (size, lastModified)<br />
 *    of files in a directory and all subdirectories (using recursion) 
 */


public void setup() {

  size(2560, 1600);
  frameRate(30);
  uiSetup();
  
  // Path
  //String path = sketchPath;

  checkConfig(path);

  if(hasConfig) {
    println("config exists in path");
    String[] setConfig = loadConfig();
    println("ready to be configured");
  }


  // println("\nListing info about all files in a directory and all subdirectories: ");
  // ArrayList allFiles = listFilesRecursive(path);
  
  // for (int i = 0; i < allFiles.size(); i++) {
  //   File f = (File) allFiles.get(i);    
  //   println("Name: " + f.getName());
  //   println("Full path: " + f.getAbsolutePath());
  //   println("Is directory: " + f.isDirectory());
  //   println("Size: " + f.length());
  //   String lastModified = new Date(f.lastModified()).toString();
  //   println("Last Modified: " + lastModified);
  //   println("-----------------------");
  // }

}

public void draw() {
  
  uiDraw();
}

public void checkConfig(String path) {
  
  // println("Getting all filenames in a directory: ");
  String[] filenames = listFileNames(path);
  
  println("\nListing info about all files in path: " + path);
  File[] files = listFiles(path);

  for (int i = 0; i < files.length; i++) {
    File f = files[i];    
    println("Name: " + f.getName());
    println("Is directory: " + f.isDirectory());
    if(!(f.isDirectory()) && (f.getName().equals("setconfig.txt"))) {
      hasConfig = true;
    }
    // println("Size: " + f.length());
    // String lastModified = new Date(f.lastModified()).toString();
    // println("Last Modified: " + lastModified);
    // println("-----------------------");
  }
}

public String[] loadConfig() {
  // load configs
  String[] setConfig = new String[2];
  Boolean loadSuccess = false;
  try {
    setConfig = loadStrings(path + File.separator + "setconfig.txt");
    loadSuccess = true;
    println("loaded config");
  } catch(Exception e) {
    loadSuccess = false;
  }
  if(loadSuccess) {
    println("there are " + setConfig.length + " sets");
    panelSets = setConfig;
    println(setConfig);
  } else {
    // load a default config
    try{
      boolean success = config.createNewFile();
      if(success) {
        println("created a new file");
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
  return panelSets;
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    println("it's not a directory");
    return null;
  }
}

// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    println("it's not a directory");
    return null;
  }
}

// Function to get a list of all files in a directory and all subdirectories
ArrayList<File> listFilesRecursive(String dir) {
   ArrayList<File> fileList = new ArrayList<File>(); 
   recurseDir(fileList,dir);
   return fileList;
}

// Recursive function to traverse subdirectories
void recurseDir(ArrayList<File> a, String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    // If you want to include directories in the list
    a.add(file);  
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      // Call this function on all files in this directory
      recurseDir(a,subfiles[i].getAbsolutePath());
    }
  } else {
    a.add((File)file);
  }
}

// Function to get a list of all files in a directory and all subdirectories
public void deleteSequenceFiles(String dir) {

  File[] top = new File(dir).listFiles();
  for(File sequenceDir : top) {
    File[] frames = sequenceDir.listFiles();
    for(File frame : frames) {
      frame.delete();
    }
    // delete the dir
    sequenceDir.delete();
  }
}


public void copy(String fromFileName, String toFileName)
    throws IOException {
  File fromFile = new File(fromFileName);
  File toFile = new File(toFileName);

  if (!fromFile.exists())
    throw new IOException("FileCopy: " + "no such source file: "
        + fromFileName);
  if (!fromFile.isFile())
    throw new IOException("FileCopy: " + "can't copy directory: "
        + fromFileName);
  if (!fromFile.canRead())
    throw new IOException("FileCopy: " + "source file is unreadable: "
        + fromFileName);

  if (toFile.isDirectory())
    toFile = new File(toFile, fromFile.getName());

  if (toFile.exists()) {
    if (!toFile.canWrite())
      throw new IOException("FileCopy: "
          + "destination file is unwriteable: " + toFileName);
    
    println("Overwriting existing file " + toFile.getName());
  } else {
    String parent = toFile.getParent();
    if (parent == null)
      parent = System.getProperty("user.dir");
    File dir = new File(parent);
    if (!dir.exists())
      throw new IOException("FileCopy: "
          + "destination directory doesn't exist: " + parent);
    if (dir.isFile())
      throw new IOException("FileCopy: "
          + "destination is not a directory: " + parent);
    if (!dir.canWrite())
      throw new IOException("FileCopy: "
          + "destination directory is unwriteable: " + parent);
  }

  FileInputStream from = null;
  FileOutputStream to = null;
  try {
    from = new FileInputStream(fromFile);
    to = new FileOutputStream(toFile);
    byte[] buffer = new byte[4096];
    int bytesRead;

    while ((bytesRead = from.read(buffer)) != -1)
      to.write(buffer, 0, bytesRead); // write
  } finally {
    if (from != null)
      try {
        from.close();
      } catch (IOException e) {
        ;
      }
    if (to != null)
      try {
        to.close();
      } catch (IOException e) {
        ;
      }
  }
}
