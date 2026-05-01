// random Wireworld cellular automaton //

int cellSize = 8;
int gridWidth, gridHeight;

final int EMPTY = 0;
final int CONDUCTOR = 1;
final int ELECTRON_HEAD = 2;
final int ELECTRON_TAIL = 3;
final int ABSORBER = 4;
final int DELAY = 5;
final int MEMORY_0 = 6;
final int MEMORY_1 = 7;
final int MEMORY_TOGGLE = 8;

int[][] grid;
int[][] nextGrid;

ArrayList<Component> components = new ArrayList<Component>();

int componentDensity = 20;

class Component {
  int x, y;
  int type;
  ArrayList<PVector> connectionPoints = new ArrayList<PVector>();
  ArrayList<PVector> allPoints = new ArrayList<PVector>();
  int delayTime = 0;
  
  Component(int x, int y, int type) {
    this.x = x;
    this.y = y;
    this.type = type;
    this.delayTime = int(random(3, 8));
  }
}

void setup() {
  size(1920, 1080);
  frameRate(30);
  
  gridWidth = width / cellSize;
  gridHeight = height / cellSize;
  
  grid = new int[gridWidth][gridHeight];
  nextGrid = new int[gridWidth][gridHeight];
  
  generateNewWorld();
}

void draw() {
  background(0);
  
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      int state = grid[x][y];
      
      if (state == CONDUCTOR) {
        boolean isComponent = false;
        for (Component c : components) {
          for (PVector p : c.allPoints) {
            if (p.x == x && p.y == y) {
              isComponent = true;
              break;
            }
          }
          if (isComponent) break;
        }
        
        if (isComponent) {
          fill(255, 255, 100);
        } else {
          fill(255, 255, 0);
        }
      } else if (state == ELECTRON_HEAD) {
        fill(0, 0, 255);
      } else if (state == ELECTRON_TAIL) {
        fill(255, 0, 0);
      } else if (state == ABSORBER) {
        fill(128, 0, 128);
      } else if (state == DELAY) {
        fill(255, 165, 0);
      } else if (state == MEMORY_0) {
        fill(0, 255, 255);
      } else if (state == MEMORY_1) {
        fill(255, 0, 255);
      } else if (state == MEMORY_TOGGLE) {
        fill(255, 255, 255);
      } else {
        fill(0);
      }
      
      rect(x * cellSize, y * cellSize, cellSize - 1, cellSize - 1);
    }
  }
  
  computeNextGeneration();
}

void computeNextGeneration() {
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      int state = grid[x][y];
      
      if (state == ELECTRON_HEAD) {
        nextGrid[x][y] = ELECTRON_TAIL;
      } else if (state == ELECTRON_TAIL) {
        nextGrid[x][y] = CONDUCTOR;
      } else if (state == CONDUCTOR) {
        int heads = countNeighborHeads(x, y);
        if (heads == 1 || heads == 2) {
          nextGrid[x][y] = ELECTRON_HEAD;
        } else {
          nextGrid[x][y] = CONDUCTOR;
        }
      } else if (state == ABSORBER) {
        nextGrid[x][y] = ABSORBER;
      } else if (state == DELAY) {
        int heads = countNeighborHeads(x, y);
        if (heads > 0) {
          nextGrid[x][y] = DELAY;
          for (int dx = -1; dx <= 1; dx++) {
            for (int dy = -1; dy <= 1; dy++) {
              if (abs(dx) + abs(dy) == 1) {
                int nx = x + dx;
                int ny = y + dy;
                if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
                  if (grid[nx][ny] == CONDUCTOR && nextGrid[nx][ny] == CONDUCTOR) {
                  }
                }
              }
            }
          }
        } else {
          nextGrid[x][y] = DELAY;
        }
      } else if (state == MEMORY_0) {
        int heads = countNeighborHeads(x, y);
        if (heads > 0) {
          nextGrid[x][y] = MEMORY_TOGGLE;
        } else {
          nextGrid[x][y] = MEMORY_0;
        }
      } else if (state == MEMORY_1) {
        int heads = countNeighborHeads(x, y);
        if (heads > 0) {
          nextGrid[x][y] = MEMORY_TOGGLE;
        } else {
          nextGrid[x][y] = MEMORY_1;
        }
      } else if (state == MEMORY_TOGGLE) {
        if (random(1) < 0.5) {
          nextGrid[x][y] = MEMORY_0;
        } else {
          nextGrid[x][y] = MEMORY_1;
        }
        
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            if (abs(dx) + abs(dy) == 1) {
              int nx = x + dx;
              int ny = y + dy;
              if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
                if (grid[nx][ny] == CONDUCTOR) {
                }
              }
            }
          }
        }
      } else {
        nextGrid[x][y] = EMPTY;
      }
    }
  }
  
  int[][] temp = grid;
  grid = nextGrid;
  nextGrid = temp;
}

