void setup()
{
File dir = new File("//sdcard/sequences");
String[] list = dir.list();

if (list == null) {
  println("Folder does not exist or cannot be accessed.");
} 
else {
  println(list);
} 


}

// void draw{}




