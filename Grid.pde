import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Date;

class Grid extends Sprite {
  ArrayList<Thumbnail> thumbs = new ArrayList<Thumbnail>();
  HashMap<String, ArrayList<String>> imageMap;
  int gridWidth;
  int cellWidth;
  int gridCols = 0;
  int gridRows = 0;
  Thumbnail mouseThumb;
  Thumbnail selectedThumb;
  PImage currentSlide;
  PhotoInfo currentSlideInfo;
  PVector currentSlidePos;
  float mx = 2.0; //Animation start speed multiplier
  int catFilter = -1;
  
  Grid(float x, float y, int gw, int cw, HashMap<String, ArrayList<String>> _imageMap) {
    super(x, y, 0);
    gridWidth = gw;
    cellWidth = cw;
    imageMap = _imageMap;
    calculateGridSize(imageMap.keySet().size());
    loadThumbnails();
  }
  
  boolean doneBouncing() { return true; }
  boolean onGround(){ return true; }
  boolean mouseIn() {
    if (mouseX >= position.x &&
        mouseX <= position.x + gridWidth &&
        mouseY >= position.y &&
        mouseY <= position.y + gridRows * cellWidth)
      return true;

    return false;
  }
  
  void setCategoryFilter(int cat) {
    catFilter = cat;
  }
  
  void bounce() {
    for (Thumbnail thumb : thumbs)
    {
      thumb.bounce(new PVector(random(-2 * mx, 2 * mx), random(-5 * mx, -1 * mx)), app.introBounce);
    }
  }
  
  boolean isAnimating() {
    for (Thumbnail thumb : thumbs)
    {
      if (thumb.animateLifeSpan > 0)
        return true;
    }
    
    return false;
  }
  
  int mouseThumbIndex() {
    if (mouseThumb == null) return -1;
    return mouseThumb.gridIndex;
  }

  int selectedThumbIndex() {
    if (selectedThumb == null) return -1;
    return selectedThumb.gridIndex;
  }

  void selectThumb(int thumbIndex) {
    Thumbnail prev = selectedThumb;
    currentSlide = null;
    selectedThumb = thumbs.get(thumbIndex);
    if (selectedThumb != null) {
      selectedThumb.animateCurve();
      //selectedThumb.loadThumbnail();
      app.data.view(selectedThumb.viewKey());
      app.data.loadDate(selectedThumb.viewKey());
      app.slideAlpha = 0;
      currentSlide = selectedThumb.getSlide();
      if (currentSlide != null) {
        if (currentSlide.width < currentSlide.height) {
          currentSlide = app.resizeImage(currentSlide, width/5, height);
        
          currentSlidePos = selectedThumb.position.copy();
          if (currentSlidePos.x + currentSlide.width > width)
            currentSlidePos.sub(new PVector(currentSlide.width - cellWidth, 0));
          
          int hAdjust = currentSlide.height < height ? app.graph.labelHeight : 0;
          if (currentSlidePos.y + currentSlide.height  > (height - hAdjust))
            currentSlidePos.sub(new PVector(0, currentSlidePos.y + currentSlide.height - (height - hAdjust)));
        }
        else {
          currentSlidePos = new PVector((width - currentSlide.width)/2, (height - app.graph.labelHeight - currentSlide.height)/2);
        }

        currentSlideInfo = app.data.getPhoto(selectedThumb.currentSlideName);
        //println("INFO:", currentSlideInfo);
      }
      
      if (prev != selectedThumb)
        app.graphHeight = 0;
    }
  }

  void update() {
    Thumbnail pmouseThumb = mouseThumb;
    for (Thumbnail thumb : thumbs)
    {
      thumb.offset = offset;
      if (thumb.mouseIn()) {
        mouseThumb = thumb;
        if (mouseThumb != pmouseThumb)
          mouseThumb.onMouseIn();
      }
      thumb.update();
    }
    
    if (app.particles.size() == 0 && app.graphHeight < app.graphHeightMax) {
      //Animate the graph 
      app.graphHeight += 8;
    }
  }
  
  void display() {    
    if (app.introComplete)
      app.graph.drawGraph();

    for (Sprite thumb : thumbs)
    {
      thumb.display();
    }
    
    drawSlide();
    
    if (mouseThumb != null)
      mouseThumb.display();
      
    if (selectedThumb != null)
      selectedThumb.display();
  }
  
  void drawSlide() {
    if (currentSlide == null)
      return;
      
    int tintColor = color(255);
    strokeWeight(4);
    stroke(app.textColor, app.slideAlpha);
    noFill();
    tint(tintColor, app.slideAlpha);
    image(currentSlide, currentSlidePos.x, currentSlidePos.y);
    if (currentSlide.width < currentSlide.height)
      rect(currentSlidePos.x, currentSlidePos.y, currentSlide.width, currentSlide.height, 8);
  }

  void reset() {
    currentSlide = null;
    app.graphHeight = 0;
    for (Thumbnail thumb : thumbs)
    {
      thumb.reset();
    }
  }
  
  void markAllViewed() {
    for (Thumbnail thumb : thumbs)
    {
      app.data.view(thumb.viewKey());
    }
  }
  
  void scrollLeft() {
    PVector go = offset.copy();
    go.x -= app.scrollRate;
    if (abs(go.x) + width > gridWidth)
      go.x = width - gridWidth;

    offset = go;
  }
  
  void scrollRight() {
    PVector go = offset.copy();
    go.x += app.scrollRate;
    if (go.x > 0)
      go.x = 0;

    offset = go;
  }
  
  void calculateGridSize(int totalImages) {
    gridCols = gridWidth / cellWidth;
    gridRows = ceil(totalImages / float(gridCols));
    
    println("Grid:" + gridRows + "X" + gridCols);
  }

  void loadThumbnails() {
    ArrayList<String> folders = new ArrayList<String>(imageMap.keySet());
    Collections.sort(folders, dateComparator);
    int index = 0;
    for (int i = 0; i < gridCols; i++) {
      for (int j = 0; j < gridRows; j++) {
        if (index < folders.size()) {
          ArrayList<String> imagesInFolder = imageMap.get(folders.get(index));
          String thumbnailFile = imagesInFolder.get(0);
          //println(thumbnailFile);
          thumbs.add(new Thumbnail(folders.get(index), thumbnailFile, i * cellWidth, j * cellWidth, cellWidth, index));
          index++;
        }
      }
    }
  }
}

Comparator<String> dateComparator = new Comparator<String>() {
    SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd-yyyy");

    @Override
    public int compare(String obj1, String obj2) {
        try {
            Date date1 = dateFormat.parse(obj1);
            Date date2 = dateFormat.parse(obj2);
            return date1.compareTo(date2);
        } catch (ParseException e) {
            // Handle parsing errors if necessary
            e.printStackTrace();
            return 0;
        }
    }
};
