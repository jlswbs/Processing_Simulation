// LC resonators Game of Life cellular automata //

int WIDTH = 960;
int HEIGHT = 540;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

float[][] v, iL;
float[][] vNext, iNext;

float L = 0.2;
float C = 1.0;
float R = 0.5;
float K = 0.5;
float dt = 0.2;

float lifeThreshold = 0.6;
float lifeKick      = 1.45;
float decay         = 0.0005;

PImage framebuffer;

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  framebuffer = createImage(WIDTH, HEIGHT, RGB);
  noSmooth();
  
  v     = new float[HEIGHT][WIDTH];
  iL    = new float[HEIGHT][WIDTH];
  vNext = new float[HEIGHT][WIDTH];
  iNext = new float[HEIGHT][WIDTH];

  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      v[y][x]  = random(1) < 0.02 ? random(-1, 1) : 0;
      iL[y][x] = 0;
    }
  }

  frameRate(60);
  noSmooth();
}

void draw() {
  
  stepLC();

  framebuffer.loadPixels();

  int idx = 0;
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {

      float a = abs(v[y][x]);
      int col;
      if (a < 0.05)      col = color(0);
      else if (a < 0.3)  col = color(0,255,0);
      else               col = color(255,255,0);

      framebuffer.pixels[idx++] = col;
    }
  }

  framebuffer.updatePixels();
  image(framebuffer, 0, 0);

  if (saving) {
    String filename = String.format("%s/frame_%04d.png", saveDir, frameCounter);
    saveFrame(filename);
    frameCounter++;
  }
  
  if (keyPressed && key == 'r') { randomInit(); }
  if (key == 's' || key == 'S') { saving = !saving; }

}

void stepLC() {
  for (int y = 0; y < HEIGHT; y++) {
    int yUp = (y - 1 + HEIGHT) % HEIGHT;
    int yDn = (y + 1) % HEIGHT;
    for (int x = 0; x < WIDTH; x++) {
      int xLt = (x - 1 + WIDTH) % WIDTH;
      int xRt = (x + 1) % WIDTH;

      float v0  = v[y][x];
      float i0  = iL[y][x];

      float vL = v[y][xLt];
      float vR = v[y][xRt];
      float vU = v[yUp][x];
      float vD = v[yDn][x];

      float lap = (vL + vR + vU + vD - 4.0 * v0);

      float nAnalog =
        act(vL) + act(vR) + act(vU) + act(vD);

      float dv = ( -i0 - v0 / R + K * lap ) / C;
      float di = v0 / L;

      float v1 = v0 + dv * dt;
      float i1 = i0 + di * dt;

      if (nAnalog > lifeThreshold && nAnalog < 3.5) {
        float w = 1.0 - constrain(abs(v0), 0, 1);
        v1 += lifeKick * w;
      }

      v1 = softClip(v1, 1.5);

      v1 *= (1.0 - decay);
      i1 *= (1.0 - decay);

      vNext[y][x] = v1;
      iNext[y][x] = i1;
    }
  }

  float[][] tmpV = v;
  v = vNext;
  vNext = tmpV;

  float[][] tmpI = iL;
  iL = iNext;
  iNext = tmpI;
}

float act(float x) {
  return 0.5 * (1.0 + (float)Math.tanh(3.0 * x));
}

float softClip(float x, float limit) {
  if (abs(x) <= limit) return x;
  return (float)(limit * Math.tanh(x / limit));
}

void randomInit() {
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      v[y][x]  = random(1) < 0.02 ? random(-1, 1) : 0;
      iL[y][x] = 0;
    }
  }
}
