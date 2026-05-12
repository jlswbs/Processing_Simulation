// 2D Continuous Neural cellular automaton //

int WIDTH = 480;
int HEIGHT = 270;

float dt = 0.2;
int hiddenSize = 8;

float[][] state;
float[][] w1;
float[] b1;
float[][] w2;
float[] b2;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(2*WIDTH, 2*HEIGHT);
  
  framebuffer = createImage(2*WIDTH, 2*HEIGHT, ARGB);
  noSmooth();

  state = new float[WIDTH][HEIGHT];

  w1 = new float[hiddenSize][9];
  b1 = new float[hiddenSize];
  w2 = new float[1][hiddenSize];
  b2 = new float[1];

  randomizeNetwork();
  initPattern();

  background(0);
  frameRate(60);
  
}

void randomizeNetwork() {
  
  for (int i = 0; i < hiddenSize; i++) {
    for (int j = 0; j < 9; j++) {
      w1[i][j] = random(-1.0, 1.0);
    }
    b1[i] = random(-0.5, 0.5);
  }

  for (int j = 0; j < hiddenSize; j++) {
    w2[0][j] = random(-1.0, 1.0);
  }

  b2[0] = random(-0.5, 0.5);
  
}

void initPattern() {
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      state[x][y] = random(1) < 0.1 ? random(0.5, 1.0) : 0.0;
    }
  }
  
}

void draw() {
  
  framebuffer.loadPixels();

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      float val = constrain(state[x][y], 0, 1);
      int col = (int)(val * 255);

      color c = color(col * 0.6, col, col * 1.3);

      int px = x * 2;
      int py = y * 2;

      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
          framebuffer.pixels[(py + j) * width + (px + i)] = c;
        }
      }
    }
  }

  framebuffer.updatePixels();
  image(framebuffer, 0, 0, width, height);

  updateContinuous();
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }
  
}

void updateContinuous() {
  
  float[][] delta = new float[WIDTH][HEIGHT];

  float[] input = new float[9];

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      int idx = 0;

      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          int nx = (x + dx + WIDTH) % WIDTH;
          int ny = (y + dy + HEIGHT) % HEIGHT;
          input[idx++] = (state[nx][ny] * 2.0) - 1.0;
        }
      }

      float[] hidden = new float[hiddenSize];

      for (int i = 0; i < hiddenSize; i++) {
        float sum = b1[i];

        for (int j = 0; j < 9; j++) {
          sum += input[j] * w1[i][j];
        }

        hidden[i] = (float)Math.tanh(sum);
      }

      float output = b2[0];

      for (int j = 0; j < hiddenSize; j++) {
        output += hidden[j] * w2[0][j];
      }

      delta[x][y] = (float)Math.tanh(output);
    }
  }

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      float diffusion = 0;

      diffusion += state[(x + 1) % WIDTH][y];
      diffusion += state[(x - 1 + WIDTH) % WIDTH][y];
      diffusion += state[x][(y + 1) % HEIGHT];
      diffusion += state[x][(y - 1 + HEIGHT) % HEIGHT];

      diffusion = (diffusion * 0.25 - state[x][y]) * 0.5;

      state[x][y] += (delta[x][y] + diffusion) * dt;
      state[x][y] = constrain(state[x][y], 0, 1);
      
    }
  }

}

void keyPressed() {

  if (key == 'r' || key == 'R') {
    randomizeNetwork();
    initPattern();
  }
  
  if (key == 's' || key == 'S') saving = !saving;

  if (key == 'm' || key == 'M') {
    for (int i = 0; i < hiddenSize; i++) {
      for (int j = 0; j < 9; j++) {
        if (random(1) < 0.15) {
          w1[i][j] += random(-0.25, 0.25);
        }
      }
    }
  }
}
