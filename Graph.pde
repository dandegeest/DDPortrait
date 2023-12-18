class Graph extends Sprite {
  int graphWidth;
  int graphHeight;
  int hoveredCategory = -1;
  int labelHeight = 16;
  
  Graph(float x, float y, int w, int h) {
    super(x, y, w);
    graphWidth = w;
    graphHeight = h;
  }
  
  boolean doneBouncing() { return true; }
  boolean onGround(){ return true; }
  boolean mouseIn() {
    if (mouseX >= position.x &&
        mouseX <= position.x + graphWidth &&
        mouseY >= position.y &&
        mouseY <= position.y + graphHeight)
      return true;

    return false;
  }
  
  PVector getCategoryLoc(int category) {
    int barWidth = floor(width / app.data.categories.length);
    int padding = floor((width - barWidth * app.data.categories.length)/2);
    return new PVector(padding + category * barWidth + barWidth/2, height - labelHeight/2);
  }

  void drawGraph() {
    hoveredCategory = -1;
    noStroke();
    fill(0, 200);
    rect(0, position.y + graphHeight - labelHeight, graphWidth, labelHeight, 8);
    
    float[] values = new float[app.data.categories.length]; 
    for (int c = 0; c < app.data.categories.length; c++) {
      if (app.grid.selectedThumb != null) { 
        values[c] = abs(app.data.getDayTotalForCategory(app.data.getCategory(c, false), null));
        if (c == app.data.getCategoryIndex("Total"))
          values[c] = app.data.getDailyTotal();
      }
      else { 
        values[c] = abs(app.data.getTotalForCategory(app.data.getCategory(c, false)));
      }
    }

    int maxBarHeight = app.graphHeight; // Maximum height of the bars
    int barWidth = floor(width / app.data.categories.length);
    int padding = floor((width - barWidth * app.data.categories.length)/2);

    color borderColor = color(128, 128, 255);
    for (int c = 0; c < app.data.categories.length; c++) {                                                                                                                                                                                                             
      String category = app.data.getCategory(c, true);
      //Bar
      int barHeight = 0;
      if (values[c] != 0)
        barHeight = int(map(values[c], 0, max(values), 0, maxBarHeight));    
      strokeWeight(4);
      if (mouseX > padding + c * barWidth && mouseX < padding + c * barWidth + barWidth && mouseY > app.gridHeight) {
        hoveredCategory = c;
        stroke(borderColor);
      }
      else
        stroke(borderColor, 128);
  
      if (app.particles.size() == 0 &&
          (app.grid.catFilter == -1 ||
           app.grid.catFilter == c  ||
           app.data.getCategoryIndex("Deposit") == c ||
           app.data.getCategoryIndex("Total") == c)) {
        fill(app.data.shadesOfRed[c], 225);
        rect(padding + c * barWidth, position.y + graphHeight - barHeight - labelHeight, barWidth, barHeight, 20, 20, 0, 0);
      }

      //Category Nam
      textAlign(CENTER);
      textSize(17);
      color textColor = color(128);
      if (values[c] > 0 || c == hoveredCategory)
        textColor = color(app.textColor);      
      if (c == app.grid.catFilter)
        textColor = #F9B300;        
      stroke(textColor, c == hoveredCategory ? 255 : 220);
      fill(textColor, c == hoveredCategory ? 255 : 220);
      text(category, padding + c * barWidth, height - labelHeight, barWidth, 18);
      //Category Location Dot
      noStroke();
      fill(app.data.shadesOfRed[c], 128);
      ellipse(getCategoryLoc(c).x, getCategoryLoc(c).y, 4, 4);
    }  
  }  
}