int countNeighborHeads(int x, int y) {
  int count = 0;
  
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx == 0 && dy == 0) continue;
      
      int nx = x + dx;
      int ny = y + dy;
      
      if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
        if (grid[nx][ny] == ELECTRON_HEAD) {
          count++;
        }
      }
    }
  }
  
  return count;
}

void mousePressed() {
  generateNewWorld();
}

void generateNewWorld() {
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      grid[x][y] = EMPTY;
    }
  }
  
  components.clear();
  
  int baseCount = int(map(componentDensity, 1, 20, 2, 8));
  
  int numOscillators = int(random(baseCount, baseCount + 5));
  int numDiodes = int(random(baseCount - 1, baseCount + 4));
  int numGates = int(random(baseCount - 1, baseCount + 4));
  int numAbsorbers = int(random(baseCount + 1, baseCount + 6));
  int numDelays = int(random(baseCount + 1, baseCount + 6));
  int numFlipFlops = int(random(baseCount + 1, baseCount + 6));
  
  numOscillators = max(2, numOscillators);
  numDiodes = max(2, numDiodes);
  numGates = max(2, numGates);
  numAbsorbers = max(3, numAbsorbers);
  numDelays = max(3, numDelays);
  numFlipFlops = max(3, numFlipFlops);
  
  numOscillators = min(12, numOscillators);
  numDiodes = min(10, numDiodes);
  numGates = min(10, numGates);
  numAbsorbers = min(12, numAbsorbers);
  numDelays = min(12, numDelays);
  numFlipFlops = min(12, numFlipFlops);
  
  int collisionDistance = int(map(componentDensity, 1, 20, 18, 6));
  
  for (int i = 0; i < numOscillators; i++) {
    int x = int(random(20, gridWidth - 20));
    int y = int(random(20, gridHeight - 20));
    
    if (!collidesWithComponents(x, y, collisionDistance)) {
      Component c = createOscillator(x, y);
      if (c != null) components.add(c);
    } else {
      i--;
      if (i < -100) break;
    }
  }
  
  for (int i = 0; i < numDiodes; i++) {
    int x = int(random(20, gridWidth - 20));
    int y = int(random(20, gridHeight - 20));
    
    if (!collidesWithComponents(x, y, collisionDistance)) {
      Component c = createDiode(x, y);
      if (c != null) components.add(c);
    } else {
      i--;
      if (i < -100) break;
    }
  }
  
  for (int i = 0; i < numGates; i++) {
    int x = int(random(20, gridWidth - 20));
    int y = int(random(20, gridHeight - 20));
    
    if (!collidesWithComponents(x, y, collisionDistance)) {
      Component c;
      if (random(1) < 0.5) {
        c = createANDGate(x, y);
      } else {
        c = createORGate(x, y);
      }
      if (c != null) components.add(c);
    } else {
      i--;
      if (i < -100) break;
    }
  }
  
  for (int i = 0; i < numDelays; i++) {
    int x = int(random(20, gridWidth - 20));
    int y = int(random(20, gridHeight - 20));
    
    if (!collidesWithComponents(x, y, collisionDistance)) {
      Component c = createDelay(x, y);
      if (c != null) components.add(c);
    } else {
      i--;
      if (i < -100) break;
    }
  }
  
  for (int i = 0; i < numFlipFlops; i++) {
    int x = int(random(20, gridWidth - 20));
    int y = int(random(20, gridHeight - 20));
    
    if (!collidesWithComponents(x, y, collisionDistance)) {
      Component c = createFlipFlop(x, y);
      if (c != null) components.add(c);
    } else {
      i--;
      if (i < -100) break;
    }
  }
  
  for (int i = 0; i < numAbsorbers; i++) {
    int x = int(random(20, gridWidth - 20));
    int y = int(random(20, gridHeight - 20));
    
    if (!collidesWithComponents(x, y, collisionDistance)) {
      Component c = createAbsorber(x, y);
      if (c != null) components.add(c);
    } else {
      i--;
      if (i < -100) break;
    }
  }
  
  connectComponentsOrthogonal();
  removeOrphanWires();
  
  for (Component c : components) {
    if (c.type == 0) {
      for (PVector p : c.allPoints) {
        int px = int(p.x);
        int py = int(p.y);
        if (random(1) < 0.15) {
          grid[px][py] = ELECTRON_HEAD;
        }
      }
    } else if (c.type == 6) {
      for (PVector p : c.allPoints) {
        int px = int(p.x);
        int py = int(p.y);
        if (random(1) < 0.5) {
          grid[px][py] = MEMORY_0;
        } else {
          grid[px][py] = MEMORY_1;
        }
      }
    }
  }
}

