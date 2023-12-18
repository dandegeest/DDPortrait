import java.util.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.DecimalFormat;

class Application {
  HashMap<String, ArrayList<String>> imageMap = new HashMap<String, ArrayList<String>>();
  PFont roboto;
  PFont robotoCB;
  PFont tetris;
  Grid grid;
  Graph graph;
  color backgroundColor = color(40);
  PImage backgroundImg;
  // Background
  color textColor = #F9F700;
  int thumbSize = 50;
  float alpha = 0;
  float slideAlpha = 0;
  float thumbAlpha = 225;
  float textAlpha = 0;
  int gridHeight = 600;
  int graphHeight = 0;
  int graphHeightMax = 340;
  int scrollRate = thumbSize;
  int introBounce = 5;
  boolean introComplete = false;
  boolean introSelect = true;
  int maxCurvePoints = 300;
  boolean debug = false;
  Database data;
  //String photoSet = "TwoDays";
  //String photoSet = "TwoMonths";
  String photoSet = "Full";
  ArrayList<Particle> particles = new ArrayList<Particle>();
 
  Application() {
    hint(ENABLE_STROKE_PURE);
    println(sketchPath(""));
    tetris = createFont("fonts\\tetris.ttf", 18, true);
    roboto = createFont("fonts\\Roboto-Bold.ttf", 16, true);
    robotoCB = createFont("fonts\\RobotoCondensed-Bold.ttf", 16, true);    textFont(roboto);
    data = new Database();
    graphHeightMax = max(graphHeightMax, height - gridHeight + 40);
    graph = new Graph(0, gridHeight, width, height - gridHeight);
    
    //backgroundImg = resizeImage(loadImage(sketchPath("") + "background.png"), width, height);
    
    buildImageMap(sketchPath("") + "photos" + photoSet);
    println("Folders:" + imageMap.size());
    println("Application Setup Done");
  }
  
  void load() {
    grid = new Grid(0, 0, 2300, thumbSize, imageMap);
  }
  
  void intro() {
    textFont(tetris);
    color introTextColor = textColor; //color(128, 128, 255);
    if (!introComplete) {
      textAlpha = min(textAlpha + 1, 245);
    }
    else {
      rotate(0);
      textAlpha = max(textAlpha - 1, 0);
    }
  
    textAlign(CENTER);
    textSize(200);
    fill(introTextColor, textAlpha);
    stroke(introTextColor, textAlpha);
    text("Work to Live", 0, 40, width, 400);
    fill(introTextColor, textAlpha - 10);
    stroke(introTextColor, textAlpha - 10);
    textSize(100);
    String story = "A 2 Year Financial $tory";
    int textStep = (int)map(textAlpha, 0, 245, 0, story.length());
    text(story.substring(0, textStep), 0, 200, width, 400);   
    textSize(50);
    if (textStep >= 24)
      text("Data Self-Portrait by Dan DeGeest", 0, 300, width, 400);   
    
    if (introComplete && grid.catFilter != -1) {
      introTextColor = #F9B300;
      fill(introTextColor, 225);
      stroke(introTextColor, 225);
      textSize(100);
      text(data.getCategory(grid.catFilter, true), 0, gridHeight - 100, width, 150);   
    }
    
    if (!grid.isAnimating() && !introComplete) {
      introComplete = true;
      graphHeight = 0;
    }
      
    if (introComplete && introSelect) {
      grid.selectThumb(285);
      introSelect = false;
    }
    
    textFont(roboto);
  }

  void buildImageMap(String folderPath) {
    File folder = new File(folderPath);
    File[] files = folder.listFiles();
  
    if (files != null) {
      for (File file : files) {
        if (file.isDirectory()) {
          //println("Found folder " + file.getName());
          imageMap.put(file.getName(), new ArrayList<String>());
          //println(imageMap.size());
          buildImageMap(file.getAbsolutePath());
        } else {
          if (file.getName().toLowerCase().endsWith(".jpg") || file.getName().toLowerCase().endsWith(".png")) {
            Path path = Paths.get(file.getParent());
            String folderName = path.getFileName().toString();
            imageMap.get(folderName).add(file.getAbsolutePath());
          }
        }
      }
    }
  }
  
  PImage resizeImage(PImage img, int targetWidth, int targetHeight) {
    // Calculate the aspect ratio of the original image
    float aspectRatio = float(img.width) / img.height;
  
    // Calculate the new dimensions while maintaining the aspect ratio
    int newWidth, newHeight;
    if (targetWidth / aspectRatio <= targetHeight) {
      // Resize based on width to fit within the target dimensions
      newWidth = targetWidth;
      newHeight = int(targetWidth / aspectRatio);
    } else {
      // Resize based on height to fit within the target dimensions
      newWidth = int(targetHeight * aspectRatio);
      newHeight = targetHeight;
    }
  
    // Create a new PImage with the calculated dimensions
    PImage resizedImage = createImage(newWidth, newHeight, ARGB);
  
    // Copy the original image to the resized image
    resizedImage.copy(img, 0, 0, img.width, img.height, 0, 0, newWidth, newHeight);
  
    //println("Resize:" + resizedImage.width + "x" + resizedImage.height);
    return resizedImage;
  }
  
  int blendColors(color c1, color c2) {
    int r1 = (int)red(c1);
    int g1 = (int)green(c1);
    int b1 = (int)blue(c1);
    int a1 = (int)alpha(c1);
  
    int r2 = (int)red(c2);
    int g2 = (int)green(c2);
    int b2 = (int)blue(c2);
    int a2 = (int)alpha(c2);
  
    int r = (r1 * (255 - a2) + r2 * a2) / 255;
    int g = (g1 * (255 - a2) + g2 * a2) / 255;
    int b = (b1 * (255 - a2) + b2 * a2) / 255;
    int a = a1 + a2 - a1 * a2 / 255;
  
    return color(r, g, b, a);
  }
  
  color inverseHSBColor(color originalColor) {
    float hue = hue(originalColor);
    float saturation = saturation(originalColor);
    float brightness = brightness(originalColor);
    
    // Calculate the inverted hue by adding 180 degrees and wrapping around
    float invertedHue = (hue + 180) % 360;
    
    // Create and return the inverted color in HSB format
    return color(invertedHue, saturation, brightness);
  }
  
  void drawFrameRate() {
    fill(0, 255, 100);
    textSize(24);
    textAlign(LEFT);
    text("Frame Rate: " + nf(frameRate, 0, 2) + " FPS", 20, 40);
  }
  
  void drawImageInverted(PImage img, int xpos) {
    //Draw upside down
    pushMatrix();
    scale(1, -1); // Invert the Y-axis
    image(img, xpos, -(img.height)); // + 70
    popMatrix();
  }
}
