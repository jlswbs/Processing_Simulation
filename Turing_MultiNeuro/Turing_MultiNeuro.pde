// Multi-scale Turing patterns neuronal adaptation // 

final int WIDTH = 960;
final int HEIGHT = 540;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

final int SCR = WIDTH * HEIGHT;
float[] grid = new float[SCR];
float[] neuronDir = new float[SCR];
float[] bestVariation = new float[SCR];
int[] bestLevel = new int[SCR];
boolean[] direction = new boolean[SCR];
float[] activator = new float[SCR];
float[] inhibitor = new float[SCR];
float[] blurBuffer = new float[SCR];

int[] radii;
float[] stepSizes;

float base, stepScale, stepOffset, blurFactor;
int levels, blurlevels;

final float NEURON_INERTIA = 0.97f;
final float NEURON_DRIVE  = 0.015f;
final float NEURON_NOISE  = 0.003f;

PImage framebuffer;

void setup() {
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  framebuffer = createImage(WIDTH, HEIGHT, RGB);
  noSmooth();
  
  rndrule();
}

void rndrule() {
  base = random(1.4f, 1.9f);
  stepScale = random(0.02f, 0.06f);
  stepOffset = random(0.01f, 0.03f);
  blurFactor = random(0.7f, 0.9f);

  levels = (int)(log(max(WIDTH, HEIGHT)) / log(base)) - 1;
  blurlevels = (int)((levels + 1) * blurFactor);

  radii = new int[levels];
  stepSizes = new float[levels];

  for (int i = 0; i < levels; i++) {
    int maxRadius = min(WIDTH, HEIGHT) / 3;
    radii[i] = min((int)pow(base, i), maxRadius);
    stepSizes[i] = log(radii[i]) * stepScale + stepOffset;
  }

  for (int i = 0; i < SCR; i++) {
    grid[i] = random(-1.0f, 1.0f);
    neuronDir[i] = random(-0.05f, 0.05f);
    bestVariation[i] = Float.MAX_VALUE;
  }
}

void draw() {
  System.arraycopy(grid, 0, activator, 0, SCR);

  for (int level = 0; level < levels - 1; level++) {
    int radius = radii[level];

    if (level <= blurlevels) {
      for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
          int t = y * WIDTH + x;
          if (y == 0 && x == 0)
            blurBuffer[t] = activator[t];
          else if (y == 0)
            blurBuffer[t] = blurBuffer[t - 1] + activator[t];
          else if (x == 0)
            blurBuffer[t] = blurBuffer[t - WIDTH] + activator[t];
          else
            blurBuffer[t] = blurBuffer[t - 1] + blurBuffer[t - WIDTH]
                          - blurBuffer[t - WIDTH - 1] + activator[t];
        }
      }
    }

    for (int y = 0; y < HEIGHT; y++) {
      for (int x = 0; x < WIDTH; x++) {
        int minx = max(0, x - radius);
        int maxx = min(WIDTH - 1, x + radius);
        int miny = max(0, y - radius);
        int maxy = min(HEIGHT - 1, y + radius);

        int area = (maxx - minx + 1) * (maxy - miny + 1);

        int nw = miny * WIDTH + minx;
        int ne = miny * WIDTH + maxx;
        int sw = maxy * WIDTH + minx;
        int se = maxy * WIDTH + maxx;

        int t = y * WIDTH + x;
        inhibitor[t] = (blurBuffer[se] - blurBuffer[sw]
                      - blurBuffer[ne] + blurBuffer[nw]) / area;
      }
    }

    for (int i = 0; i < SCR; i++) {
      float v = abs(activator[i] - inhibitor[i]);
      if (level == 0 || v < bestVariation[i]) {
        bestVariation[i] = v;
        bestLevel[i] = level;
        direction[i] = activator[i] > inhibitor[i];
      }
    }

    System.arraycopy(inhibitor, 0, activator, 0, SCR);
  }

  float smallest = Float.MAX_VALUE;
  float largest  = -Float.MAX_VALUE;

  for (int i = 0; i < SCR; i++) {
    float target = direction[i] ? 1.0f : -1.0f;
    float step   = stepSizes[bestLevel[i]] * NEURON_DRIVE;
    
    neuronDir[i] = neuronDir[i] * NEURON_INERTIA + target * step + random(-NEURON_NOISE, NEURON_NOISE);
    grid[i] += neuronDir[i];

    smallest = min(smallest, grid[i]);
    largest  = max(largest, grid[i]);
  }

  float range = (largest - smallest) * 0.5f;

  framebuffer.loadPixels();
  for (int i = 0; i < SCR; i++) {
    grid[i] = ((grid[i] - smallest) / range) - 1.0f;
    int c = (int)(128 + (127.0f * grid[i]));
    framebuffer.pixels[i] = color(c, c, c);
  }
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);

  if (saving) {
    String filename = String.format("%s/frame_%03d.png", saveDir, frameCounter);
    saveFrame(filename);
    frameCounter++;
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saving = !saving;
  }
}

void mousePressed() {
  rndrule();
}