Component createOscillator(int cx, int cy) {
  Component c = new Component(cx, cy, 0);
  
  for (int dx = -3; dx <= 3; dx++) {
    for (int dy = -3; dy <= 3; dy++) {
      if (abs(dx) == 3 || abs(dy) == 3) {
        int x = cx + dx;
        int y = cy + dy;
        if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
          grid[x][y] = CONDUCTOR;
          c.allPoints.add(new PVector(x, y));
        }
      }
    }
  }
  
  c.connectionPoints.add(new PVector(cx, cy - 3));
  c.connectionPoints.add(new PVector(cx, cy + 3));
  c.connectionPoints.add(new PVector(cx - 3, cy));
  c.connectionPoints.add(new PVector(cx + 3, cy));
  
  return c;
}

Component createDiode(int x, int y) {
  Component c = new Component(x, y, 1);
  
  for (int i = -2; i <= 2; i++) {
    if (x + i >= 0 && x + i < gridWidth) {
      grid[x + i][y] = CONDUCTOR;
      c.allPoints.add(new PVector(x + i, y));
    }
  }
  
  if (x + 3 < gridWidth) {
    grid[x + 3][y] = CONDUCTOR;
    c.allPoints.add(new PVector(x + 3, y));
    if (y - 1 >= 0) {
      grid[x + 3][y - 1] = CONDUCTOR;
      c.allPoints.add(new PVector(x + 3, y - 1));
    }
    if (y + 1 < gridHeight) {
      grid[x + 3][y + 1] = CONDUCTOR;
      c.allPoints.add(new PVector(x + 3, y + 1));
    }
  }
  
  c.connectionPoints.add(new PVector(x - 2, y));
  c.connectionPoints.add(new PVector(x + 3, y));
  
  return c;
}

Component createANDGate(int x, int y) {
  Component c = new Component(x, y, 2);
  
  for (int dy = -2; dy <= 2; dy++) {
    if (x - 2 >= 0) {
      grid[x - 2][y + dy] = CONDUCTOR;
      c.allPoints.add(new PVector(x - 2, y + dy));
    }
  }
  for (int dx = -1; dx <= 2; dx++) {
    if (y - 2 >= 0) {
      grid[x + dx][y - 2] = CONDUCTOR;
      c.allPoints.add(new PVector(x + dx, y - 2));
    }
    if (y + 2 < gridHeight) {
      grid[x + dx][y + 2] = CONDUCTOR;
      c.allPoints.add(new PVector(x + dx, y + 2));
    }
  }
  
  if (x + 3 < gridWidth) {
    grid[x + 3][y] = CONDUCTOR;
    c.allPoints.add(new PVector(x + 3, y));
  }
  
  c.connectionPoints.add(new PVector(x - 2, y - 1));
  c.connectionPoints.add(new PVector(x - 2, y + 1));
  c.connectionPoints.add(new PVector(x + 3, y));
  
  return c;
}

