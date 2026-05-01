// 2D Biham-Middleton traffic model //

int WIDTH = 960;
int HEIGHT = 540;
boolean[][] redCars;
boolean[][] blueCars;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();
  
  redCars = new boolean[WIDTH][HEIGHT];
  blueCars = new boolean[WIDTH][HEIGHT];
  
  float density = 0.31;
  
  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < HEIGHT; j++) {
      if (random(1) < density) {
        if (random(1) < 0.5) {
          redCars[i][j] = true;
        } else {
          blueCars[i][j] = true;
        }
      }
    }
  }
  
  background(0);
  frameRate(60);
  
}

void draw() {

  background(0);
  
  boolean[][] newRed = new boolean[WIDTH][HEIGHT];
  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < HEIGHT; j++) {
      if (redCars[i][j]) {
        int next = (i + 1) % WIDTH;
        if (!redCars[next][j] && !blueCars[next][j]) {
          newRed[next][j] = true;
        } else {
          newRed[i][j] = true;
        }
      }
    }
  }
  redCars = newRed;
  
  boolean[][] newBlue = new boolean[WIDTH][HEIGHT];
  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < HEIGHT; j++) {
      if (blueCars[i][j]) {
        int next = (j + 1) % HEIGHT;
        if (!redCars[i][next] && !blueCars[i][next]) {
          newBlue[i][next] = true;
        } else {
          newBlue[i][j] = true;
        }
      }
    }
  }
  blueCars = newBlue;
  
  framebuffer.loadPixels();
  
  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < HEIGHT; j++) {
      if (redCars[i][j]) {
        framebuffer.pixels[i + j * WIDTH] = color(255, 0, 0);
      } else if (blueCars[i][j]) {
        framebuffer.pixels[i + j * WIDTH] = color(0, 0, 255);
      } else {
        framebuffer.pixels[i + j * WIDTH] = color(255);
      }
    }
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }
  
}

void keyPressed() {
  
  if (key == 'r' || key == 'R') setup();
  if (key == 's' || key == 'S') saving = !saving;
  
}
