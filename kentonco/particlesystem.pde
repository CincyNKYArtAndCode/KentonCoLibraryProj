

class Particle {
  float posX;
  float posY;
  float velX;
  float velY;
  
  Particle(float x, float y) {
    posX = x;
    posY = y;
    velX = 0;
    velY = 0;
  }
  
  void reset() {}
  void draw() { }
  void update() {}
}

class ParticleSystem {
  
  Particle[] particleArray;
  
  ParticleSystem(int size) {
    particleArray = new Particle[size];
  }
  
  void setParticle(int idx, Particle p) {
    particleArray[idx] = p;
  }
  
  Particle getParticle(int idx) {
    return particleArray[idx];
  }
  
  void reset() {
    for(Particle p : particleArray) {
      p.reset();
    }
  }
  
  void draw() {
    for(Particle p : particleArray) {
      p.draw();
    }
  }
  
  void update() {
    for(Particle p : particleArray) {
      p.update();
    }
  }
}
