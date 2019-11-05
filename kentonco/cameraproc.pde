import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import gab.opencv.*;

// Clamp depth values into this range
int minDepth = 500;
int maxDepth = 1000;

Kinect kinect;

int[] depth;

boolean videoReady = false;
boolean depthReady = false;
OpenCV opencv;

PImage flowImg;

boolean computeOpticalFlow = false;

void setupKinect() {
  kinect = new Kinect(this);
  kinect.initVideo();
  kinect.initDepth();
  kinect.enableMirror(true);
  
  flowImg = createImage(kinect.width / 4, kinect.height / 4, RGB);
  opencv = new OpenCV(this, flowImg.width, flowImg.height);
  
  setupAcceptableDepthScan();
}

void setOpticalFlow(boolean flag) {
  if(computeOpticalFlow == false && flag == true) {
    videoReady = false;
  }
  computeOpticalFlow = flag;
}

boolean kinectReady() {
  return videoReady && depthReady;
}

void videoEvent(Kinect k) {
  if(computeOpticalFlow) {
    flowImg.copy(
      kinect.getVideoImage(),
      0, 0,
      kinect.width, kinect.height,
      0, 0,
      flowImg.width, flowImg.height);
    opencv.loadImage(flowImg);
    opencv.calculateOpticalFlow();
  }
  videoReady = true;
}

void depthEvent(Kinect k) {
  depth = k.getRawDepth();
  depthReady = true
  ;
}

//==================================
// GetScaledDepth - Returns the depth
// at the screen coordinates (x,y)
// scaled to a value between 0 and 1
//==================================
float GetScaledDepth(float x, float y) {
  // If we don't have depth data yet return 0
  if(!depthReady)
    return 0;
  // Map the screen coordinates to the
  // kinect coordinates
  x = constrain(x, 0, width - 1);
  y = constrain(y, 0, height - 1);
  int depthPixelX = int(map(x, 0, width, 0, kinect.width));
  int depthPixelY = int(map(y, 0, height, 0, kinect.height));

  // Get the depth from the array of depths from the kinect
  // and constrain it to a min and max
  int iDepth = depth[depthPixelX + depthPixelY*kinect.width]; 
  iDepth = constrain(iDepth, minDepth, maxDepth) - minDepth; 
  
  // Scale the integer depth value to something
  // between 0 and 1
  return 1.0 - float(iDepth)/float(maxDepth - minDepth);
}

//==================================
// This section has to do with
// choosing a random screen coordinate
// whose depth falls into the correct 
// range
//==================================

int numScanLines = 8;
int scanStart = 0;
int scanInc = 0;

int[] acceptablePosX;
int[] acceptablePosY;
int numAcceptablePoints = 0;

void setupAcceptableDepthScan() {
  acceptablePosX = new int[numScanLines * kinect.width];
  acceptablePosY = new int[numScanLines * kinect.width];
  scanInc = kinect.height/numScanLines;
}

void updateAcceptableDepthScan() {
  numAcceptablePoints = 0;
  for(int y = 0; y < numScanLines; ++y) {
    int depthPixelY = y*scanInc + scanStart;
    if(depthPixelY < kinect.height) {
      for(int depthPixelX = 0; depthPixelX < kinect.width; ++depthPixelX) {
        int iDepth = depth[depthPixelX + depthPixelY*kinect.width];
        if(iDepth < maxDepth) {
          acceptablePosX[numAcceptablePoints] = depthPixelX;
          acceptablePosY[numAcceptablePoints] = depthPixelY;
          ++numAcceptablePoints;
        }
      }
    }
  }
  scanStart = (scanStart + 1) % scanInc;
}
