class Thumbnail extends Bouncy {
  String thumbFolder;
  String thumbFilename;
  PImage thumbnail;
  PVector gridPosition;
  int gridIndex;
  int currentSlideNumber = 0;
  String currentSlideName;
  float totalSpent = 0;
  ArrayList<Transaction> transactions;
  float curveAnim = app.maxCurvePoints;

  Thumbnail(String folder, String filename, float x, float y, int s, int gi) {
    super(x, y, s);
    thumbFolder = folder;
    thumbFilename = filename;
    gridPosition = position.copy();
    size = s;
    gridIndex = gi;
    
    transactions = app.data.loadDate(viewKey());
    setTotalSpent(app.data.getDailyTotal());
  }
  
  boolean onGround()
  {
    return position.y + size > height;
  }

  void onMouseIn() {}
  
  void loadThumbnail() { 
    if (thumbnail == null)
      thumbnail = cropImageToSquare(loadImage(thumbFilename), size);
  }
  
  void bounce(PVector velo, int bounces) {
    velocity = velo;
    position = position.copy();//gridPosition.copy();
    animateLifeSpan = bounces;
  }
  
  void animateCurve() {
    if (transactions.size() == 0)
      return;
    curveAnim = 0;
  }
  
  int numberOfSlides() {
    return app.grid.imageMap.get(thumbFolder).size();
  }
  
  void reset() {
    app.data.unview(viewKey());
  }
  
  void setTotalSpent(float amount) { totalSpent = amount; }
  
  PImage getSlide() {  
    ArrayList<String> imagesInFolder = app.grid.imageMap.get(thumbFolder);
    if (currentSlideNumber == numberOfSlides()) {
      currentSlideName = "";
      currentSlideNumber = 0;
    }
    
    currentSlideName = imagesInFolder.get(currentSlideNumber);
    PImage slide = app.resizeImage(loadImage(currentSlideName), width, height); 
    currentSlideNumber++;
    return slide;
  }
    
  void update() {
    if (animateLifeSpan > 0) {
      super.update();
    }
    else {
      position = new PVector(gridPosition.x + offset.x, gridPosition.y + offset.y);
    }
  }
  
  void display() {
    noStroke();
    color borderColor = color(128, 128, 255);
    if (viewKey().contains("2021"))
      borderColor = color(128, 255, 255);
    if (viewKey().contains("2023"))
      borderColor = color(255, 128, 255);

    //#8da9c4
    fill(borderColor, mouseY < app.gridHeight ? map(mouseProximity(), app.grid.cellWidth * 2.50, 0, 0, 225/*app.thumbAlpha*/) : 0);
    rect(position.x, position.y, size, size);
    strokeWeight(2);
    stroke(borderColor, mouseIn() ? 255 : min(96, app.thumbAlpha));
    
    noFill();
    rect(position.x, position.y, size-1, size-1, 0);

    //if (app.data.viewed(viewKey())) {
    //  if (thumbnail != null) {
    //    image(thumbnail, position.x, position.y);
    //  }
    //}

    if (animateLifeSpan < 1) {
      for (int c = 0; c < app.data.categories.length; c++) {
        String cat = app.data.getCategory(c,false);
        float dayTotalForCat = app.data.getDayTotalForCategory(cat, transactions);

        if ((app.grid.catFilter == -1 || app.grid.catFilter == c) && dayTotalForCat > 0) {
          noStroke();
          fill(app.data.shadesOfRed[c], max(app.thumbAlpha, 40));
          rect(position.x + 2 + (c % 4) * 12, position.y + 2 + (c / 4) * 12, 12, 12);
          if (app.grid.catFilter == c || gridIndex == app.grid.selectedThumbIndex()) {
            drawCurve(c, dayTotalForCat);
          }
        }
      }
      
      if (floor(curveAnim) < app.maxCurvePoints) {
        float r = min(app.maxCurvePoints, totalSpent) / app.maxCurvePoints;
        curveAnim += r;
      }
      else curveAnim = app.maxCurvePoints;
    }
        
    float indicator = map(numberOfSlides(), 0, 8, 4,12);
    if (indicator > 0 && animateLifeSpan < 2) { 
      noStroke();
      fill(borderColor, mouseIn() ? 255 : min(96, app.thumbAlpha));
      ellipse(position.x + indicator/2, position.y + indicator/2, indicator, indicator);
    }       

    if (mouseIn() || gridIndex == app.grid.selectedThumbIndex() || (int)random(1,3) == animateLifeSpan) {
      color textColor = #FFFFFF;//app.textColor;
      fill(textColor);
      stroke(textColor);
      textAlign(CENTER);
      textSize(14);
      text(viewKey().replace("/", "\n"), position.x + 2, position.y + 2, size-2, size-2);
    }
  }
  
  void drawCurve(int catIndex, float dayTotalForCat) {
    color strokeColor = app.data.shadesOfRed[catIndex];
    noFill();
    if (app.grid.catFilter != -1 && mouseIn())
      strokeColor = color(#FFDD89);
      
    PVector catLoc = app.graph.getCategoryLoc(catIndex);
    PVector p = new PVector(position.x + 2 + (catIndex % 4) * 12, position.y + 2 + (catIndex / 4) * 12);
    stroke(strokeColor);
    bezier(p.x, p.y, 40, 40, 360, 360, catLoc.x, catLoc.y);
    int steps = min(floor(dayTotalForCat), app.maxCurvePoints);
    for (int i = 0; i <= steps; i++) {
      float t = i / float(steps);
      float x = bezierPoint(p.x, 40, 360, catLoc.x, t);
      float y = bezierPoint(p.y, 40, 360, catLoc.y, t);
      if (floor(curveAnim) == i || i == steps && floor(curveAnim) >= steps) {
        noStroke();
        fill(app.textColor, 225);
        ellipse(x, y, 18, 18);
      }
      else {
        noFill();
        stroke(strokeColor);//, max(app.thumbAlpha, 40));
        ellipse(x, y, 6, 6);
      }
    }
  }
  
  String viewKey() {
    return thumbFolder.replace("-", "/");
  }
  
  PImage cropImageToSquare(PImage img, int thumbSize) {
    // Calculate the dimensions for cropping
    int cropX, cropY, cropWidth, cropHeight;
  
    if (img.width > img.height) {
      // Image is wider than tall
      cropWidth = img.height;
      cropHeight = img.height;
      cropX = (img.width - cropWidth) / 2;
      cropY = 0;
    } else {
      // Image is taller than or square
      cropWidth = img.width;
      cropHeight = img.width;
      cropX = 0;
      cropY = (img.height - cropHeight) / 2;
    }
  
    // Create a new PImage by cropping the original image
    PImage croppedImage = img.get(cropX, cropY, cropWidth, cropHeight);
    croppedImage.resize(thumbSize, thumbSize);
  
    return croppedImage;
  }  
}
