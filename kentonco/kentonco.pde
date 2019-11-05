
int sketchNumber = 0;
SubSketch[] sketchList;
SubSketch currentSketch;

void sequenceSketches() {
  if(currentSketch.running())
      return;
  currentSketch.teardown();
  sketchNumber = (sketchNumber + 1) % sketchList.length;
  currentSketch = sketchList[sketchNumber];
  currentSketch.setup();
}

void setup() {
  fullScreen(P2D);
//  size(640, 480, P2D);
  
  setupKinect();
  
  sketchList = new SubSketch[6];
  sketchList[0] = new CreditsSketch(10);
  sketchList[1] = new LogoSketch(10);
  sketchList[2] = new FlowUpSketch(10);
  sketchList[3] = new RevealSketch(10);
  sketchList[4] = new SonarSketch(10);
  sketchList[5] = new MazeSketch();
  //sketchList[5] = new TextSketch(10);
  //sketchList[6] = new JitterSketch(10);
  currentSketch = sketchList[0];
  currentSketch.setup();
}

void draw() {
  if(kinectReady() == false) {
    fill(255);
    rect(0, 0, width, height);
    textAlign(CENTER);
    fill(0);
    text("Waiting for kinect", width/2, height/2);
    return;
  }
  if(currentSketch != null) {
    currentSketch.draw();
    currentSketch.update();
  }
  sequenceSketches();
  //saveFrame("frames/######.tif");
}
