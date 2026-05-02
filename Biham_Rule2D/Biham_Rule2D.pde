// 2D Biham Rule 184 traffic model //

int WIDTH = 960;
int HEIGHT = 540;
boolean[][] cars;
int step = 0;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();
  
  cars = new boolean[HEIGHT][WIDTH];
  
  float density = 0.5;
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      cars[y][x] = random(1) < density;
    }
  }
  
  background(0);
  frameRate(60);
  
}

void draw() {
  
  framebuffer.loadPixels();
  
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      int px = x;
      int py = y;
      
      color c = cars[y][x] ? color(255) : color(0);
      
      int index = px + py * width;
      if (px + 1 < width && py + 1 < height) {
        framebuffer.pixels[index] = c;
        framebuffer.pixels[index + 1] = c;
        framebuffer.pixels[index + width] = c;
        framebuffer.pixels[index + width + 1] = c;
      }
    }
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  boolean[][] newCars = new boolean[HEIGHT][WIDTH];
  
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      if (cars[y][x]) {
        int nextX = (x + 1) % WIDTH;
        if (!cars[y][nextX]) {
          newCars[y][nextX] = true;
        } else {
          newCars[y][x] = true;
        }
      }
    }
  }
  
  cars = newCars;
  step++;
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }
  
}

void keyPressed() {
  
  if (key == 'r' || key == 'R') setup();
  if (key == 's' || key == 'S') saving = !saving;
  
}
