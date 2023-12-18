class Particle extends Sprite {
  color col;
  float lifespan;
  float fsize;
  String label;

  Particle(float x, float y, color c, float mx, float size, String t, PVector v) {
    super(x, y, (int)size);
    fsize = size;
    label = t;
    position = new PVector(x, y);
    if (v == null)
      velocity = new PVector(random(-2 * mx, 2 * mx), random(-5 * mx, -1 * mx)); // Initial random velocity
    else
      velocity = v;
    col = c;
    lifespan = 255;//random(100, 255);
  }

  void update() {
    velocity.add(gGravity); // Add gravity
    position.add(velocity);
    lifespan = max(0, --lifespan); // Decrease lifespan
    //fsize -= .1;
  }

  void display() {  
    if (label.equals("")) {
      rectMode(CENTER);
      noStroke();
      fill(col);//, lifespan);
      rect(position.x, position.y, fsize, fsize);
      rectMode(CORNER);
    }
    else {
      textFont(app.robotoCB);
      noStroke();
      fill(col, map(lifespan, 0, 255, 128, 255));
      textSize(size);
      textAlign(LEFT);
      text(label, position.x, position.y, width - position.x, size + 4);
      textFont(app.roboto);
    }
  }

  boolean isDead() {
    return lifespan == 0;
  }
}
