void scrape() {
  // scrape for the strips 501 x 24 (167 per panel)
  // scrape for the strips 668 x 24 (167 per panel)  
  
  float xpos = 0, ypos = 0;
  patternPreviewBuffer.loadPixels();
  if (observer.hasStrips) {
    registry.startPushing();

    // each set of panels
    for(int setIdx=0; setIdx<panelSets.length; setIdx++) {

      // index into the {start,end} panel sets and scrape for those panels in order
      // we will index into the panelSetBuffers as well, to get the right stuff from them
      int panelSetFirst = panelSets[setIdx][0]; // e.g. 1
      int panelSetLast = panelSets[setIdx][1]; // e.g. 2
      int panelSetLength = (panelSetLast - panelSetFirst) + 1; // e.g. 2  number of panels in the set inclusive
      // println("panelSet " + setIdx);
      // println("panelSetFirst "+ panelSetFirst);
      // println("panelSetLast "+ panelSetLast);
      // println("panelSetLength "+ panelSetLength);

      // for each individual panel in the current set
      for(int panelIdx = 0; panelIdx < panelSetLength; panelIdx++) {
        // index + panel start gives us the actual group
        int groupIdx = (panelIdx + panelSetFirst);
        // println(panelIdx + " group: " + groupIdx);
        List<Strip> strips = registry.getStrips(groupIdx);

        if (strips.size() > 0) {
          for (Strip strip : strips) {   // for each strip (y-index)
            
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
              xpos = xpos + (panelIdx * stride);
              //println ("Set: " + setIdx + " Group: " + groupIdx + " stride:" + (panelIdx * stride) + " getting pixel from "+xpos + "," + ypos);
              //int pixIndex = (int) xpos + (stride * (int) ypos);
              //color c = patternPreviewBuffer.pixels[pixIndex];)
              if(setIdx == 0) {
                color c = set1Buffer.get((int) xpos, (int) ypos);      
                strip.setPixel(c, stripx);          
              } else if (setIdx == 1) {
                color c = set2Buffer.get((int) xpos, (int) ypos);
                strip.setPixel(c, stripx);
              }

              if (stripx == stride || stripx == 333) {
                ypos=ypos+1;
              } // move to the next yPos of the buffer
              
            } //end x loop
           
          } // for each strip
        } // strips.size() check for any strips
        // reset y scan
        ypos = 0;
      }
    }
  } // observer
} // scrape
