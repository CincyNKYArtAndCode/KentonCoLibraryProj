
float drag = 0.05;
float scaleVel = 0.5;
float rtnEasing = 0.05;
int maxParticles = 2000;

float scrnRgnWidth;
float scrnRgnHeight;
float imgRgnWidth;
float imgRgnHeight;

ParticleSystem particleSys;

class LogoParticle extends Particle {
  float orgnX;
  float orgnY;
  float texX;
  float texY; 
  
  LogoParticle(float x, float y, float tx, float ty) {
    super(x, y);
    orgnX = x;
    orgnY = y;
    texX = tx;
    texY = ty;   
  }
  
  void reset() {
    posX = orgnX;
    posY = orgnY;
    velX = 0;
    velY = 0;
  }
  
  void draw() {
    vertex(posX, posY, texX, texY);
    vertex(posX + scrnRgnWidth, posY, texX + imgRgnWidth, texY);
    vertex(posX + scrnRgnWidth, posY + scrnRgnHeight, texX + imgRgnWidth, texY + imgRgnHeight);
    vertex(posX, posY + scrnRgnHeight, texX, texY + imgRgnHeight);
  }
  
  void update() { 
    // update the particle position
    posX += velX;
    posY += velY;
    
    // When particle gos off the screen
    // then bounce
    if(posX < 0) {
      posX = -posX;
      velX = -velX;
    }
    
    if(posX >= width) {
      posX = width - posX;
      velX = -velX;
    }
    
    if(posY < 0) {
      posY = -posY;
      velY = -velY;
    }
    
    if(posY >= height) {
      posY = height - posY;
      velY = -velY;
    }
    
    // update the particle velocity
    // drag slows the paricle down
    velX = velX - drag * velX;
    velY = velY - drag * velY;
    
    // update the velocity with optical flow
    // velocity
    if(posX > 0 && posX < width && posY > 0 && posY < height) {
      int fgx = int(map(posX, 0, width, 0, opencv.width));
      int fgy = int(map(posY, 0, height, 0, opencv.height));
      
      PVector flowAt = opencv.getFlowAt(fgx, fgy);
      
      velX = constrain(velX + flowAt.x * scaleVel, -100, 100);
      velY = constrain(velY + flowAt.y * scaleVel, -100, 100); 
    }
    
    // When velocity drops below threshold then
    // move particle back to the origin
    float velMag = mag(velX, velY);
    if(velMag < 2) {
      
      float diffX = orgnX - posX;
      float diffY = orgnY - posY;
      
      if(diffX + diffY > 4) {
        posX = posX + diffX * rtnEasing;
        posY = posY + diffY * rtnEasing;
      }
      else {
        posX = orgnX;
        posY = orgnY;
      }
    } 
  }
}


class LogoSketch extends TimedSketch {
  PImage leafImg;
  PImage backGrnd;
  
  LogoSketch(float runTime) {
    super(runTime);
    leafImg = loadImage("pirateShip_SailsClearBkgrnd-01.png");
    backGrnd = loadImage("pirateShip_NoSails-01.png");

    ImagePixelCounter counter = new ImagePixelCounter();
    
    int countClr = counter.pixelCount(leafImg, 1, 1);
    int ptsPerSide = floor(sqrt(float(countClr) / float(maxParticles) ));
    println(leafImg.width, leafImg.height, countClr, ptsPerSide);
  
    float scaleImg = scaleWithPreservedAspect(leafImg, width, height);
  
    imgRgnWidth = ptsPerSide;
    imgRgnHeight = ptsPerSide;
    scrnRgnWidth = ptsPerSide * scaleImg;
    scrnRgnHeight = ptsPerSide * scaleImg;
    
    ImageFragmentList fragLister = new ImageFragmentList();
    
    IntList fragList = fragLister.getFragmentCoords(leafImg, ptsPerSide, ptsPerSide);
    
    particleSys = new ParticleSystem(fragList.size() / 2);

    float newWidth = float(leafImg.width) * scaleImg;
    float newHeight = float(leafImg.height) * scaleImg;
    float offX = (width - newWidth) / 2;
    float offY = (height - newHeight) / 2;
    
    for(int i = 0; i < fragList.size()/2; ++i) {
      int posX = fragList.get(i * 2);
      int posY = fragList.get(i * 2 + 1);
      
      particleSys.setParticle(i, 
        new LogoParticle(
          offX + posX*scaleImg,
          offY + posY*scaleImg,
          posX,
          posY));
    }
  }
  
  void drawParticles() {
    beginShape(QUADS);
    noStroke();
    texture(leafImg);
    particleSys.draw();
    endShape();
  }
  
  void setup() {
    particleSys.reset();
    setOpticalFlow(true);
    beginRunning();
  }
  
  void teardown() { 
    setOpticalFlow(false);
  }
  
  void draw() {
    fill(0);
    rect(0, 0, width, height);
    drawWithPreservedAspect(backGrnd, 0, 0, width, height);
    drawParticles();
  
    particleSys.update();
  }
}
