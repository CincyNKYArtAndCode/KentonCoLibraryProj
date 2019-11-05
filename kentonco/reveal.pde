

class RevealSketch extends TimedSketch {
  int totalNumOfDots = 5000;    // # dots

  float maxJitterSize = 40.0f;

  int rows; // num of rows of dots
  int cols; // num dots in a row
  float rowSpacing;
  float colSpacing;
  
  MappedImage backgroundImg;
  MappedImage revealImg;

  RevealSketch(float runTime) {
    super(runTime);
    
    backgroundImg = new MappedImage("NoShipsOnOcean.png");
    revealImg = new MappedImage("ShipsOnOcean.png");

    // calulate start variables
    cols = int(sqrt(totalNumOfDots * revealImg.mappedWidth / revealImg.mappedHeight));
    rows = totalNumOfDots/cols;
    
    colSpacing = revealImg.mappedWidth / float(cols + 1);
    rowSpacing = revealImg.mappedHeight / float(rows + 1); //<>// //<>//
  }
  
  void setup() {
    beginRunning();
    colorMode(HSB);
  }
  
  void draw() {
    backgroundImg.draw();
    
    beginShape(QUADS);
    texture(revealImg.img);
    noStroke();
    for(int row = 0; row < rows; ++row) {
      for(int col = 0; col < cols; ++col) {
        float ptX = revealImg.posX + col * colSpacing;
        float ptY = revealImg.posY + row * rowSpacing;
        float depth = GetScaledDepth(ptX, ptY);
        if(depth > 0.05) {
          
          revealImg.texturedVertex(ptX, ptY);
          revealImg.texturedVertex(ptX + colSpacing, ptY);
          revealImg.texturedVertex(ptX + colSpacing, ptY + rowSpacing);
          revealImg.texturedVertex(ptX, ptY + rowSpacing);
        }
      }
    }
    endShape();
  }
}
