// Physarum growth - chemotax trails and plasmodium //

int WIDTH = 960;
int HEIGHT = 540;

int numAgents = 1500;
Agent[] agents;
float[][] trail;
float[][] diffusedTrail;

float sensorAngle = 25;
float sensorDistance = 8;
float turnAngle = 48;
float moveSpeed = 1;

float decayRate = 0.125;
float depositAmount = 7;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

void setup() {
  
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, ARGB);
  noSmooth();
  
  trail = new float[WIDTH][HEIGHT];
  diffusedTrail = new float[WIDTH][HEIGHT];
  
  agents = new Agent[numAgents];
  for (int i = 0; i < numAgents; i++) {
    agents[i] = new Agent(random(WIDTH), random(HEIGHT), random(TWO_PI));
  }
  
  frameRate(60);

}

void draw() {
  
  for (Agent a : agents) {
    a.sense();
    a.move();
    a.deposit();
  }
  
  diffuseAndDecay();
  
  framebuffer.loadPixels();
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      float val = trail[x][y];
      int idx = x + y * WIDTH;
      framebuffer.pixels[idx] = color(val * 0.3, val * 0.8, val * 1.2, val);
    }
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }

}

void diffuseAndDecay() {

  for (int x = 1; x < WIDTH - 1; x++) {
    for (int y = 1; y < HEIGHT - 1; y++) {
      float sum = 0;
      // 3x3 kernel
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          sum += trail[x + dx][y + dy];
        }
      }
      diffusedTrail[x][y] = sum / 9.0;
    }
  }
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      trail[x][y] = max(0, diffusedTrail[x][y] - decayRate);
    }
  }

}

float localDensity(int cx, int cy, int r) {
  
  float sum = 0;
  int count = 0;
  
  for (int dx = -r; dx <= r; dx++) {
    for (int dy = -r; dy <= r; dy++) {
      int x = constrain(cx + dx, 0, WIDTH - 1);
      int y = constrain(cy + dy, 0, HEIGHT - 1);
      sum += trail[x][y];
      count++;
    }
  }
  return sum / count;

}


class Agent {
  float x, y;
  float angle;
  float noiseOffset;
  
  Agent(float x, float y, float angle) {
    this.x = x;
    this.y = y;
    this.angle = angle;
    noiseOffset = random(1000);
  }
  
  float chemoResponse(float v, float localAvg) {
  
    float optimal = 70;
    float tolerance = 50;
    float attract = exp(-sq(v - optimal) / (2 * sq(tolerance)));
    float repel = map(localAvg, 80, 200, 0, 1);
    repel = constrain(repel, 0, 1);
  
    return attract - repel * 0.8;

  }

  void sense() {
    
    float leftAngle = angle - radians(sensorAngle);
    float centerAngle = angle;
    float rightAngle = angle + radians(sensorAngle);

    float lx = x + cos(leftAngle) * sensorDistance;
    float ly = y + sin(leftAngle) * sensorDistance;

    float cx = x + cos(centerAngle) * sensorDistance;
    float cy = y + sin(centerAngle) * sensorDistance;

    float rx = x + cos(rightAngle) * sensorDistance;
    float ry = y + sin(rightAngle) * sensorDistance;

    int lix = constrain((int)lx, 0, WIDTH - 1);
    int liy = constrain((int)ly, 0, HEIGHT - 1);
    int cix = constrain((int)cx, 0, WIDTH - 1);
    int ciy = constrain((int)cy, 0, HEIGHT - 1);
    int rix = constrain((int)rx, 0, WIDTH - 1);
    int riy = constrain((int)ry, 0, HEIGHT - 1);

    float leftRaw = trail[lix][liy];
    float centerRaw = trail[cix][ciy];
    float rightRaw = trail[rix][riy];

    float leftDensity = localDensity(lix, liy, 3);
    float centerDensity = localDensity(cix, ciy, 3);
    float rightDensity = localDensity(rix, riy, 3);

    float leftSensor   = chemoResponse(leftRaw, leftDensity);
    float centerSensor = chemoResponse(centerRaw, centerDensity);
    float rightSensor  = chemoResponse(rightRaw, rightDensity);

    if (centerSensor > leftSensor && centerSensor > rightSensor) {
    } else if (centerSensor < leftSensor && centerSensor < rightSensor) {
      angle += random(-1, 1) * radians(turnAngle);
    } else if (leftSensor > rightSensor) {
      angle -= radians(turnAngle);
    } else if (rightSensor > leftSensor) {
      angle += radians(turnAngle);
    }
  }

  float sampleTrail(float sx, float sy) {
  
    int ix = constrain((int)sx, 0, WIDTH - 1);
    int iy = constrain((int)sy, 0, HEIGHT - 1);
    return trail[ix][iy];
    
  }
  
  void move() {
    
    float noiseTurn = map(noise(noiseOffset, frameCount * 0.01), 0, 1, -1, 1);
    angle += noiseTurn * radians(10);
  
    noiseOffset += 0.01;

    float newX = x + cos(angle) * moveSpeed;
    float newY = y + sin(angle) * moveSpeed;
    
    if (newX < 0 || newX >= WIDTH || newY < 0 || newY >= HEIGHT) {
      angle = random(TWO_PI);
      newX = constrain(newX, 0, WIDTH - 1);
      newY = constrain(newY, 0, HEIGHT - 1);
    }
    
    x = newX;
    y = newY;
  }
  
  void deposit() {
    int ix = constrain((int)x, 0, WIDTH - 1);
    int iy = constrain((int)y, 0, HEIGHT - 1);
    trail[ix][iy] = min(255, trail[ix][iy] + depositAmount);
  }
 
}

void keyPressed() {
  
  if (key == 'r' || key == 'R') setup();
  if (key == 's' || key == 'S') saving = !saving;

}
