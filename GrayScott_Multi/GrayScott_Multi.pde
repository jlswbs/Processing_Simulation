// Multi scale Gray-Scott system //

int WIDTH = 960;
int HEIGHT = 540;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

float[][] A1, B1;
float[][] A2, B2;
float[][] A3, B3;

float[] scale1 = {0.01, 0.05, 0.20, 0.01};
float[] scale2 = {0.01, 0.04, 0.45, 0.02};
float[] scale3 = {0.008, 0.03, 0.75, 0.03};

float dt = 0.5;
float crossScale = 0.004;
float feedRate =  0.075;
float killRate = 0.065;

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
  
  computeReactionDiffusion();
  render();

}

void computeReactionDiffusion() {

  float[][] nextA1 = new float[WIDTH][HEIGHT];
  float[][] nextB1 = new float[WIDTH][HEIGHT];
  float[][] nextA2 = new float[WIDTH][HEIGHT];
  float[][] nextB2 = new float[WIDTH][HEIGHT];
  float[][] nextA3 = new float[WIDTH][HEIGHT];
  float[][] nextB3 = new float[WIDTH][HEIGHT];

  for (int x = 2; x < WIDTH - 2; x++) {
    for (int y = 2; y < HEIGHT - 2; y++) {

      float a1 = A1[x][y];
      float b1 = B1[x][y];

      float laplaceA1 =
        (A1[x-1][y] + A1[x+1][y] + A1[x][y-1] + A1[x][y+1]) * 0.2 +
        (A1[x-2][y] + A1[x+2][y] + A1[x][y-2] + A1[x][y+2]) * 0.05 -
        a1;

      float laplaceB1 =
        (B1[x-1][y] + B1[x+1][y] + B1[x][y-1] + B1[x][y+1]) * 0.2 +
        (B1[x-2][y] + B1[x+2][y] + B1[x][y-2] + B1[x][y+2]) * 0.05 -
        b1;

      float reaction1 = a1 * b1 * b1;

      nextA1[x][y] = a1 + dt * (scale1[2] * laplaceA1 - reaction1 + feedRate * (1.0 - a1));
      nextB1[x][y] = b1 + dt * (scale1[3] * laplaceB1 + reaction1 - (killRate + feedRate) * b1 + crossScale);

      nextA1[x][y] = constrain(nextA1[x][y], 0, 1);
      nextB1[x][y] = constrain(nextB1[x][y], 0, 1);

      float a2 = A2[x][y];
      float b2 = B2[x][y];

      float laplaceA2 =
        A2[x-1][y] + A2[x+1][y] + A2[x][y-1] + A2[x][y+1] - 4 * a2;

      float laplaceB2 =
        B2[x-1][y] + B2[x+1][y] + B2[x][y-1] + B2[x][y+1] - 4 * b2;

      float reaction2 = a2 * b2 * b2;
      float scale1Influence = (B1[x][y] - 0.5) * crossScale * 0.1;

      nextA2[x][y] = a2 + dt * (scale2[2] * laplaceA2 - reaction2 + feedRate * (1.0 - a2) + scale1Influence);
      nextB2[x][y] = b2 + dt * (scale2[3] * laplaceB2 + reaction2 - (killRate + feedRate) * b2 + crossScale);

      nextA2[x][y] = constrain(nextA2[x][y], 0, 1);
      nextB2[x][y] = constrain(nextB2[x][y], 0, 1);

      float a3 = A3[x][y];
      float b3 = B3[x][y];

      float laplaceA3 =
        (A3[x-1][y] + A3[x+1][y] + A3[x][y-1] + A3[x][y+1]) * 0.25 - a3;

      float laplaceB3 =
        (B3[x-1][y] + B3[x+1][y] + B3[x][y-1] + B3[x][y+1]) * 0.25 - b3;

      float reaction3 = a3 * b3 * b3;
      float scale2Influence = (B2[x][y] - 0.5) * crossScale * 0.2;

      nextA3[x][y] = a3 + dt * (scale3[2] * laplaceA3 - reaction3 + feedRate * (1.0 - a3) + scale2Influence);
      nextB3[x][y] = b3 + dt * (scale3[3] * laplaceB3 + reaction3 - (killRate + feedRate) * b3 + crossScale);

      nextA3[x][y] = constrain(nextA3[x][y], 0, 1);
      nextB3[x][y] = constrain(nextB3[x][y], 0, 1);
    }
  }

  for (int x = 2; x < WIDTH - 2; x++) {
    for (int y = 2; y < HEIGHT - 2; y++) {
      A1[x][y] = nextA1[x][y];
      B1[x][y] = nextB1[x][y];
      A2[x][y] = nextA2[x][y];
      B2[x][y] = nextB2[x][y];
      A3[x][y] = nextA3[x][y];
      B3[x][y] = nextB3[x][y];
    }
  }

}

void render() {
  
  framebuffer.loadPixels();

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      float r = B1[x][y];
      float g = B2[x][y];
      float b = B3[x][y];
      framebuffer.pixels[x + y * WIDTH] =
        color(r * 200 + g * 55, g * 180 + b * 75, b * 160 + r * 95);
    }
  }

  framebuffer.updatePixels();
  image(framebuffer, 0, 0);

  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }

}

void keyPressed() {
  
  if (key == 's' || key == 'S') saving = !saving;
  if (key == 'r' || key == 'R') initAutomaton();
  
}

void initAutomaton() {
  
  noiseSeed((int)random(1e6));

  A1 = new float[WIDTH][HEIGHT];
  B1 = new float[WIDTH][HEIGHT];
  A2 = new float[WIDTH][HEIGHT];
  B2 = new float[WIDTH][HEIGHT];
  A3 = new float[WIDTH][HEIGHT];
  B3 = new float[WIDTH][HEIGHT];

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      A1[x][y] = 1;
      A2[x][y] = 1;
      A3[x][y] = 1;

      float n = noise(x * 0.01, y * 0.01);
      B1[x][y] = n * 0.5;
      B2[x][y] = n * 0.3;
      B3[x][y] = n * 0.2;

      if (random(1) < 0.001) B1[x][y] += 0.5;
      if (random(1) < 0.001) B2[x][y] += 0.5;
      if (random(1) < 0.001) B3[x][y] += 0.5;
    }
  }

}
