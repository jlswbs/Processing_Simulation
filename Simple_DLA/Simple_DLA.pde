// Diffusion-Limited Aggregation //

int WIDTH = 960;
int HEIGHT = 540;

float[][] field;
float[][] nextField;

float diffusionRate = 0.03;
float evaporation = 1.0;
int particles = 400;

float maxRadius = 1;
int centerX, centerY;
float spawnMargin = 30;
float killMargin = 70;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();
  
  field = new float[width][height];
  nextField = new float[width][height];

  field[width/2][height/2] = 255;
  
  background(0);
  frameRate(60);
  
  centerX = width/2;
  centerY = height/2;
  maxRadius = 1;
  
}

void draw() {
  
  simulateStep();
  
  framebuffer.loadPixels();
  
  for (int x = 1; x < width-1; x++) {
    for (int y = 1; y < height-1; y++) {
      
      int pixIdx = y * width + x;
      float val = field[x][y];
      framebuffer.pixels[pixIdx] = color(val * 0.5, val * 0.8, val);
    }
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }
  
}

void simulateStep() {
  
  for (int i = 0; i < particles; i++) {
    
    float spawnRadius = maxRadius + spawnMargin;
    float killRadius = maxRadius + killMargin;
    
    float r = random(TWO_PI);
    int x = centerX + int(spawnRadius * cos(r));
    int y = centerY + int(spawnRadius * sin(r));
    
    while (true) {
      
      int dir = int(random(4));
      if (dir == 0) x++;
      else if (dir == 1) x--;
      else if (dir == 2) y++;
      else y--;
      
      if (x < 1 || x >= width-1 || y < 1 || y >= height-1)
        break;
      
      float dx = x - centerX;
      float dy = y - centerY;
      float distSq = dx*dx + dy*dy;
      
      if (distSq > killRadius * killRadius)
        break;
      
      if (field[x][y] > 10) {
        
        field[x][y] += 50;
        if (field[x][y] > 255) field[x][y] = 255;
        
        float dist = sqrt(distSq);
        if (dist > maxRadius) {
          maxRadius = dist;
        }
        
        break;
      }
    }
  }

  for (int x = 1; x < width-1; x++) {
    for (int y = 1; y < height-1; y++) {
      float avg = (field[x+1][y] + field[x-1][y] +
                   field[x][y+1] + field[x][y-1]) / 4.0;
                   
      nextField[x][y] = (field[x][y] * (1 - diffusionRate) +
                         avg * diffusionRate) * evaporation;
    }
  }
  
  float[][] temp = field;
  field = nextField;
  nextField = temp;
  
}

void keyPressed() {
  
  if (key == 'r' || key == 'R') setup();
  if (key == 's' || key == 'S') saving = !saving;
  
}
