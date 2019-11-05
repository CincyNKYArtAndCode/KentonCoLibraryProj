

int sonarSweepAge = 2000; // seconds * 1000
float sweepSpeed = 5.0;
  
//==================================
// Circle sweep data
//==================================

class SonarSweep {
  float centerX;
  float centerY;
  float radius;
  color clr;
  int   timeOfDeath;
  boolean alive;
  
  SonarSweep() {
    alive = false;
  }
  
  void delayStart(int beginTime) {
    alive = false;
    timeOfDeath = millis() + beginTime;
  }

  void initSweep() {
    centerX = random(10, width - 10);
    centerY = random(10, height - 10);
    radius = 8;
    clr = color(random(0,256), 255, 255);
    timeOfDeath = millis() + sonarSweepAge;
    alive = true;
  }
  
  void update() {
    radius += sweepSpeed;
    if(timeOfDeath < millis()) {
      initSweep();
    }
  }
  
  void draw() {
    if(!alive) return;
    noStroke();
    float circumference = TAU * radius;
    int divs = floor(circumference/10.0);
    float angleInc = TAU/divs;
    float angle = 0;
    beginShape(QUAD_STRIP);
    PImage img = kinect.getVideoImage();
    texture(img);
    for(int i = 0; i <= divs; ++i) {
      float x1 = centerX + cos(angle) * (radius - 2);
      float y1 = centerY + sin(angle) * (radius - 2);
      float x2 = centerX + cos(angle) * (radius + 2);
      float y2 = centerY + sin(angle) * (radius + 2);
      float tx1 = map(x1, 0, width, 0, img.width);
      float ty1 = map(y1, 0, height, 0, img.height);
      float tx2 = map(x2, 0, width, 0, img.width);
      float ty2 = map(y2, 0, height, 0, img.height);
      vertex(x1, y1, tx1, ty1);
      vertex(x2, y2, tx2, ty2);
      angle += angleInc;
    }
    endShape();
  }
}


class SonarSketch extends TimedSketch {
  int maxSweeps = 60;
  
  SonarSweep[] sweeps;

  SonarSketch(float runTime) {
    super(runTime);   
    sweeps = new SonarSweep[maxSweeps];
    for(int i = 0; i < maxSweeps; ++i) {
      sweeps[i] = new SonarSweep();
    } 
  }
  
  void setup() {
    beginRunning();
    int incStart = sonarSweepAge / maxSweeps;
    int startTime = 0;
    for(SonarSweep s : sweeps) {
      s.delayStart(startTime);
      startTime += incStart;
    }
    noStroke();
    colorMode(RGB);
  }
  
  void draw() {
    fill(0, 0, 128, 60);
    rect(0, 0, width, height);
    for(SonarSweep s : sweeps) {
      s.draw();
      s.update();
    } 
  }
}
