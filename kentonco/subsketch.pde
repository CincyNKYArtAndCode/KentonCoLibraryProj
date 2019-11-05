

abstract class SubSketch {
  abstract boolean running();
  void setup() { }
  void teardown() { }
  void draw() {}
  void update() {}
}

abstract class TimedSketch extends SubSketch {
  float runTime;
  float expirationTime;
  TimedSketch(float rt) {
    runTime = rt;
  }
  
  void beginRunning() {
    expirationTime = millis() + runTime * 1000.0;
  }
  
  boolean running() {
    return (millis() < expirationTime);
  }
}
