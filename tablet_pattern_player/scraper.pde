void scrape() {
  // scrape for the strips 501 x 24 (167 per panel)
  
  
  float xpos = 0, ypos = 0;
  patternPreviewBuffer.loadPixels();
  if (observer.hasStrips) {
    registry.startPushing();
    for(int panelIdx = 1; panelIdx < numPanels; panelIdx++) {

      List<Strip> strips = registry.getStrips(panelIdx);

      if (strips.size() > 0) {
        for (Strip strip : strips) {   // for each strip (y-direction)
          
          for (int stripx = 0; stripx < 334; stripx++) {  // loop through each pixel in the strip
          
            int xpixel = stripx % stride;
            int stridenumber = stripx / stride;             
            // zigzag code
            if ((stridenumber & 1) == 0) { // we are going left to right
              xpos = xpixel * xscale;
            } else { // we are going right to left
              xpos = ((stride - 1)-xpixel) * xscale;
            }
            // add 0-indexed multiplier of stride for xpos
            xpos = xpos + ((panelIdx - 1) * stride);
            //println ("Group" + panelIdx + " getting pixel from "+xpos + "," + ypos);
            color c = patternPreviewBuffer.get((int) xpos, (int)ypos);
            strip.setPixel(c, stripx);
            if (stripx == stride || stripx == 333) {
              ypos=ypos+1;
            } // move to the next yPos of the buffer
            
          } //end x loop
         
        } // for each strip
      } // strips.size() check for any strips

      // reset y scan
      ypos = 0;
    }
  } // observer
} // scrape