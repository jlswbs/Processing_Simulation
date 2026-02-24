// Keller-Segel system simulation with adhesion //

int WIDTH = 960;
int HEIGHT = 540;

int numCells = 15000;
float diffuseRate = 0.1;
float evaporateRate = 0.01;
float attractStrength = 0.2;
float adhesionStrength = 0.9;

float[][] chem;
float[][] nextChem;
int[][] occupancy;
Cell[] cells;
int cols, rows;

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
  occupancy = new int[cols][rows];
  
  cells = new Cell[numCells];
  for (int i = 0; i < numCells; i++) {
    cells[i] = new Cell(random(width), random(height));
  }
  
  background(0);
  frameRate(60);
  
}

void draw() {
  
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      occupancy[x][y] = 0;
    }
  }
  
  for (Cell c : cells) {
    int cx = int(c.x);
    int cy = int(c.y);
    if (cx >= 0 && cx < cols && cy >= 0 && cy < rows) {
      occupancy[cx][cy]++;
    }
  }

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
    int p = framebuffer.pixels[i];
    float r = (p >> 16 & 0xFF) * 0.9;
    float g = (p >> 8 & 0xFF) * 0.9;
    float b = (p & 0xFF) * 0.9;
    framebuffer.pixels[i] = color(r, g, b);
  }
  
  for (Cell c : cells) {
    c.applyBehaviors(chem, occupancy);
    c.update();
    c.deposit(chem);
    
    int ix = int(c.x);
    int iy = int(c.y);

    if (ix >= 0 && ix < width && iy >= 0 && iy < height) {
      int pix = ix + iy * width;
      framebuffer.pixels[pix] = color(200, 200, 255);
    }
  }
  
  framebuffer.updatePixels();
  
  background(0);
  image(framebuffer, 0, 0);
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }
  
}

class Cell {
  float x, y;
  float vx, vy;

  Cell(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void applyBehaviors(float[][] grid, int[][] occ) {
    float maxC = -1;
    int dirX = 0;
    int dirY = 0;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int nx = (int(x) + i + cols) % cols;
        int ny = (int(y) + j + rows) % rows;
        if (grid[nx][ny] > maxC) {
          maxC = grid[nx][ny];
          dirX = i;
          dirY = j;
        }
      }
    }
    vx += dirX * attractStrength;
    vy += dirY * attractStrength;

    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        int nx = (int(x) + i + cols) % cols;
        int ny = (int(y) + j + rows) % rows;
        if (occ[nx][ny] > 0) {
          vx += i * (adhesionStrength / 5.0); 
          vy += j * (adhesionStrength / 5.0);
        }
      }
    }
  }

  void update() {
    vx *= 0.9;
    vy *= 0.9;
    
    vx += random(-0.2, 0.2);
    vy += random(-0.2, 0.2);

    x = (x + vx + cols) % cols;
    y = (y + vy + rows) % rows;
  }

  void deposit(float[][] grid) {
    int ix = int(x);
    int iy = int(y);
    if (ix >= 0 && ix < cols && iy >= 0 && iy < rows) {
      grid[ix][iy] += 5.0;
    }
  }
}

void keyPressed() {
  
  if (key == 'r' || key == 'R') setup();
  if (key == 's' || key == 'S') saving = !saving;

}
