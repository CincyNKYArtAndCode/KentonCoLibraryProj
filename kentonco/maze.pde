
int mazeColWidth = 40;
int mazeRowHeight = 40;

class IntStack {
  int numElems = 0;
  IntList list;
  
  IntStack() {
    list = new IntList();
  }
  
  void push(int val) {
    if(numElems == list.size()) {
      list.append(val);
    }
    else {
      list.set(numElems, val);
    }
    ++numElems;
  }
  
  int pop() {
    --numElems; 
    return list.get(numElems);
  }
  
  int length() {
    return numElems;
  }
};

// A maze is an array of doors wth size Rows X Columns X 2(Doors).
// Each array element is false if the door is closed and true 
// if the door is open.
// Each cell has 2 elements for the east and south doors.  
// The north door of a cell is the south door in the previous row.
// The west door of a cell is the east door in the previous colum.
class Maze {
  int[] adjacentColOffset = { 1, 0, -1, 0 };
  int[] adjacentRowOffset = { 0, 1, 0, -1 };

  int rows;
  int cols;
  boolean[] arr;
  
  IntStack path;
  
  // Create the array and initialize all the doors to false(closed)
  Maze(int rs, int cs) {
    rows = rs;
    cols = cs;
    arr = new boolean[rows * cols * 2];
    path = new IntStack();
  }
  
  void setup() {
    isDone = false;
    curRow = 0;
    curCol = 0;
    for(int idx = 0; idx < rows * cols * 2; ++idx) {
      arr[idx] = false;
    }
  }

  boolean isCoordInBounds(int row, int col) {
    return row >= 0 && 
      row < rows && 
      col >= 0 && 
      col < cols;
  }

  boolean isDoorOpen(int row, int col, int door) {
    if(door > 1) {
      row = row + adjacentRowOffset[door];
      col = col + adjacentColOffset[door];
      door = (door + 2) % 4; // reverse door
    }
    if(isCoordInBounds(row, col) == false) {
      return false;
    }

    return arr[row * cols * 2 + col * 2 + door];
  }

  boolean anyDoorOpen(int row, int col) {
    for(int door = 0; door < 4; ++door) {
      if(isDoorOpen(row, col, door)) {
        return true;
      }
    }
    return false;
  }

  void openDoor(int row, int col, int door) {
    if(door > 1) {
      row = row + adjacentRowOffset[door];
      col = col + adjacentColOffset[door];
      door = (door + 2) % 4; // reverse door
    }
    if(isCoordInBounds(row, col) == true) {
      arr[row * cols * 2 + col * 2 + door] = true;
    }
  }
  
  int[] validDoors = { -1, -1, -1, -1 };
  int chooseRandomDoor(int row, int col) {
    int numDoors = 0;
    int randDoor = -1;
    for (int door = 0; door < 4; door++) {
      int testRow = row + adjacentRowOffset[door];
      int testCol = col + adjacentColOffset[door];
      if(isCoordInBounds(testRow, testCol) == true && 
        anyDoorOpen(testRow, testCol) == false) {
          validDoors[numDoors++] = door;
      }
    }
    if(numDoors > 0) {
      int randIdx = floor(random(numDoors));
      randDoor = validDoors[randIdx];
    }
    return randDoor; 
  }

  boolean isDone = false;
  int curRow = 0;
  int curCol = 0;
  
  boolean buildStep() {
    int door = chooseRandomDoor(curRow, curCol);
    
    while(door < 0 && path.length() > 0) {
      curCol = path.pop();
      curRow = path.pop();
      door = chooseRandomDoor(curRow, curCol);
    }

    if(door >= 0) { 
      // Go forward
      openDoor(curRow, curCol, door);
      path.push(curRow);
      path.push(curCol);
      this.curRow = this.curRow + adjacentRowOffset[door];
      this.curCol = this.curCol + adjacentColOffset[door];
    }
    else {
      isDone = true;
    }
    
    return isDone;
  }
}



class MazeSketch extends SubSketch {
  
  Maze maze;
  float expirationTime;
  
  MappedImage theMap;
  
  MazeSketch() {
    int cols = width / mazeColWidth;
    int rows = height / mazeRowHeight;
    maze = new Maze(rows - 2, cols - 2); // -2 to give a border
    
    theMap = new MappedImage("TreasureMapX.png");
    theMap.setRegion(0, 0, width, height);
  }
  
  boolean running() {
    return (millis() < expirationTime);
  }
  
  
  void setup() { 
      maze.setup();
      expirationTime = millis() + 1000;
  }
  
  void draw() {
    fill(0);
    rect(0,0,width,height);
    theMap.draw();
    int mazeWidth = maze.cols * mazeColWidth;
    int mazeHeight = maze.rows * mazeRowHeight;
    int baseX = (width - mazeWidth)/2;
    int baseY = (height - mazeHeight)/2;
    line(baseX, baseY, baseX + mazeWidth, baseY);
    line(baseX, baseY, baseX, baseY + mazeHeight);
    for(int row = 0; row < maze.rows; ++row) {
      for(int col = 0; col < maze.cols; ++col) {
        // east(0) door
        if(!maze.anyDoorOpen(row, col)) {
          noStroke();
          rect(baseX + col * mazeColWidth, baseY + row * mazeRowHeight, mazeColWidth, mazeRowHeight);
        }
        stroke(255);
        strokeWeight(2);
        if(maze.isDoorOpen(row, col, 0) == false) {
          line( baseX + (col + 1) * mazeColWidth,
                baseY + row * mazeRowHeight,
                baseX + (col + 1) * mazeColWidth,
                baseY + (row + 1) * mazeRowHeight);
        }
        // south(1) door
        if(maze.isDoorOpen(row, col, 1) == false) {
          line( baseX + col * mazeColWidth,
                baseY + (row + 1) * mazeRowHeight,
                baseX + (col + 1) * mazeColWidth,
                baseY + (row + 1) * mazeRowHeight);
        }
      }
    }
  }

  void update() {
    if(!maze.isDone) {
      maze.buildStep();
      expirationTime = millis() + 1000;
    }
  }
}
