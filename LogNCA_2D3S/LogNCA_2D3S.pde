// 2D Logistics Neural cellular automaton - 3 states //

int WIDTH = 480;
int HEIGHT = 270;

int hiddenSize = 4;

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
      w1[i][j] = random(-2.0, 2.0);
    }
    b1[i] = random(-1.0, 1.0);
  }

  for (int c = 0; c < 3; c++) {
    for (int j = 0; j < hiddenSize; j++) {
      w2[c][j] = random(-2.0, 2.0);
    }
    b2[c] = random(-0.5, 0.5);
  }
  
}

void initPattern() {
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      for (int c = 0; c < 3; c++) {
        state[x][y][c] = random(1) < 0.0001 ? random(0.0, 1.0) : 0.0;
      }
    }
  }
  
}

void draw() {
  
  updateLogisticNCA();

  if (frameCount % 2 == 0) {
    
    framebuffer.loadPixels();

    for (int x = 0; x < WIDTH; x++) {
      for (int y = 0; y < HEIGHT; y++) {
        color c = color(
          state[x][y][0] * 255,
          state[x][y][1] * 255,
          state[x][y][2] * 255
        );
        
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

  }
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }

}

void updateLogisticNCA() {
  
  float[][][] nextState = new float[WIDTH][HEIGHT][3];
  float[][][] intermediate = new float[WIDTH][HEIGHT][3];

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      float[] input = new float[27];
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

        for (int j = 0; j < 27; j++) {
          sum += input[j] * w1[i][j];
        }

        hidden[i] = (float)Math.tanh(sum);
      }

      for (int c = 0; c < 3; c++) {
        float r = b2[c];

        for (int j = 0; j < hiddenSize; j++) {
          r += hidden[j] * w2[c][j];
        }

        r = map((float)Math.tanh(r), -1, 1, 3.5, 3.65);

        float currentVal = state[x][y][c];

        intermediate[x][y][c] =
          r * currentVal * (1.0 - currentVal);
      }
    }
  }

  float blend = 0.7;

  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {

      for (int c = 0; c < 3; c++) {

        float avg =
          (
            intermediate[(x + 1) % WIDTH][y][c] +
            intermediate[(x - 1 + WIDTH) % WIDTH][y][c] +
            intermediate[x][(y + 1) % HEIGHT][c] +
            intermediate[x][(y - 1 + HEIGHT) % HEIGHT][c]
          ) * 0.25;

        nextState[x][y][c] =
          lerp(avg, intermediate[x][y][c], blend);

        nextState[x][y][c] =
          constrain(nextState[x][y][c], 0, 1);
      }
    }
  }

  state = nextState;
  
}

void keyPressed() {

  if (key == 'r' || key == 'R') {
    randomizeNetwork();
    initPattern();
  }
  
  if (key == 's' || key == 'S') saving = !saving;

}
