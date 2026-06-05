// 2D Smooth Life continuous cellular automaton //

int WIDTH = 480;
int HEIGHT = 270;

float[][] grid;
float[][] nextGrid;

float ri = 3.0;
float ra = 9.0;

float b1 = 0.278;
float b2 = 0.365;
float s1 = 0.267;
float s2 = 0.445;

float alpha_n = 0.028;
float alpha_m = 0.147;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

void setup() {

  size(100, 100, P2D);
  surface.setSize(2 * WIDTH, 2 * HEIGHT);

  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();

  grid = new float[WIDTH][HEIGHT];
  nextGrid = new float[WIDTH][HEIGHT];

  initGrid();

  background(0);
  frameRate(60);
  
}

void draw() {

  framebuffer.loadPixels();

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      float m = 0;
      float n = 0;
      float m_area = 0;
      float n_area = 0;

      int r_ceil = ceil(ra);

      for (int dx = -r_ceil; dx <= r_ceil; dx++) {
        for (int dy = -r_ceil; dy <= r_ceil; dy++) {

          int nx = (x + dx + WIDTH) % WIDTH;
          int ny = (y + dy + HEIGHT) % HEIGHT;

          float d = sqrt(dx * dx + dy * dy);
          float val = grid[nx][ny];

          if (d <= ri) {
            m += val;
            m_area++;
          } else if (d > ri && d <= ra) {
            n += val;
            n_area++;
          }
        }
      }

      m = (m_area > 0) ? m / m_area : grid[x][y];
      n = (n_area > 0) ? n / n_area : 0;

      nextGrid[x][y] = transition(m, n);

      int c = int(constrain(nextGrid[x][y], 0, 1) * 255);
      framebuffer.pixels[x + y * WIDTH] = color(c);
    }
  }

  framebuffer.updatePixels();
  image(framebuffer, 0, 0, width, height);

  float[][] temp = grid;
  grid = nextGrid;
  nextGrid = temp;

  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }
  
}

void initGrid() {

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      grid[x][y] = 0.0;
    }
  }

  for (int i = 0; i < 60; i++) {
    int cx = int(random(WIDTH));
    int cy = int(random(HEIGHT));
    int r = int(random(5, 25));

    for (int x = cx - r; x <= cx + r; x++) {
      for (int y = cy - r; y <= cy + r; y++) {
        if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT) {
          if (dist(x, y, cx, cy) < r) {
            grid[x][y] = random(0.5, 1.0);
          }
        }
      }
    }
  }
}

void keyPressed() {

  if (key == 'r' || key == 'R') {
    initGrid();
  }

  if (key == 's' || key == 'S') {
    saving = !saving;
  }
}

float sigma1(float x, float a, float alpha) {
  return 1.0 / (1.0 + exp(-4.0 * (x - a) / alpha));
}

float sigma2(float x, float a, float b, float alpha) {
  return sigma1(x, a, alpha) * (1.0 - sigma1(x, b, alpha));
}

float transition(float m, float n) {
  float s = sigma2(n, s1, s2, alpha_n);
  float b = sigma2(n, b1, b2, alpha_n);
  return m * s + (1.0 - m) * b;
}
