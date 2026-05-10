// 2D Neural cellular automaton - 3 states //

int WIDTH = 480;
int HEIGHT = 270;
int CHANNELS = 3;

float[][][] current;
float[][][] next;

int radius = 2;
int hiddenSize = 8;

int inputSize = 9 * CHANNELS;
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

  current = new float[WIDTH][HEIGHT][CHANNELS];
  next = new float[WIDTH][HEIGHT][CHANNELS];

  initNeuralNetwork();
  initPattern();

  background(0);
  frameRate(60);

}

void initNeuralNetwork() {
  
  w1 = new float[hiddenSize][inputSize];
  b1 = new float[hiddenSize];
  w2 = new float[CHANNELS][hiddenSize];
  b2 = new float[CHANNELS];

  randomizeNetwork();

}

void randomizeNetwork() {
  
  for (int i = 0; i < hiddenSize; i++) {
    for (int j = 0; j < inputSize; j++) {
      w1[i][j] = random(-1.2, 1.2);
    }
    b1[i] = random(-0.3, 0.3);
  }

  for (int c = 0; c < CHANNELS; c++) {
    for (int j = 0; j < hiddenSize; j++) {
      w2[c][j] = random(-1.5, 1.5);
    }
    b2[c] = random(-0.2, 0.2);
  }

}

void initPattern() {

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      for (int c = 0; c < CHANNELS; c++) {
        current[x][y][c] = random(1) < 0.1 ? random(0.5, 1.0) : 0.0;
      }
    }
  }

}

void draw() {

  framebuffer.loadPixels();

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      
      int r = (int)(current[x][y][0] * 255);
      int g = (int)(current[x][y][1] * 255);
      int b = (int)(current[x][y][2] * 255);

      color c = color(r, g, b);
      int px = x * 2;
      int py = y * 2;

      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
          framebuffer.pixels[(py+j) * width + (px+i)] = c;
        }
      }
      
    }
  }

  framebuffer.updatePixels();
  image(framebuffer, 0, 0, width, height);

  computeNextGeneration();

  float[][][] temp = current;
  current = next;
  next = temp;
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }

}

void computeNextGeneration() {
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      float[] input = new float[inputSize];
      int idx = 0;

      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {

          int nx = (x + dx + WIDTH) % WIDTH;
          int ny = (y + dy + HEIGHT) % HEIGHT;

          for (int c = 0; c < CHANNELS; c++) {
            input[idx++] = current[nx][ny][c];
          }
        }
      }

      float[] hidden = new float[hiddenSize];

      for (int i = 0; i < hiddenSize; i++) {
        float sum = b1[i];

        for (int j = 0; j < inputSize; j++) {
          sum += input[j] * w1[i][j];
        }

        hidden[i] = (float)Math.tanh(sum);
      }

      for (int c = 0; c < CHANNELS; c++) {
        float output = b2[c];

        for (int j = 0; j < hiddenSize; j++) {
          output += hidden[j] * w2[c][j];
        }

        next[x][y][c] = (float)(Math.tanh(output) * 0.5 + 0.5);
      }
    }
  }
  
}

void keyPressed() {

  if (key == 'r' || key == 'R') {
    randomizeNetwork();
    initPattern();
    background(0);
  }
  
  if (key == 's' || key == 'S') saving = !saving;

  if (key == 'm' || key == 'M') {
    for (int i = 0; i < hiddenSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        if (random(1) < 0.1) {
          w1[i][j] += random(-0.2, 0.2);
        }
      }
    }
  }
  
}
