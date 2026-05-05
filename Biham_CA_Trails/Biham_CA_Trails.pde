// 2D Biham-Middleton like Neumann CA with trails //

int WIDTH = 960;
int HEIGHT = 540;
int CELL_SIZE = 2;

int gridWidth = WIDTH / CELL_SIZE;
int gridHeight = HEIGHT / CELL_SIZE;

int[][] cars;
float[][] trail;
int step = 0;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

color c1 = color(255, 0, 0);
color c2 = color(0, 255, 0);

float TRAIL_DECAY = 0.96;
float TRAIL_INTENSITY = 0.7;

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();
  
  cars = new int[gridHeight][gridWidth];
  trail = new float[gridHeight][gridWidth];
  
  float density = 0.3;
  float redRatio = 0.5;
  
  for (int y = 0; y < gridHeight; y++) {
    for (int x = 0; x < gridWidth; x++) {
      trail[y][x] = 0.0;
      if (random(1) < density) {
        cars[y][x] = random(1) < redRatio ? 1 : 2;
      } else {
        cars[y][x] = 0;
      }
    }
  }
  
  background(0);
  frameRate(60);
  
}

void draw() {
  
  framebuffer.loadPixels();
  
  for (int i = 0; i < framebuffer.pixels.length; i++) {
    framebuffer.pixels[i] = color(0);
  }
  
  for (int gy = 0; gy < gridHeight; gy++) {
    for (int gx = 0; gx < gridWidth; gx++) {
      float t = trail[gy][gx];
      if (t > 0.01) {
        int gray = int(t * 100);
        color trailColor = color(gray, gray, gray);
        
        int px = gx * CELL_SIZE;
        int py = gy * CELL_SIZE;
        
        for (int dy = 0; dy < CELL_SIZE; dy++) {
          for (int dx = 0; dx < CELL_SIZE; dx++) {
            int index = (px + dx) + (py + dy) * WIDTH;
            if (index >= 0 && index < framebuffer.pixels.length) {
              framebuffer.pixels[index] = trailColor;
            }
          }
        }
      }
    }
  }
  
  for (int gy = 0; gy < gridHeight; gy++) {
    for (int gx = 0; gx < gridWidth; gx++) {
      int car = cars[gy][gx];
      if (car == 0) continue;
      
      color col = (car == 1) ? c1 : c2;
      
      int px = gx * CELL_SIZE;
      int py = gy * CELL_SIZE;
      
      for (int dy = 0; dy < CELL_SIZE; dy++) {
        for (int dx = 0; dx < CELL_SIZE; dx++) {
          int index = (px + dx) + (py + dy) * WIDTH;
          if (index >= 0 && index < framebuffer.pixels.length) {
            framebuffer.pixels[index] = col;
          }
        }
      }
    }
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0, width, height);
  
  for (int y = 0; y < gridHeight; y++) {
    for (int x = 0; x < gridWidth; x++) {
      trail[y][x] *= TRAIL_DECAY;
      if (trail[y][x] < 0.01) trail[y][x] = 0;
    }
  }
  
  int[][] newCars = new int[gridHeight][gridWidth];
  
  for (int y = 0; y < gridHeight; y++) {
    for (int x = 0; x < gridWidth; x++) {
      int car = cars[y][x];
      if (car == 0) continue;
      
      boolean moved = false;
      
      int[][] directions;
      if (car == 1) {
        directions = new int[][]{{1, 0}, {-1, 0}, {0, 1}, {0, -1}};
      } else {
        directions = new int[][]{{0, 1}, {0, -1}, {1, 0}, {-1, 0}};
      }
      
      for (int i = directions.length - 1; i > 0; i--) {
        int j = int(random(i + 1));
        int[] temp = directions[i];
        directions[i] = directions[j];
        directions[j] = temp;
      }
      
      for (int i = 0; i < 4; i++) {
        int dx = directions[i][0];
        int dy = directions[i][1];
        
        int nx = (x + dx + gridWidth) % gridWidth;
        int ny = (y + dy + gridHeight) % gridHeight;
        
        if (cars[ny][nx] == 0) {
          newCars[ny][nx] = car;
          trail[y][x] = min(1.0, trail[y][x] + TRAIL_INTENSITY);
          moved = true;
          break;
        }
      }
      
      if (!moved) {
        newCars[y][x] = car;
        trail[y][x] = min(1.0, trail[y][x] + TRAIL_INTENSITY * 0.3);
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
