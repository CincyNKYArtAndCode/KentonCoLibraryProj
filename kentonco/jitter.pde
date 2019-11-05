

class JitterSketch extends TimedSketch {
  int totalNumOfDots = 5000;    // # dots

  float maxJitterSize = 40.0f;

  int rows; // num of rows of dots
  int cols; // num dots in a row
  float rowSpacing;
  float colSpacing;

  JitterSketch(float runTime) {
    super(runTime);

    // calulate start variables
    cols = int(sqrt(totalNumOfDots * width / height));
    rows = totalNumOfDots/cols;
    
    rowSpacing = height/ float(rows + 1);
    colSpacing = width / float(cols + 1);
  }
  
  void setup() {
    beginRunning();
    colorMode(HSB);
  }
  
  void draw() {
    fill(0, 0, 0, 5);
    rect(0, 0, width, height);
    noStroke();
    ellipseMode(CENTER);
    
    for(int row = 0; row < rows; ++row) {
      for(int col = 0; col < cols; ++col) {
        float ptX = (col + 1)*colSpacing;
        float ptY = (row + 1)*rowSpacing;
        float depth = GetScaledDepth(ptX, ptY);
        if(depth > 0.05) {
          float randAngle = random(0, TAU);
          float jitterScale = random(0, depth * maxJitterSize);
          float offX = cos(randAngle) * jitterScale;
          float offY = sin(randAngle) * jitterScale;
          int saturation = int((1.0 - depth)*200.0) + 55;
          fill(random(0,255), saturation, 255);
          
          ellipse(ptX + offX, ptY + offY, 8, 8);
        }
      }
    }
  }
}
