// Physarum chemotax trails - toroidal wrapping //

int WIDTH = 480;
int HEIGHT = 270;

int NUM_SPECIES = 4;
int AGENTS_PER_SPECIES = 50;
int TOTAL_AGENTS = NUM_SPECIES * AGENTS_PER_SPECIES;

float MOVE_SPEED = 1.0;
float SENSOR_DISTANCE = 5.0;
float SENSOR_ANGLE = 0.8;
float DEPOSIT_AMOUNT = 100.0;
float DECAY_RATE = 0.99;
float DIFFUSE_RATE = 0.1;

PImage framebuffer;

boolean saving = false;
int frameCounter = 0;
String saveDir = "frames";

class Agent {
  float x;
  float y;
  float angle;
  int species;
  
  Agent(float x, float y, float angle, int species) {
    this.x = x;
    this.y = y;
    this.angle = angle;
    this.species = species;
  }
}

float[][][] trail;
float[][] trailTemp;
color[] speciesColors;
Agent[] agents;
PGraphics buffer;
int frameCount = 0;

void setup() {
  size(100, 100, P2D);
  surface.setSize(WIDTH, HEIGHT);
  
  framebuffer = createImage(WIDTH, HEIGHT, RGB);
  noSmooth();
  
  trail = new float[NUM_SPECIES][WIDTH][HEIGHT];
  trailTemp = new float[WIDTH][HEIGHT];
  speciesColors = new color[NUM_SPECIES];
  agents = new Agent[TOTAL_AGENTS];
  
  initializeColors();
  initializeAgents();
  
  frameRate(60);
}

void draw() {
  updateSimulation();
  renderToBuffer();
}

void initializeColors() {
  for (int i = 0; i < NUM_SPECIES; i++) {
    float hue = (float)i / (float)NUM_SPECIES;
    int r, g, b;
    
    if (hue < 0.166) {
      r = 255; 
      g = (int)(hue * 6.0 * 255); 
      b = 0;
    } else if (hue < 0.333) {
      r = (int)((0.333 - hue) * 6.0 * 255); 
      g = 255; 
      b = 0;
    } else if (hue < 0.5) {
      r = 0; 
      g = 255; 
      b = (int)((hue - 0.333) * 6.0 * 255);
    } else if (hue < 0.666) {
      r = 0; 
      g = (int)((0.666 - hue) * 6.0 * 255); 
      b = 255;
    } else if (hue < 0.833) {
      r = (int)((hue - 0.666) * 6.0 * 255); 
      g = 0; 
      b = 255;
    } else {
      r = 255; 
      g = 0; 
      b = (int)((1.0 - hue) * 6.0 * 255);
    }
    
    speciesColors[i] = color(r, g, b);
  }
}

void initializeAgents() {
  for (int s = 0; s < NUM_SPECIES; s++) {
    for (int y = 0; y < HEIGHT; y++) {  
      for (int x = 0; x < WIDTH; x++) {
        trail[s][x][y] = 0.0;
      }
    }
  }
  
  for (int s = 0; s < NUM_SPECIES; s++) {
    for (int a = 0; a < AGENTS_PER_SPECIES; a++) {
      int idx = s * AGENTS_PER_SPECIES + a;
      agents[idx] = new Agent(
        random(WIDTH),
        random(HEIGHT),
        random(TWO_PI),
        s
      );
    }
  }
}

int wrapX(int x) {
  if (x < 0) return WIDTH + x;
  if (x >= WIDTH) return x - WIDTH;
  return x;
}

int wrapY(int y) {
  if (y < 0) return HEIGHT + y;
  if (y >= HEIGHT) return y - HEIGHT;
  return y;
}

float senseTrail(int species, float x, float y) {
  int ix = wrapX((int)x);
  int iy = wrapY((int)y);
  return trail[species][ix][iy];
}

float senseEnemyTrail(int species, float x, float y) {
  int ix = wrapX((int)x);
  int iy = wrapY((int)y);
  
  float enemySum = 0.0;
  for (int s = 0; s < NUM_SPECIES; s++) {
    if (s != species) {
      enemySum += trail[s][ix][iy];
    }
  }
  return enemySum;
}

void diffuseTrail(int species) {
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      float sum = trail[species][x][y];
      
      int left = wrapX(x - 1);
      int right = wrapX(x + 1);
      int up = wrapY(y - 1);
      int down = wrapY(y + 1);
      
      sum += trail[species][left][y] + trail[species][right][y];
      sum += trail[species][x][up] + trail[species][x][down];
      sum += trail[species][left][up] + trail[species][right][up];
      sum += trail[species][left][down] + trail[species][right][down];
      
      trailTemp[x][y] = sum / 9.0;
    }
  }
  
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      trail[species][x][y] = trail[species][x][y] * (1.0 - DIFFUSE_RATE) + 
                              trailTemp[x][y] * DIFFUSE_RATE;
    }
  }
}

