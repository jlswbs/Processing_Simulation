// 1D Neural cellular automaton - 3 states //

int WIDTH = 960;
int HEIGHT = 540;
int radius = 3;
int CHANNELS = 3;

float[][] current;
float[][] next;

int inputSize = (radius*2 + 1) * CHANNELS;
float[][] weights1;
float[] bias1;
float[][] weights2;
float[] bias2;

int hiddenSize = 32;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

void setup() {
  
  size(960, 540, P2D);
  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();

  current = new float[WIDTH][CHANNELS];
  next = new float[WIDTH][CHANNELS];

  weights1 = new float[hiddenSize][inputSize];
  bias1 = new float[hiddenSize];
  weights2 = new float[CHANNELS][hiddenSize]; // Výstup má nyní 3 kanály
  bias2 = new float[CHANNELS];

  randomizeWeights();
  resetCells();

  background(0);
  frameRate(60);

}

void resetCells() {
  
  for (int x = 0; x < WIDTH; x++) {
    for (int c = 0; c < CHANNELS; c++) {
      current[x][c] = random(1.0);
    }
  }
  
}

void randomizeWeights() {
  
  for (int i = 0; i < hiddenSize; i++) {
    for (int j = 0; j < inputSize; j++) {
      weights1[i][j] = random(-1.0, 1.0);
    }
    bias1[i] = random(-0.5, 0.5);
  }
  for (int i = 0; i < CHANNELS; i++) {
    for (int j = 0; j < hiddenSize; j++) {
      weights2[i][j] = random(-1.0, 1.0);
    }
    bias2[i] = random(-0.2, 0.2);
  }

}

void draw() {
  
  framebuffer.loadPixels();

  framebuffer.copy(framebuffer, 0, 1, WIDTH, HEIGHT-1, 0, 0, WIDTH, HEIGHT-1);

  int y = HEIGHT - 1; 
  int fw = framebuffer.width;

  for (int x = 0; x < WIDTH; x++) {

    int r = (int)(current[x][0] * 255);
    int g = (int)(current[x][1] * 255);
    int b = (int)(current[x][2] * 255);

    framebuffer.pixels[y * fw + x] = color(r, g, b);

  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0, width, height);

  computeNCAGeneration();

  float[][] temp = current;
  current = next;
  next = temp;
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }

}

void computeNCAGeneration() {
  
  for (int x = 0; x < WIDTH; x++) {
    
    float[] input = new float[inputSize];
    int idx = 0;
    for (int r = -radius; r <= radius; r++) {
      int nx = (x + r + WIDTH) % WIDTH;
      for (int c = 0; c < CHANNELS; c++) {
        input[idx++] = (current[nx][c] * 2.0) - 1.0; 
      }
    }

    float[] hidden = new float[hiddenSize];
    for (int i = 0; i < hiddenSize; i++) {
      float sum = bias1[i];
      for (int j = 0; j < inputSize; j++) {
        sum += input[j] * weights1[i][j];
      }
      hidden[i] = (float)Math.tanh(sum);
    }

    for (int c = 0; c < CHANNELS; c++) {
      float output = bias2[c];
      for (int j = 0; j < hiddenSize; j++) {
        output += hidden[j] * weights2[c][j];
      }
      next[x][c] = (float)(Math.tanh(output) * 0.5 + 0.5);
    }
  }
  
}

void keyPressed() {

  if (key == 'r' || key == 'R') {
    randomizeWeights();
    resetCells();
    framebuffer.loadPixels();
    for (int i = 0; i < framebuffer.pixels.length; i++) {
      framebuffer.pixels[i] = color(0);
    }
    framebuffer.updatePixels();

    background(0);
  }
  
  if (key == 's' || key == 'S') saving = !saving;

  if (key == 'm' || key == 'M') {
    
    for (int i = 0; i < hiddenSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        if (random(1) < 0.05) {
          weights1[i][j] += random(-0.1, 0.1); 
        }
      }
      if (random(1) < 0.05) bias1[i] += random(-0.05, 0.05);
    }

    for (int i = 0; i < CHANNELS; i++) {
      for (int j = 0; j < hiddenSize; j++) {
        if (random(1) < 0.05) {
          weights2[i][j] += random(-0.1, 0.1);
        }
      }
      if (random(1) < 0.05) bias2[i] += random(-0.05, 0.05);
    }
  }

}
