// 1D Biham Rule 184 traffic model //

int WIDTH = 960;
int HEIGHT = 540;
boolean[] cars;
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
  
  cars = new boolean[WIDTH];
  
  float density = 0.3;
  for (int i = 0; i < WIDTH; i++) {
    if (random(1) < density) {
      cars[i] = true;
    }
  }
  
  step = 0;
  
  framebuffer.loadPixels();
  
  for (int i = 0; i < framebuffer.pixels.length; i++) {
    framebuffer.pixels[i] = color(0);
  }
  
  framebuffer.updatePixels();
  
  background(0);
  frameRate(60);

}

void draw() {

  framebuffer.loadPixels();

  for (int y = 0; y < HEIGHT - 1; y++) {
    for (int x = 0; x < WIDTH; x++) {
      framebuffer.pixels[x + y * WIDTH] =
        framebuffer.pixels[x + (y + 1) * WIDTH];
    }
  }

  int y = HEIGHT - 1;
  for (int x = 0; x < WIDTH; x++) {
    if (cars[x]) {
      framebuffer.pixels[x + y * WIDTH] = color(255);
    } else {
      framebuffer.pixels[x + y * WIDTH] = color(0);
    }
  }

  framebuffer.updatePixels();
  image(framebuffer, 0, 0);

  boolean[] newCars = new boolean[WIDTH];

  for (int x = 0; x < WIDTH; x++) {
    if (cars[x]) {
      int next = (x + 1) % WIDTH;
      if (!cars[next]) {
        newCars[next] = true;
      } else {
        newCars[x] = true;
      }
    }
  }

  cars = newCars;

  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }

}

void keyPressed() {
  
  if (key == 'r' || key == 'R') setup();
  if (key == 's' || key == 'S') saving = !saving;
  
}
