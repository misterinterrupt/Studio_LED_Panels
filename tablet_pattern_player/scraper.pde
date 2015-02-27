void scrape() {
  // scrape for the strips 501 x 24 (167 per panel)
  
  
  float xpos = 0, ypos = 0;
  patternPreviewBuffer.loadPixels();
  if (observer.hasStrips) {
    registry.startPushing();

    // each set of panels
    for(int setIdx=0; setIdx<panelSets.length; setIdx++) {

      // index into the {start,end} panel sets and scrape for those panels in order
      // we will index into the panelSetBuffers as well, to get the right stuff from them
      int panelSetStart = panelSets[setIdx][0]; // 4
      int panelSetEnd = panelSets[setIdx][1]; // 6
      int panelSetLength = panelSetEnd - panelSetStart + 1; // inclusive so add 1 to get the count from start to end
      for(int panelIdx = 0; panelIdx < panelSetLength+1; panelIdx++) {

        // index + panel start gives us the actual group
        List<Strip> strips = registry.getStrips(panelIdx + panelSetStart);

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
              color c = panelSetBuffers[setIdx].pixels[(int) xpos * (int) ypos];
              
              if(debug){
                debugBuffers[setIdx].setPixel(c);
              } else {
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