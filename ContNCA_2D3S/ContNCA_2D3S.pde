// 2D Continuous Neural cellular automaton - 3 states //

int WIDTH = 480;
int HEIGHT = 270;

float dt = 0.5;
int hiddenSize = 8; 

float[][][] state;
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
  
  state = new float[WIDTH][HEIGHT][3];

  w1 = new float[hiddenSize][27];
  b1 = new float[hiddenSize];
  w2 = new float[3][hiddenSize];
  b2 = new float[3];

  randomizeNetwork();
  initPattern();
  
  background(0);
  frameRate(60);

}

void randomizeNetwork() {

  for (int i = 0; i < hiddenSize; i++) {
    for (int j = 0; j < 27; j++) {
      w1[i][j] = random(-0.3, 0.3); 
    }
    b1[i] = random(-0.1, 0.1);
  }

  for (int c = 0; c < 3; c++) {
    for (int j = 0; j < hiddenSize; j++) {
      w2[c][j] = random(-0.5, 0.5);
    }
    b2[c] = 0; 
  }
  
}

void initPattern() {
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      for (int c = 0; c < 3; c++) {
        state[x][y][c] = random(1) < 0.01 ? random(0.5, 1.0) : 0.0;
      }
    }
  }

}

void draw() {
  
  framebuffer.loadPixels();
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      int r = (int)(constrain(state[x][y][0], 0, 1) * 255);
      int g = (int)(constrain(state[x][y][1], 0, 1) * 255);
      int b = (int)(constrain(state[x][y][2], 0, 1) * 255);
      
      color c = color(r, g, b);
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
  
  float[][][] nextDelta = new float[WIDTH][HEIGHT][3];
  float[] input = new float[27];

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      int idx = 0;
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          int nx = (x + dx + WIDTH) % WIDTH;
          int ny = (y + dy + HEIGHT) % HEIGHT;
          for (int c = 0; c < 3; c++) {
            input[idx++] = (state[nx][ny][c] * 2.0) - 1.0;
          }
        }
      }

      float[] hidden = new float[hiddenSize];
      for (int i = 0; i < hiddenSize; i++) {
        float sum = b1[i];
        for (int j = 0; j < 27; j++) sum += input[j] * w1[i][j];
        hidden[i] = (float)Math.tanh(sum);
      }

      for (int c = 0; c < 3; c++) {
        float out = b2[c];
        for (int j = 0; j < hiddenSize; j++) out += hidden[j] * w2[c][j];
        nextDelta[x][y][c] = (float)Math.tanh(out);
      }
    }
  }

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      for (int c = 0; c < 3; c++) {
        float avg = (state[(x + 1) % WIDTH][y][c] + state[(x - 1 + WIDTH) % WIDTH][y][c] +
                     state[x][(y + 1) % HEIGHT][c] + state[x][(y - 1 + HEIGHT) % HEIGHT][c]) * 0.25;
        
        float laplacian = (avg - state[x][y][c]);
    
        state[x][y][c] += (nextDelta[x][y][c] * 1.0 + laplacian * 0.5) * dt;
        state[x][y][c] = constrain(state[x][y][c], 0, 1);
      }
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
      for (int j = 0; j < 27; j++) {
        if (random(1) < 0.15) {
          w1[i][j] += random(-0.4, 0.4);
        }
      }
      if (random(1) < 0.1) b1[i] += random(-0.1, 0.1);
    }
    for (int c = 0; c < 3; c++) {
      for (int j = 0; j < hiddenSize; j++) {
        if (random(1) < 0.15) {
          w2[c][j] += random(-0.4, 0.4);
        }
      }
      if (random(1) < 0.1) b2[c] += random(-0.1, 0.1);
    }
  }
}
