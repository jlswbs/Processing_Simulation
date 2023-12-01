// Multiscale Turing patterns //

int n, level, levels;
int i, x, y;
float[] grid;
float[] diffusionLeft, diffusionRight, blurBuffer, variation;
float[] bestVariation;
int[] bestLevel;
boolean[] direction;
float[] stepSizes;
int[] radii;
float[] activator;
float[] inhibitor;
float[] swap;
 
 
void setup() {
  
  size(640, 480);
  background(255);
 
  float base = random(1.5, 2.4);
  float stepScale = random(.006, .011);
  float stepOffset = random(.007, .012);
 
  n = width * height;
  levels = (int) (log(width) / log(base));
  radii = new int[levels];
  stepSizes = new float[levels];
  grid = new float[n];
  diffusionLeft = new float[n];
  diffusionRight = new float[n];
  blurBuffer = new float[n];
  variation = new float[n];
  bestVariation = new float[n];
  bestLevel = new int[n];
  direction = new boolean[n];
  activator = new float[n];
  inhibitor = new float[n];
  swap = new float[n];
 
  for (i = 0; i < levels; i++) {
    int radius = (int) pow(base, i);
    radii[i] = radius;
    stepSizes[i] = log(radius) * stepScale + stepOffset;
  }
 
  for (i = 0; i < n; i++) grid[i] = random(-1, +1);
  
}
 

void draw() {
  
  
    for (i = 0; i < n; i++) {
        activator[i] = grid[i];
         inhibitor[i] = diffusionRight[i];
      }
 
  for (level = 0; level < levels - 1; level++) {

    int radius = radii[level];
    
     for (y = 0; y < height; y++) {
    for (x = 0; x < width; x++) {
       int t = y * width + x;
      if (y == 0 && x == 0) {
        blurBuffer[t] = activator[t];
      } else if (y == 0) {
        blurBuffer[t] = blurBuffer[t - 1] + activator[t];
      } else if (x == 0) {
        blurBuffer[t] = blurBuffer[t - width] + activator[t];
      } else {
        blurBuffer[t] = blurBuffer[t - 1] + blurBuffer[t - width] - blurBuffer[t - width - 1] + activator[t];
      }
    }
  }

  for (y = 0; y < height; y++) {
    for (x = 0; x < width; x++) {
      int minx = max(0, x - radius);
      int maxx = min(x + radius, width - 1);
      int miny = max(0, y - radius);
      int maxy = min(y + radius, height - 1);
      int area = (maxx - minx) * (maxy - miny);
       
      int nw = miny * width + minx;
      int ne = miny * width + maxx;
      int sw = maxy * width + minx;
      int se = maxy * width + maxx;
       
      int t = y * width + x;
      inhibitor[t] = (blurBuffer[se] - blurBuffer[sw] - blurBuffer[ne] + blurBuffer[nw]) / area;
    }
  }

    for (i = 0; i < n; i++) {
      variation[i] = activator[i] - inhibitor[i];
      if (variation[i] < 0) {
        variation[i] = -variation[i];
      }
    }
 
    if (level == 0) {
      for (i = 0; i < n; i++) {
        bestVariation[i] = variation[i];
        bestLevel[i] = level;
        direction[i] = activator[i] > inhibitor[i];
      }
      
    }
    else {
      for (i = 0; i < n; i++) {
        if (variation[i] < bestVariation[i]) {
          bestVariation[i] = variation[i];
          bestLevel[i] = level;
          direction[i] = activator[i] > inhibitor[i];
        }
      }
      
      for (i = 0; i < n; i++) {
      swap[i] = activator[i];
      activator[i] = inhibitor[i];
      inhibitor[i] = swap[i];
      }
    }
  }

  float smallest = Float.POSITIVE_INFINITY;
  float largest = Float.NEGATIVE_INFINITY;
  for (i = 0; i < n; i++) {
    float curStep = stepSizes[bestLevel[i]];
    if (direction[i]) {
      grid[i] += curStep;
    }
    else {
      grid[i] -= curStep;
    }
    smallest = min(smallest, grid[i]);
    largest = max(largest, grid[i]);
  }
 
  float range = (largest - smallest) / 2;
  for (i = 0; i < n; i++) grid[i] = ((grid[i] - smallest) / range) - 1;
  
  loadPixels();
  
  for (y = 0; y < height; y++) {
    for (x = 0; x < width; x++) {
       int t = y * width + x;
       float val = 128 + 128 * grid[t];
       pixels[y*width+x] = color(val, val, val);
    }
  }
  
  updatePixels();
  
  // saveFrame("#####.jpg");
  
}
