package processing.test.admin;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Date; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class admin extends PApplet {


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

  // Path
  //String path = sketchPath;
  String path = "//storage/extSdCard ";

  println("Listing all filenames in a directory: ");
  String[] filenames = listFileNames(path);
  println(filenames);
  
  println("\nListing info about all files in a directory: ");
  File[] files = listFiles(path);
  for (int i = 0; i < files.length; i++) {
    File f = files[i];    
    println("Name: " + f.getName());
    println("Is directory: " + f.isDirectory());
    println("Size: " + f.length());
    String lastModified = new Date(f.lastModified()).toString();
    println("Last Modified: " + lastModified);
    println("-----------------------");
  }
  
  println("\nListing info about all files in a directory and all subdirectories: ");
  ArrayList allFiles = listFilesRecursive(path);
  
  for (int i = 0; i < allFiles.size(); i++) {
    File f = (File) allFiles.get(i);    
    println("Name: " + f.getName());
    println("Full path: " + f.getAbsolutePath());
    println("Is directory: " + f.isDirectory());
    println("Size: " + f.length());
    String lastModified = new Date(f.lastModified()).toString();
    println("Last Modified: " + lastModified);
    println("-----------------------");
  }

  noLoop();
}

// Nothing is drawn in this program and the draw() doesn't loop because
// of the noLoop() in setup()
public void draw() {

}


// This function returns all the files in a directory as an array of Strings  
public String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
public File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}

// Function to get a list ofall files in a directory and all subdirectories
public ArrayList listFilesRecursive(String dir) {
   ArrayList fileList = new ArrayList(); 
   recurseDir(fileList,dir);
   return fileList;
}

// Recursive function to traverse subdirectories
public void recurseDir(ArrayList a, String dir) {
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
    a.add(file);
  }
}

}