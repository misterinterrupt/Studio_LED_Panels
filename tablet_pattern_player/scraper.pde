void scrape() {
  // scrape for the strips 501 x 24 (167 per panel)
  
  
  float xpos =0, ypos = 0;
  offScreenBuffer.loadPixels();
  if (observer.hasStrips) {
    registry.startPushing();
    boolean phase = false;
    int stride = 167; // number of LEDs per row

    // First, scrape for the left hand panel of the display

    List<Strip> strips = registry.getStrips(1);

    if (strips.size() > 0) {

      for (Strip strip : strips) {   // for each strip (y-direction)

        int strides_per_strip = 2;
        float xscale = 1;
        
        for (int stripx = 0; stripx < 334; stripx++) {  // loop through each pixel in the strip
        
          int xpixel = stripx % stride;
          int stridenumber = stripx / stride; 
          
          // zigzag code
          if ((stridenumber & 1) == 0) { // we are going left to right
            xpos = xpixel * xscale;
            
          } else { // we are going right to left
            xpos = ((stride - 1)-xpixel) * xscale;
             
          }
       //  println ("Group1 getting pixel from "+xpos + "," + ypos);
          color c = offScreenBuffer.get((int) xpos, (int)ypos);
          strip.setPixel(c, stripx);
           if (stripx == stride || stripx == 333) { ypos=ypos+1;} // move to the next yPos of the buffer
          
        } //end x loop
       
      } //strips
    } // strips.size()


    ypos = 0;

    // Secondly, scrape for the middle panel of the display
    strips = registry.getStrips(2);

    if (strips.size() > 0) {

      for (Strip strip : strips) {   // for each strip (y-direction)

        int strides_per_strip = 2;
        float xscale = 1;
        
        for (int stripx = 0; stripx < 334; stripx++) {  // loop through each pixel in the strip
        
          int xpixel = stripx % stride;
          int stridenumber = stripx / stride; 
          
          // zigzag code
          if ((stridenumber & 1) == 0) { // we are going left to right
            xpos = xpixel * xscale;
            
          } else { // we are going right to left
            xpos = ((stride - 1)-xpixel) * xscale;
             
          }
          
          xpos=xpos+167;
     // println ("Group2 getting pixel from "+xpos + "," + ypos);
          color c = offScreenBuffer.get((int) xpos, (int)ypos);
          strip.setPixel(c, stripx);
           if (stripx == stride || stripx == 333) { ypos=ypos+1;} // move to the next yPos of the buffer
          
        } //end x loop
       
      } //strips
    } // strips.size()


    // Finally, scrape for the right hand panel of the display
    
    ypos = 0;

    strips = registry.getStrips(3);

    if (strips.size() > 0) {

      for (Strip strip : strips) {   // for each strip (y-direction)

        int strides_per_strip = 2;
        float xscale = 1;
        
        for (int stripx = 0; stripx < 334; stripx++) {  // loop through each pixel in the strip
        
          int xpixel = stripx % stride;
          int stridenumber = stripx / stride; 
          
          // zigzag code
          if ((stridenumber & 1) == 0) { // we are going left to right
            xpos = xpixel * xscale;
            
          } else { // we are going right to left
            xpos = ((stride - 1)-xpixel) * xscale;
             
          }
       //  println ("Group1 getting pixel from "+xpos + "," + ypos);
       xpos=xpos+167+167;
          color c = offScreenBuffer.get((int) xpos, (int)ypos);
          strip.setPixel(c, stripx);
           if (stripx == stride || stripx == 333) { ypos=ypos+1;} // move to the next yPos of the buffer
          
        } //end x loop
       
      } //strips
    } // strips.size()





  } // observer
} // scrape

