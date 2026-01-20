// 3 state Langton ant + GoL cellular automata //

int WIDTH = 960;
int HEIGHT = 540;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

int[][] grid;
int[][] nextGrid;

int ax, ay;
int dir = 0;

int langStep = 1000;

int golInterval = 0;
int golCounter = 0;

PImage framebuffer;

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);

  framebuffer = createImage(WIDTH, HEIGHT, RGB);
  noSmooth();
  
  initAutomaton();

  frameRate(60);

}

void draw() {
  
  framebuffer.loadPixels();

  for (int i = 0; i < langStep; i++) updateAnt();
  if (golCounter++ % golInterval == 0) updateGoL();

  for (int x = 0; x < WIDTH; x++) {
    
    for (int y = 0; y < HEIGHT; y++) {

      int s = grid[x][y];
      int c;

      if (s == 0) c = color(0);
      else if (s == 1) c = color(0, 180, 255);
      else if (s == 2) c = color(255, 120, 0);
      else if (s == 3) c = color(180, 255, 0);
      else c = color(255);

      if (x == ax && y == ay) c = color(255, 0, 0);

      framebuffer.pixels[y * width + x] = c;

    }

  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    String filename = String.format("%s/frame_%04d.png", saveDir, frameCounter);
    saveFrame(filename);
    frameCounter++;
  }
  
}

void updateGoL() {

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      int alive = (grid[x][y] > 0) ? 1 : 0;
      int neighbors = countNeighbors(x, y);

      if (alive == 1) {
        nextGrid[x][y] = (neighbors < 2 || neighbors > 3) ? 0 : grid[x][y];
      } else {
        nextGrid[x][y] = (neighbors == 3) ? 1 : 0;
      }
    }
  }

  int[][] tmp = grid;
  grid = nextGrid;
  nextGrid = tmp;

}

int countNeighbors(int x, int y) {

  int sum = 0;
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx == 0 && dy == 0) continue;
      int nx = (x + dx + WIDTH) % WIDTH;
      int ny = (y + dy + HEIGHT) % HEIGHT;
      if (grid[nx][ny] > 0) sum++;
    }
  }
  return sum;

}

void updateAnt() {

  int state = grid[ax][ay];

  if (state == 0) dir = (dir + 2) % 4;
  else dir = (dir + 1) % 4;

  grid[ax][ay] = (state + 1) % 4;

  if (dir == 0) ay--;
  else if (dir == 1) ax++;
  else if (dir == 2) ay++;
  else if (dir == 3) ax--;

  ax = (ax + WIDTH) % WIDTH;
  ay = (ay + HEIGHT) % HEIGHT;

}

void keyPressed() {

  if (key == 's' || key == 'S') saving = !saving;
  if (key == 'r' || key == 'R') initAutomaton();

}

void initAutomaton() {
  
  grid = new int[WIDTH][HEIGHT];
  nextGrid = new int[WIDTH][HEIGHT];

  golInterval = (int)random(20, 200);
  dir = (int)random(4);
  ax = WIDTH / 2;
  ay = HEIGHT / 2;

}
