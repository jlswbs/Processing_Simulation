// 1D Neural cellular automaton //

int WIDTH = 960;
int HEIGHT = 540;
int radius = 3;

float[] current;
float[] next;

int inputSize = (radius*2 + 1) * 1;
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
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();

  current = new float[WIDTH];
  next = new float[WIDTH];

  weights1 = new float[hiddenSize][inputSize];
  bias1 = new float[hiddenSize];
  weights2 = new float[1][hiddenSize];
  bias2 = new float[1];

  randomizeWeights();

  for (int x = 0; x < WIDTH; x++) {
    current[x] = random(1.0);
  }

  background(0);
  frameRate(60);
  
}

void randomizeWeights() {
  
  for (int i = 0; i < hiddenSize; i++) {
    for (int j = 0; j < inputSize; j++) {
      weights1[i][j] = random(-1.2, 1.2);
    }

    bias1[i] = random(-0.5, 0.5);
  }

  for (int j = 0; j < hiddenSize; j++) {
    weights2[0][j] = random(-1.5, 1.5);
  }

  bias2[0] = random(-0.3, 0.3);
  
}

void draw() {
  
  framebuffer.loadPixels();
  
  framebuffer.copy(framebuffer, 0, 1, WIDTH, HEIGHT-1, 0, 0, WIDTH, HEIGHT-1);

  int y = HEIGHT - 1;
  int fw = framebuffer.width;

  for (int x = 0; x < WIDTH; x++) {
    
    float state = current[x];
    float boosted = pow(state, 0.7); 
    int brightness = (int)(boosted * 255);
    color c = color(brightness * 0.6, brightness, brightness * 0.8);

    framebuffer.pixels[y * fw + x] = c;
    
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0, width, height);

  computeNCAGeneration();

  float[] temp = current;
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
      input[idx++] = current[nx];
    }

    float[] hidden = new float[hiddenSize];

    for (int i = 0; i < hiddenSize; i++) {
      float sum = bias1[i];

      for (int j = 0; j < inputSize; j++) {
        sum += input[j] * weights1[i][j];
      }

      hidden[i] = (float)Math.tanh(sum);
    }

    float output = bias2[0];

    for (int j = 0; j < hiddenSize; j++) {
      output += hidden[j] * weights2[0][j];
    }

    output = ((float)Math.tanh(output) + 1) * 0.5;

    next[x] = output;
  }
  
}

void keyPressed() {

  if (key == 'r' || key == 'R') {

    randomizeWeights();

    for (int x = 0; x < WIDTH; x++) {
      current[x] = random(1) < 0.15 ? random(0.7, 1.0) : 0.0;
    }
    
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

        if (random(1) < 0.1) {
          weights1[i][j] += random(-0.4, 0.4);
        }

      }
    }
  }
  
}