Component createORGate(int x, int y) {
  Component c = new Component(x, y, 3);
  
  for (int dy = -2; dy <= 2; dy++) {
    if (x - 2 >= 0) {
      grid[x - 2][y + dy] = CONDUCTOR;
      c.allPoints.add(new PVector(x - 2, y + dy));
    }
    if (x + 2 < gridWidth) {
      grid[x + 2][y + dy] = CONDUCTOR;
      c.allPoints.add(new PVector(x + 2, y + dy));
    }
  }
  
  for (int dx = -1; dx <= 1; dx++) {
    if (y - 2 >= 0) {
      grid[x + dx][y - 2] = CONDUCTOR;
      c.allPoints.add(new PVector(x + dx, y - 2));
    }
    if (y + 2 < gridHeight) {
      grid[x + dx][y + 2] = CONDUCTOR;
      c.allPoints.add(new PVector(x + dx, y + 2));
    }
  }
  
  c.connectionPoints.add(new PVector(x - 2, y - 1));
  c.connectionPoints.add(new PVector(x - 2, y + 1));
  c.connectionPoints.add(new PVector(x + 2, y));
  
  return c;
}

Component createDelay(int x, int y) {
  Component c = new Component(x, y, 5);
  
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      int nx = x + dx;
      int ny = y + dy;
      if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
        grid[nx][ny] = DELAY;
        c.allPoints.add(new PVector(nx, ny));
      }
    }
  }
  
  c.connectionPoints.add(new PVector(x - 2, y));
  c.connectionPoints.add(new PVector(x + 2, y));
  
  return c;
}

Component createFlipFlop(int x, int y) {
  Component c = new Component(x, y, 6);
  
  for (int dx = -2; dx <= 2; dx++) {
    for (int dy = -2; dy <= 2; dy++) {
      if (abs(dx) <= 2 && abs(dy) <= 2) {
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
          grid[nx][ny] = CONDUCTOR;
          c.allPoints.add(new PVector(nx, ny));
        }
      }
    }
  }
  
  for (int dy = -1; dy <= 1; dy++) {
    if (x - 1 >= 0) {
      grid[x - 1][y + dy] = CONDUCTOR;
      c.allPoints.add(new PVector(x - 1, y + dy));
    }
  }
  for (int dx = -1; dx <= 1; dx++) {
    if (y - 1 >= 0) {
      grid[x + dx][y - 1] = CONDUCTOR;
      c.allPoints.add(new PVector(x + dx, y - 1));
    }
  }
  
  c.connectionPoints.add(new PVector(x - 3, y));
  c.connectionPoints.add(new PVector(x + 3, y));
  c.connectionPoints.add(new PVector(x, y - 3));
  c.connectionPoints.add(new PVector(x, y + 3));
  
  return c;
}

Component createAbsorber(int x, int y) {
  Component c = new Component(x, y, 4);
  
  for (int dx = -2; dx <= 2; dx++) {
    for (int dy = -2; dy <= 2; dy++) {
      if (abs(dx) + abs(dy) <= 3) {
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
          grid[nx][ny] = ABSORBER;
          c.allPoints.add(new PVector(nx, ny));
        }
      }
    }
  }
  
  c.connectionPoints.add(new PVector(x - 2, y));
  c.connectionPoints.add(new PVector(x + 2, y));
  c.connectionPoints.add(new PVector(x, y - 2));
  c.connectionPoints.add(new PVector(x, y + 2));
  
  return c;
}

boolean collidesWithComponents(int x, int y, int minDistance) {
  for (Component c : components) {
    if (dist(x, y, c.x, c.y) < minDistance) {
      return true;
    }
  }
  return false;
}

