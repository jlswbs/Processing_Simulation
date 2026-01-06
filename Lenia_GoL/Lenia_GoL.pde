// Lenia GoL like cellular automata //

int WIDTH = 480;
int HEIGHT = 270;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

float[][] board;
float[][] buffer;
float[][] kernel;

int R = 3;
float muKernel = 0.5;
float sigmaKernel = 1.0;

float muGrowth = 0.15;
float sigmaGrowth = 0.015;

float dt = 0.25;
float randSeed = 0.1;

PImage framebuffer;

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);

  framebuffer = createImage(WIDTH, HEIGHT, RGB);
  noSmooth();

  board  = new float[WIDTH][HEIGHT];
  buffer = new float[WIDTH][HEIGHT];

  kernel = makeKernel(R, muKernel, sigmaKernel);
  randomizeBoard(randSeed);

  frameRate(60);

}

void draw() {

  evolve();

  framebuffer.loadPixels();
  
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      float sum = board[x][y] + 0.5*(board[(x+1)%WIDTH][y] + board[(x-1+WIDTH)%WIDTH][y] + board[x][(y+1)%HEIGHT] + board[x][(y-1+HEIGHT)%HEIGHT]);
      sum = constrain(sum, 0, 1);
      framebuffer.pixels[y*WIDTH + x] = color(255*sum, 255*pow(sum,0.5), 255*pow(sum,1.5));
    }
  }

  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    String filename = String.format("%s/frame_%04d.png", saveDir, frameCounter);
    saveFrame(filename);
    frameCounter++;
  }
  
  if (keyPressed && key == 'r') randomizeBoard(randSeed);
  if (key == 's' || key == 'S') { saving = !saving; }

}

void evolve() {
 
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      float C = 0;

      for (int i = -R; i <= R; i++) {
        for (int j = -R; j <= R; j++) {
          int xi = (x + i + WIDTH) % WIDTH;
          int yj = (y + j + HEIGHT) % HEIGHT;
          C += board[xi][yj] * kernel[i + R][j + R];
        }
      }

      float g = -1 + 2 * gauss(C, muGrowth, sigmaGrowth);
      buffer[x][y] = constrain(board[x][y] + dt * g, 0, 1);
    }
  }

  float[][] tmp = board;
  board = buffer;
  buffer = tmp;

}

float gauss(float x, float mu, float sigma) {
  return exp(-0.5 * sq((x - mu) / sigma));
}

float[][] makeKernel(int R, float mu, float sigma) {
  
  int S = 2 * R + 1;
  float[][] K = new float[S][S];
  float sum = 0;

  for (int i = -R; i <= R; i++) {
    for (int j = -R; j <= R; j++) {
      float d = dist(i, j, 0, 0) / R;
      if (d <= 1) {
        float v = gauss(d, mu, sigma);
        K[i + R][j + R] = v;
        sum += v;
      }
    }
  }

  for (int i = 0; i < S; i++)
    for (int j = 0; j < S; j++)
      K[i][j] /= sum;

  return K;

}

void randomizeBoard(float probability) {
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      if (random(1) < probability) {
        board[x][y] = random(0, 1);
      } else {
        board[x][y] = 0;
      }
    }
  }

}
