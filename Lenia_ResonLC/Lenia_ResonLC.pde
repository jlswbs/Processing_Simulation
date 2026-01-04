// LC resonators Lenia like cellular automata //

int WIDTH = 960;
int HEIGHT = 540;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

float[][] v, iL, vNext, iNext;
float[][] kernel;

int kernelRadius = 6;

float L = 0.2;
float C = 1.0;
float R = 0.5;
float K = 0.1;
float dt = 0.15;

float mu = 0.15;
float sigma = 0.05;
float lifeKick = 0.95;
float decay = 0.0002;

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

  kernel = new float[2 * kernelRadius + 1][2 * kernelRadius + 1];
  float sumK = 0;
  for (int ky = -kernelRadius; ky <= kernelRadius; ky++) {
    for (int kx = -kernelRadius; kx <= kernelRadius; kx++) {
      float dist = sqrt(kx*kx + ky*ky) / kernelRadius;
      float val = exp(-4.0 * pow(dist - 0.5, 2)); 
      if (dist > 1.0) val = 0;
      kernel[ky + kernelRadius][kx + kernelRadius] = val;
      sumK += val;
    }
  }

  for (int j = 0; j < kernel.length; j++) {
    for (int i = 0; i < kernel[0].length; i++) kernel[j][i] /= sumK;
  }

  randomInit();
  
  frameRate(60);
  noSmooth();

}

void draw() {
  
  stepLCLenia();
  
  framebuffer.loadPixels();
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      float val = v[y][x];
      if (val > 0) framebuffer.pixels[y * WIDTH + x] = color(val * 400, val * 200, 0);
      else framebuffer.pixels[y * WIDTH + x] = color(0, abs(val) * 100, abs(val) * 400);
    }
  }
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    String filename = String.format("%s/frame_%04d.png", saveDir, frameCounter);
    saveFrame(filename);
    frameCounter++;
  }
  
  if (keyPressed && key == 'r') randomInit();
  if (key == 's' || key == 'S') { saving = !saving; }
}

void stepLCLenia() {

  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      
      float nAnalog = 0;
      for (int ky = -kernelRadius; ky <= kernelRadius; ky++) {
        int ny = (y + ky + HEIGHT) % HEIGHT;
        for (int kx = -kernelRadius; kx <= kernelRadius; kx++) {
          int nx = (x + kx + WIDTH) % WIDTH;
          nAnalog += v[ny][nx] * kernel[ky + kernelRadius][kx + kernelRadius];
        }
      }

      float growth = exp(-pow(nAnalog - mu, 2) / (2 * pow(sigma, 2))) * 2.0 - 1.0;
      float v0 = v[y][x];
      float i0 = iL[y][x];

      float lap = (v[y][(x+1)%WIDTH] + v[y][(x-1+WIDTH)%WIDTH] + v[(y+1)%HEIGHT][x] + v[(y-1+HEIGHT)%HEIGHT][x] - 4.0 * v0);

      float dv = (-i0 - v0 / R + K * lap) / C;
      float di = v0 / L;

      float v1 = v0 + dv * dt + (growth * lifeKick * dt);
      float i1 = i0 + di * dt;

      v1 = constrain(v1, -2.0, 2.0);
      vNext[y][x] = v1 * (1.0 - decay);
      iNext[y][x] = i1 * (1.0 - decay);
    }
  }

  float[][] tmpV = v; v = vNext; vNext = tmpV;
  float[][] tmpI = iL; iL = iNext; iNext = tmpI;

}

void randomInit() {

  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      v[y][x] = random(1) < 0.05 ? random(0, 1) : 0;
      iL[y][x] = 0;
    }
  }

}
