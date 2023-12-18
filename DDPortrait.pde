Application app;

void setup() {
  size(1250, 616);
  fullScreen();

  app = new Application();
  app.load();
  if (app.photoSet == "Full")
    app.grid.bounce();
}

void draw() {
  noTint();
  background(app.backgroundColor);

  app.intro();
  app.grid.update();
  app.grid.display();    

  if(app.particles.size() > 0 ||
    (app.grid.selectedThumb != null && ceil(app.grid.selectedThumb.curveAnim) < app.maxCurvePoints)) {
    app.slideAlpha = min(app.slideAlpha + 5, 245);
    app.thumbAlpha = max(app.thumbAlpha - 5, 15);
  }
  else {
    app.slideAlpha = max(app.slideAlpha - 5, 0);
    app.thumbAlpha = min(app.thumbAlpha + 5, 225);
  }
  
  //Update all currently animating particles
  for (int i = app.particles.size() - 1; i >= 0; i--) {
    Particle p = app.particles.get(i);
    p.update();
    p.display();
    
    if (p.isDead()) {
      app.particles.remove(i);
    }
  } 
  
  if (app.debug)
    app.drawFrameRate();
    
  //saveFrame("frames\\f####.tiff");
}

void mouseWheel(MouseEvent event) {
  // Adjust the scale factor based on the mouse wheel movement
  float delta = event.getCount();
  if (keyPressed) {
    app.alpha += delta * 5;
    if (app.alpha > 255) app.alpha = 0;
    if (app.alpha < 0) app.alpha = 255;
  }
  else {
    if (delta < 0) app.grid.scrollRight();
    if (delta > 0) app.grid.scrollLeft();
  }
}

void mousePressed() {
  if (!app.introComplete) return;
    
  if (mouseButton == LEFT) {
    if (app.grid.mouseIn()) {
      app.grid.selectThumb(app.grid.mouseThumbIndex());
            
      if (app.data.currentTransactions.size() > 0) {
        for (int i = 0; i < app.data.currentTransactions.size(); i++) {
          Transaction t = app.data.currentTransactions.get(i);
          int catIndex = app.data.getCategoryIndex(t.category);
          if (app.grid.catFilter == -1 || catIndex == app.grid.catFilter) {
            color shapeColor = app.data.getCategoryColor(t.category);         
            float partCount = ceil(abs(t.amount) / app.data.getDailyTotal() * 100.0);
            if (t.category.equals("Deposit")) {
              partCount = ceil(abs(t.amount) / app.data.getDepositTotal() * 100.0) * 5;
            }
            
            partCount = 0;
            for (int p = 0; p < partCount; p++) {
              Particle part = new Particle(
                mouseX,
                mouseY,
                shapeColor,
                random(6.0),
                36,
                app.data.getCategory(app.data.getCategoryIndex(t.category), true),
                null);
              app.particles.add(part);
            }
          }
        }
      }
      else {
        String win = "The best things in life are free!|free|free|free|free|free|free|free|free|free|free|free";
        //workToLive = 150;
        String[] msg = win.split("\\|");
        for (int p = 0; p < msg.length; p++) {
          Particle part = new Particle(
          p == 0 ? mouseX : mouseX + 480,
          mouseY,
          color(128, 128, 255),
          random(6.0),
          48,
          msg[p],
          p == 0 ? new PVector(0, random(-5 * 3, -1 * 3)) : null);
          app.particles.add(part);
        }
      }
    }
    
    if (app.graph.mouseIn()) {
      if (app.grid.currentSlide != null)
        app.graphHeight = 0;
        
      app.grid.selectedThumb = null;
      app.grid.currentSlide = null;
      
      if (app.grid.catFilter == app.graph.hoveredCategory ||
          app.graph.hoveredCategory == app.data.getCategoryIndex("Total"))
        app.grid.catFilter = -1;
      else
        app.grid.catFilter = app.graph.hoveredCategory;
    }
  } 
  else
    app.grid.currentSlide = null;
}

void keyPressed() {
  if (keyCode == LEFT) {
    app.grid.scrollLeft();
  }
  
  if (keyCode == RIGHT) {
    app.grid.scrollRight();
  }
  
  if (keyCode == ENTER) {
    saveFrame("screens\\photoTile####.png");
  }
}
