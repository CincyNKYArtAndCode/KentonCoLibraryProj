
abstract class ImagePixelProcessor {
  void processImage(PImage img, int regSizeX, int regSizeY) {
    img.loadPixels();
    for(int iy = 0; iy < img.height; iy += regSizeY) {
      for(int ix = 0; ix < img.width; ix += regSizeX) {
        boolean found = false;
        for(int iry = iy; !found && iry < min(iy + regSizeY, img.height); ++iry) {
          for(int irx = ix; !found && irx < min(ix + regSizeX, img.width); ++irx) {
            if(testPixel(img, irx, iry)) found = true;
          }
        }
        if(found) processFragment(img, ix, iy, regSizeX, regSizeY);
      }
    }  
    img.updatePixels();
  }
  
  boolean testPixel(PImage img, int x, int y) {
    return true;
  }
  abstract void processFragment(PImage img, int x1, int y1, int regSizeX, int regSizeY);
}

class ImagePixelCounter extends ImagePixelProcessor {
  int count = 0;
  int pixelCount(PImage img, int regSizeX, int regSizeY) {
    count = 0;
    processImage(img, regSizeX, regSizeY);
    return count;
  }
  
  boolean testPixel(PImage img, int x, int y) {
    color clr = img.get(x, y);
    return (alpha(clr) > 20);
  }
  void processFragment(PImage img, int x, int y, int regSizeX, int regSizeY) {
    ++count;
  }
}

class ImageFragmentList extends ImagePixelProcessor {
  IntList fragmentCoords;
  IntList getFragmentCoords(PImage img, int regSizeX, int regSizeY) {
    fragmentCoords = new IntList();
    processImage(img, regSizeX, regSizeY);
    return fragmentCoords;
  }
  
  boolean testPixel(PImage img, int x, int y) {
    color clr = img.get(x, y);
    return (alpha(clr) > 20);
  }
  
  void processFragment(PImage img, int x, int y, int regSizeX, int regSizeY) {
    fragmentCoords.append(x);
    fragmentCoords.append(y);
  }
}



float scaleWithPreservedAspect(PImage img, int w, int h) {
  float scaleImg = float(h)/float(img.height);
  
  float newWidth = float(img.width) * scaleImg;
  if(newWidth > w) {
    scaleImg = float(w)/float(img.width);
  }
  return scaleImg;
}

void drawWithPreservedAspect(PImage img, int x, int y, int w, int h) {
  float scaleImg = scaleWithPreservedAspect(img, w, h);
  
  float newWidth = float(img.width) * scaleImg;
  float newHeight = float(img.height) * scaleImg;
  float drwX = x + (w - newWidth) / 2;
  float drwY = y + (h - newHeight) / 2;
  
  image(img, drwX, drwY, newWidth, newHeight);
}

class MappedImage {
  PImage img;
  float scale;
  float posX;
  float posY;
  float mappedWidth;
  float mappedHeight;
  
  MappedImage(String fileName) {
    img = loadImage(fileName);
    setRegion();
  }
  
  void setRegion(float x, float y, float w, float h) {
    scale = h / float(img.height);
    
    mappedWidth = float(img.width) * scale;
    if(mappedWidth > w) {
      scale = w / float(img.width);
    }
  
    mappedWidth = float(img.width) * scale;
    mappedHeight = float(img.height) * scale;
    posX = x + (w - mappedWidth) / 2;
    posY = y + (h - mappedHeight) / 2;
  }
  
  void setRegion() {
    setRegion(0, 0, width, height);
  }
  
  void draw() {
    image(img, posX, posY, mappedWidth, mappedHeight);
  }
  
  void texturedVertex(float x, float y) {
    float texX = (x - posX) / scale;
    float texY = (y - posY) / scale;
    vertex(x, y, texX, texY);
  }
  
}