void connectComponentsOrthogonal() {
  if (components.size() < 2) return;
  
  for (int i = 0; i < components.size(); i++) {
    Component c1 = components.get(i);
    
    int numConnections = int(random(2, 5));
    
    for (int k = 0; k < numConnections; k++) {
      if (components.size() <= 1) break;
      
      int j = findBestConnectionTarget(i);
      if (j == i) continue;
      
      Component c2 = components.get(j);
      
      if (c1.connectionPoints.size() > 0 && c2.connectionPoints.size() > 0) {
        PVector p1 = c1.connectionPoints.get(int(random(c1.connectionPoints.size())));
        PVector p2 = c2.connectionPoints.get(int(random(c2.connectionPoints.size())));
        
        createOrthogonalPath(int(p1.x), int(p1.y), int(p2.x), int(p2.y));
      }
    }
  }
}

int findBestConnectionTarget(int currentIndex) {
  Component current = components.get(currentIndex);
  
  if (current.type == 6) {
    for (int i = 0; i < components.size(); i++) {
      if (i != currentIndex && (components.get(i).type == 5 || components.get(i).type == 4)) {
        return i;
      }
    }
  }
  
  if (current.type == 0) {
    for (int i = 0; i < components.size(); i++) {
      if (i != currentIndex && components.get(i).type == 6) {
        return i;
      }
    }
  }
  
  int j;
  do {
    j = int(random(components.size()));
  } while (j == currentIndex && components.size() > 1);
  
  return j;
}

void createOrthogonalPath(int x1, int y1, int x2, int y2) {
  if (abs(x1 - x2) + abs(y1 - y2) > 150) return;
  
  boolean horizontalFirst = random(1) < 0.5;
  
  int x = x1;
  int y = y1;
  
  if (horizontalFirst) {
    while (x != x2) {
      if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
        if (grid[x][y] == EMPTY) {
          grid[x][y] = CONDUCTOR;
        }
      }
      x += (x2 > x) ? 1 : -1;
    }
    while (y != y2) {
      if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
        if (grid[x][y] == EMPTY) {
          grid[x][y] = CONDUCTOR;
        }
      }
      y += (y2 > y) ? 1 : -1;
    }
  } else {
    while (y != y2) {
      if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
        if (grid[x][y] == EMPTY) {
          grid[x][y] = CONDUCTOR;
        }
      }
      y += (y2 > y) ? 1 : -1;
    }
    while (x != x2) {
      if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
        if (grid[x][y] == EMPTY) {
          grid[x][y] = CONDUCTOR;
        }
      }
      x += (x2 > x) ? 1 : -1;
    }
  }
  
  if (x2 >= 0 && x2 < gridWidth && y2 >= 0 && y2 < gridHeight) {
    if (grid[x2][y2] == EMPTY) {
      grid[x2][y2] = CONDUCTOR;
    }
  }
}

void removeOrphanWires() {
  boolean[][] connected = new boolean[gridWidth][gridHeight];
  
  for (Component c : components) {
    for (PVector p : c.allPoints) {
      floodFill(int(p.x), int(p.y), connected);
    }
    for (PVector p : c.connectionPoints) {
      floodFill(int(p.x), int(p.y), connected);
    }
  }
  
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      if ((grid[x][y] == CONDUCTOR || grid[x][y] == DELAY) && !connected[x][y]) {
        grid[x][y] = EMPTY;
      }
    }
  }
}

void floodFill(int x, int y, boolean[][] connected) {
  if (x < 0 || x >= gridWidth || y < 0 || y >= gridHeight) return;
  if (connected[x][y]) return;
  if (grid[x][y] != CONDUCTOR && grid[x][y] != ABSORBER && 
      grid[x][y] != DELAY && grid[x][y] != MEMORY_0 && 
      grid[x][y] != MEMORY_1) return;
  
  connected[x][y] = true;
  
  floodFill(x + 1, y, connected);
  floodFill(x - 1, y, connected);
  floodFill(x, y + 1, connected);
  floodFill(x, y - 1, connected);
}
