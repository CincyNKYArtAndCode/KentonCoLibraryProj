
int numLines = 50;    // # lines vertically
int numLineSegs = 200; // # segments horizontally

float depthLineOffset = 40.0f;

int numSquares = 1000;
ParticleSystem flowUpSystem;

//==================================
// Calculated once when sketch starts
//==================================
float lineSpacingY; // Y spacing between each line
float segSpacingX; // X spacing between each line

PGraphics theTexture;

PImage sprites;
int spriteWidth = 64;
int spriteHeight = 64;
int spriteCols = 0;
int spriteRows = 0;
int numSprites = 0;

class FlowUpParticle extends Particle {
  
  float sz;
  color clr;
  float spriteX;
  float spriteY;
  
  FlowUpParticle() {
    super(0, 0);
    init();
  }
  
  void init() {
    sz = random(32, 64); //<>//
    posX = random(sz/2, width - sz/2);
    posY = random(height + sz/2, height + 40);
    clr = color(random(0,256), 255, 255);
    velX = 0;
    velY = -random(2, 10);
    int spriteNum = int(random(0, numSprites));
    spriteX = spriteNum % spriteCols * spriteWidth;
    spriteY = spriteNum / spriteCols * spriteHeight;
  }
  
  void draw() {
    float hsz = sz/2.0;
    theTexture.vertex(posX - hsz, posY - hsz, spriteX, spriteY); //<>//
    theTexture.vertex(posX + hsz, posY - hsz, spriteX + spriteWidth, spriteY);
    theTexture.vertex(posX + hsz, posY + hsz, spriteX + spriteWidth, spriteY + spriteHeight);
    theTexture.vertex(posX - hsz, posY + hsz, spriteX, spriteY + spriteHeight);
  }
  
  void update() {
    posX += velX;
    posY += velY;
    if(posY + sz < 0) {
      init();
    }
  }
}

class FlowUpSketch extends TimedSketch {
  FlowUpSketch(float runTime) {
    super(runTime);
    
    theTexture = createGraphics(width, height, P2D);
    
    sprites = loadImage("Pirate Sprite3.png");
    
    spriteCols = sprites.width / spriteWidth;
    spriteRows = sprites.height / spriteHeight;
    numSprites = spriteCols * spriteRows;
    
    colorMode(HSB);
    flowUpSystem = new ParticleSystem(numSquares);
    
    for(int idx = 0; idx < numSquares; ++idx) {
      flowUpSystem.setParticle(idx, new FlowUpParticle());
    }
    
    // calulate start variables
    lineSpacingY = float(height)/(numLines + 1);
    segSpacingX = float(width)/numLineSegs;
  }
  
  void setup() {
    beginRunning();
  }

  void drawFlowUp() {
    theTexture.beginDraw();
    theTexture.noStroke();
    
    theTexture.colorMode(RGB);
    theTexture.fill(255, 255, 255, 128);
    theTexture.rectMode(CORNER);
    theTexture.rect(0, 0, theTexture.width, theTexture.height);
    theTexture.beginShape(QUADS);
    theTexture.texture(sprites);
    flowUpSystem.draw();
    theTexture.endShape();
    
    theTexture.endDraw();
  }
  
  void draw() {
    drawFlowUp();
    flowUpSystem.update();
    
    fill(0, 0, 0);
    rect(0, 0, width, height);
    noStroke();
    fill(255,255,255);
    
    for(int lineNum = 0; lineNum < numLines; ++lineNum) {
      beginShape(QUAD_STRIP);
      texture(theTexture);
      for(int seg = 0; seg < numLineSegs; ++seg) {
        float ptX = seg*segSpacingX;
        float ptY = (lineNum + 1)*lineSpacingY;
        float offsetY = GetScaledDepth(ptX, ptY) * depthLineOffset/2;
        vertex(ptX, ptY - offsetY, ptX, ptY - offsetY);
        vertex(ptX, ptY + offsetY, ptX, ptY + offsetY);
      }
      endShape();
    }
  }
}
