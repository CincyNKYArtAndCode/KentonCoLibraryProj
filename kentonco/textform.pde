
int maxNumWordsToDisplay = 400;
float textSpeed = 1;
int textLifeTime = 5000; // seconds * 1000
int textFadeTime = 500; // Should be < textLifeTime
int minTextSize = 8;
int maxTextSize = 30;

String[] wordArray;

class TextData extends Particle {
  String theText;
  color textColor;
      
  int timeOfDeath;
  
  boolean alive;
  TextData next;
  
  TextData() {
    super(0, 0);
    timeOfDeath = 0;
    alive = false;
  }
  
  void reset() {
    timeOfDeath = 0;
    alive = false;
  }

  void initText(float x, float y) {
    int randWordIdx = floor(random(0, wordArray.length));
    theText = wordArray[randWordIdx];
    
    posX = x;
    posY = y;
    float angle = random(0, TAU);
    velX = cos(angle) * textSpeed;
    velY = sin(angle) * textSpeed;
    timeOfDeath = millis() + textLifeTime;
    textColor = color(random(0,256),255, 255);
    alive = true;
  }
  
  void draw() {
    if(alive) {
      float s = constrain(float(timeOfDeath - millis())/textFadeTime, 0, 1);
      color drawColor = lerpColor(color(hue(textColor),255,0), textColor, s);
      float size = lerp(minTextSize, maxTextSize, GetScaledDepth(posX, posY)); 
      fill(drawColor);
      textAlign(CENTER, CENTER);
      textSize(size);
      text(theText, posX, posY);
    }
  }
  
  void update() {
    if(alive) {
      posX += velX;
      posY += velY;
      if(timeOfDeath < millis()) {
        alive = false;
        next = freeTextList;
        freeTextList = this;
      }
      
      if( GetScaledDepth(posX, posY) < 0.05) {
        timeOfDeath -= 100;
      }
    }
  }
}

TextData freeTextList;
  
class TextSketch extends TimedSketch {
  
  ParticleSystem wordSystem;

  TextSketch(float runTime) {
    super(runTime);

    wordArray = loadStrings("positive-words.txt");  
    
    wordSystem = new ParticleSystem(maxNumWordsToDisplay);
    
    TextData prevTD = null;
    for(int idx = 0; idx < maxNumWordsToDisplay; ++idx) {
      freeTextList = new TextData();
      freeTextList.next = prevTD;
      prevTD = freeTextList;
      wordSystem.setParticle(idx, freeTextList);
    }
  }
  
  void setup() {
    wordSystem.reset();
    TextData prevTD = null;
    for(int idx = 0; idx < maxNumWordsToDisplay; ++idx) {
      freeTextList = (TextData)wordSystem.getParticle(idx);
      freeTextList.next = prevTD;
      prevTD = freeTextList;
    }
    
    beginRunning();
    colorMode(HSB);
    updateAcceptableDepthScan();
  }
  
  void addText() {
    int createCount = 0;
    while(freeTextList != null && createCount < 5) {
      TextData newTD = freeTextList;
      int posIdx = floor(random(0, numAcceptablePoints));
      float x = map(acceptablePosX[posIdx], 0, kinect.width, 0, width);
      float y = map(acceptablePosY[posIdx], 0, kinect.height, 0, height);
      newTD.initText(x, y);
      freeTextList = newTD.next;
      newTD = null;
      ++createCount;
    }
  }
  
  void draw() {
    fill(0);
    rect(0, 0, width, height);
    addText();
    wordSystem.draw();
    wordSystem.update();
    updateAcceptableDepthScan();
  }
}