void updateSimulation() {
  for (int i = 0; i < TOTAL_AGENTS; i++) {
    Agent ag = agents[i];
    
    float sensorAngleLeft = ag.angle + SENSOR_ANGLE;
    float sensorAngleRight = ag.angle - SENSOR_ANGLE;
    
    float senseForwardX = ag.x + cos(ag.angle) * SENSOR_DISTANCE;
    float senseForwardY = ag.y + sin(ag.angle) * SENSOR_DISTANCE;
    
    float senseLeftX = ag.x + cos(sensorAngleLeft) * SENSOR_DISTANCE;
    float senseLeftY = ag.y + sin(sensorAngleLeft) * SENSOR_DISTANCE;
    
    float senseRightX = ag.x + cos(sensorAngleRight) * SENSOR_DISTANCE;
    float senseRightY = ag.y + sin(sensorAngleRight) * SENSOR_DISTANCE;
    
    float weightForward = senseTrail(ag.species, senseForwardX, senseForwardY);
    float weightLeft = senseTrail(ag.species, senseLeftX, senseLeftY);
    float weightRight = senseTrail(ag.species, senseRightX, senseRightY);
    
    float enemyForward = senseEnemyTrail(ag.species, senseForwardX, senseForwardY);
    float enemyLeft = senseEnemyTrail(ag.species, senseLeftX, senseLeftY);
    float enemyRight = senseEnemyTrail(ag.species, senseRightX, senseRightY);
    
    weightForward -= enemyForward * 0.5;
    weightLeft -= enemyLeft * 0.5;
    weightRight -= enemyRight * 0.5;
    
    float randomSteer = (random(1) - 0.5) * 0.3;
    
    if (weightForward > weightLeft && weightForward > weightRight) {
      ag.angle += randomSteer;
    } else if (weightLeft > weightRight) {
      ag.angle += SENSOR_ANGLE + randomSteer;
    } else if (weightRight > weightLeft) {
      ag.angle -= SENSOR_ANGLE + randomSteer;
    } else {
      ag.angle += (random(1) - 0.5) * 1.0;
    }
    
    float newX = ag.x + cos(ag.angle) * MOVE_SPEED;
    float newY = ag.y + sin(ag.angle) * MOVE_SPEED;
    
    if (newX < 0) newX += WIDTH;
    if (newX >= WIDTH) newX -= WIDTH;
    if (newY < 0) newY += HEIGHT;
    if (newY >= HEIGHT) newY -= HEIGHT;
    
    ag.x = newX;
    ag.y = newY;
    
    int ix = wrapX((int)ag.x);
    int iy = wrapY((int)ag.y);
    
    trail[ag.species][ix][iy] += DEPOSIT_AMOUNT;
    if (trail[ag.species][ix][iy] > 100.0) {
      trail[ag.species][ix][iy] = 100.0;
    }
  }
  
  for (int s = 0; s < NUM_SPECIES; s++) {
    for (int y = 0; y < HEIGHT; y++) {
      for (int x = 0; x < WIDTH; x++) {
        trail[s][x][y] *= DECAY_RATE;
        if (trail[s][x][y] < 0.01) {
          trail[s][x][y] = 0.0;
        }
      }
    }
    
    if (frameCount % 3 == 0) {
      diffuseTrail(s);
    }
  }
  
  frameCount++;
}

void renderToBuffer() {
  framebuffer.loadPixels();
  
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      float maxTrail = 0.0;
      int dominant = -1;
      
      for (int s = 0; s < NUM_SPECIES; s++) {
        if (trail[s][x][y] > maxTrail) {
          maxTrail = trail[s][x][y];
          dominant = s;
        }
      }
      
      color c = color(0);
      
      if (dominant >= 0 && maxTrail > 0.5) {
        float intensity = (maxTrail > 100.0) ? 1.0 : maxTrail / 100.0;
        c = lerpColor(color(0), speciesColors[dominant], intensity);
      }
      
      for (int i = 0; i < TOTAL_AGENTS; i++) {
        int ax = wrapX((int)agents[i].x);
        int ay = wrapY((int)agents[i].y);
        if (ax == x && ay == y) {
          c = speciesColors[agents[i].species];
          break;
        }
      }
      
      framebuffer.pixels[y * WIDTH + x] = c;
    }
  }
  
  framebuffer.updatePixels();
  image(framebuffer, 0, 0);
  
  if (saving) {
    saveFrame(saveDir + "/frame_" + nf(frameCounter++, 4) + ".png");
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    initializeAgents();
    frameCount = 0;
  }
  if (key == 's' || key == 'S') saving = !saving;
}
