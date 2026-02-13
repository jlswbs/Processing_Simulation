// Keller-Segel system simulation //

int WIDTH = 960;
int HEIGHT = 540;

int cols, rows;
float[][] chem;
float[][] nextChem;
ArrayList<Cell> cells;

int agents = 5000;

float diffuseRate = 0.1;
float evaporateRate = 0.8;
float attractStrength = 1.3;

float noiseStrength = 0.1;
float inertia = 0.85;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();
  
  cols = width;
  rows = height;
  chem = new float[cols][rows];
  nextChem = new float[cols][rows];
  cells = new ArrayList<Cell>();

  for (int i = 0; i < agents; i++) {
    cells.add(new Cell(random(width), random(height)));
  }
  
  background(0);
  frameRate(60);
  
}

void draw() {
  
  for (int x = 1; x < cols-1; x++) {
    for (int y = 1; y < rows-1; y++) {
      float sum = chem[x+1][y] + chem[x-1][y] + chem[x][y+1] + chem[x][y-1];
      nextChem[x][y] = (chem[x][y] + sum * diffuseRate) / (1 + 4 * diffuseRate);
      nextChem[x][y] *= evaporateRate; 
    }
  }
  
  float[][] temp = chem;
  chem = nextChem;
  nextChem = temp;

  framebuffer.loadPixels();

  for (int i = 0; i < framebuffer.pixels.length; i++) {
  
      color c = framebuffer.pixels[i];
  
    float r = red(c) * 0.95;
    float g = green(c) * 0.95;
    float b = blue(c) * 0.95;
  
    framebuffer.pixels[i] = color(r, g, b);
  }

  for (Cell c : cells) {
    c.sense(chem);
    c.update();
    c.deposit(chem);
    
    int pix = int(c.x) + int(c.y) * width;
    if (pix >= 0 && pix < framebuffer.pixels.length) {
      framebuffer.pixels[pix] = color(100, 150, 255);
    }
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }

}

class Cell {
  float x, y, vx, vy;

  Cell(float x, float y) {
    this.x = x; 
    this.y = y;
  }

  void sense(float[][] grid) {
    float maxC = -1;
    float dirX = 0, dirY = 0;

    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        int nx = (int(x) + i + cols) % cols;
        int ny = (int(y) + j + rows) % rows;
        if (grid[nx][ny] > maxC) {
          maxC = grid[nx][ny];
          dirX = i; 
          dirY = j;
        }
      }
    }

    vx = vx * inertia + dirX * attractStrength + random(-noiseStrength, noiseStrength);
    vy = vy * inertia + dirY * attractStrength + random(-noiseStrength, noiseStrength);

  }

  void update() {
    x = (x + vx + cols) % cols;
    y = (y + vy + rows) % rows;
  }

  void deposit(float[][] grid) {
    grid[int(x)][int(y)] += 2.0;
  }
}

void keyPressed() {
  
  if (key == 'r' || key == 'R') setup();
  if (key == 's' || key == 'S') saving = !saving;

}
