// Langton's Ant - two ants with different rules //

int WIDTH = 960;
int HEIGHT = 540;

int[][] grid;
int[][] ownerGrid;

String rules1 = "LRRRLLRRRLLLRLRLRRRRRRLLLRRRLRLRLRRRLLRRRLLRRLLRRRRRLLRLL";
String rules2 = "LRLRLR";

int N_COLORS;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

class Ant {
  int x, y;
  int dir;
  String rules;
  int nStates;
  int id;
  float hueOffset;
  
  Ant(int startX, int startY, int startDir, String antRules, int antId, float hue) {
    x = startX;
    y = startY;
    dir = startDir;
    rules = antRules;
    nStates = rules.length();
    id = antId;
    hueOffset = hue;
  }
  
  void step() {
    int cellState = grid[y][x];
    
    char rule = rules.charAt(cellState % nStates);
    if (rule == 'L') {
      dir = (dir + 3) % 4;
    } else if (rule == 'R') {
      dir = (dir + 1) % 4;
    }
    
    grid[y][x] = (cellState + 1) % N_COLORS;
    ownerGrid[y][x] = id;
    
    switch(dir) {
      case 0: y = (y - 1 + HEIGHT) % HEIGHT; break;
      case 1: x = (x + 1) % WIDTH; break;
      case 2: y = (y + 1) % HEIGHT; break;
      case 3: x = (x - 1 + WIDTH) % WIDTH; break;
    }
  }
}

Ant ant1, ant2;
int stepsPerFrame = 1000;

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, RGB);
  noSmooth();
  
  grid = new int[HEIGHT][WIDTH];
  ownerGrid = new int[HEIGHT][WIDTH];
  
  N_COLORS = max(rules1.length(), rules2.length());
  
  ant1 = new Ant(
    int(random(WIDTH)),
    int(random(HEIGHT)),
    int(random(4)),
    rules1,
    1,
    0
  );
  
  ant2 = new Ant(
    int(random(WIDTH)),
    int(random(HEIGHT)),
    int(random(4)),
    rules2,
    2,
    240
  );
  
  background(0);
  frameRate(60);

}

void draw() {
  
  for (int i = 0; i < stepsPerFrame; i++) {
    ant1.step();
    ant2.step();
  }
  
  framebuffer.loadPixels();

  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      int idx = y * WIDTH + x;
      int owner = ownerGrid[y][x];
      int state = grid[y][x];
      
      if (owner == 1) {
        framebuffer.pixels[idx] = cellToColor(state, ant1.hueOffset);
      } else if (owner == 2) {
        framebuffer.pixels[idx] = cellToColor(state, ant2.hueOffset);
      } else {
        framebuffer.pixels[idx] = color(0);
      }
    }
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }
  
}

color cellToColor(int state, float hueBase) {

  float hueRange = 60;
  float hue = hueBase + (state * (hueRange / N_COLORS));
  float s = 0.85;
  float v = 0.9;
  
  colorMode(HSB, 360, 1, 1);
  color c = color(hue % 360, s, v);
  colorMode(RGB, 255);
  
  return c;

}

void keyPressed() {
  
  if (key == 'r' || key == 'R') setup();
  if (key == 's' || key == 'S') saving = !saving;

}
