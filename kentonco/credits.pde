
class TextActor {
  String theTxt;
  float txtSize;
  float beginScale;
  float curScale;
  float posX;
  float posY;
  
  void setup() {
    curScale = beginScale;
  }
  
  void draw() {
    fill(255, 255, 255);
    textAlign(CENTER, CENTER);
    translate(posX, posY);
    scale(curScale);
    textSize(txtSize);
    text(theTxt, 0, 0);
  }
  
  void update() {
    curScale = curScale + (1 - curScale) * 0.08;
  }
}

class CreditsSketch extends TimedSketch {

  float theScale = 16;
  
  CreditsSketch(float runTime) {
    super(runTime);
  }
  
  void setup() {
    beginRunning();
    colorMode(RGB);
  }
  
  void draw() {
    fill(0, 0, 0, 6);
    
    rect(0, 0, width, height);
    noStroke();
  }
  
  void update() {
  }
}
