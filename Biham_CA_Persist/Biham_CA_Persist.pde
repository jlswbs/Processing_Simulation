// 2D Biham-Middleton like Moore CA with directional persistence //

int WIDTH = 960;
int HEIGHT = 540;
boolean[][] cars;
int[][][] lastDir;
int step = 0;
color c;

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
  lastDir = new int[HEIGHT][WIDTH][2];
  
  float density = 0.3;
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      cars[y][x] = random(1) < density;
      lastDir[y][x][0] = 0;
      lastDir[y][x][1] = 0;
    }
  }
  
  background(0);
  frameRate(60);
  
}

void draw() {
  
  framebuffer.loadPixels();
  
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      int px = x * 2;
      int py = y * 2;
      if (cars[y][x]) {
        int dy = lastDir[y][x][0];
        int dx = lastDir[y][x][1];
        if (dx > 0)      c = color(255, 50, 50);
        else if (dx < 0) c = color(50, 255, 50);
        else if (dy > 0) c = color(50, 100, 255);
        else if (dy < 0) c = color(255, 255, 50);
        else             c = color(0);
        } else {
          c = color(0);
        }
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
  image(framebuffer, 0, 0, width, height);

  boolean[][] newCars = new boolean[HEIGHT][WIDTH];
  
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      if (!cars[y][x]) continue;

      int[][] directions = {
        {1, 0}, {1, 1}, {0, 1}, {-1, 1},
        {-1, 0}, {-1, -1}, {0, -1}, {1, -1}
      };

      int prevDy = lastDir[y][x][0];
      int prevDx = lastDir[y][x][1];
      
      if (prevDy != 0 || prevDx != 0) {
        for (int i = 0; i < directions.length; i++) {
          if (directions[i][0] == prevDy && directions[i][1] == prevDx) {
            int[] temp = directions[0];
            directions[0] = directions[i];
            directions[i] = temp;
            break;
          }
        }
      }
      
      for (int i = directions.length - 1; i > 1; i--) {
        int j = int(random(i + 1));
        if (j == 0) j = 1;
        int[] temp = directions[i];
        directions[i] = directions[j];
        directions[j] = temp;
      }
      
      boolean moved = false;
      int chosenDy = 0;
      int chosenDx = 0;
      
      for (int i = 0; i < 8; i++) {
        int dy = directions[i][0];
        int dx = directions[i][1];
        
        int nx = (x + dx + WIDTH) % WIDTH;
        int ny = (y + dy + HEIGHT) % HEIGHT;
        
        if (!cars[ny][nx]) {
          newCars[ny][nx] = true;
          moved = true;
          chosenDy = dy;
          chosenDx = dx;
          break;
        }
      }
      
      if (!moved) {
        newCars[y][x] = true;
      } else {
        lastDir[y][x][0] = chosenDy;
        lastDir[y][x][1] = chosenDx;
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
