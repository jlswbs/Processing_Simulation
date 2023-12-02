// Chemical diffusion-reaction //

float u[][];
float v[][];
float u1[][];
float v1[][];
float dt = 1.2, h = 0.1, h2 = h*h;
float a = 0.024, b = 0.078;
float cu = 0.002, cv = 0.001;


void setup(){
  
  size(640, 480);
  background(255);
  
  u = new float[width+2][height+2];
  v = new float[width+2][height+2];
  u1 = new float[width+2][height+2];
  v1 = new float[width+2][height+2];
  
  a = random(0.021f, 0.027f);
  b = random(0.074f, 0.081f);

  for (int j = 0; j < height; j++){
    for (int i = 0; i < width; i++){
      u[i][j] = 0.5f + random(-0.5f, 0.5f);
      v[i][j] = 0.125f + random(-0.25f, 0.25f);
    }
  }

}

void draw(){
 
  boundary();
  update();
  
  loadPixels();
  
  for(int j=0; j<height; ++j) {
    for(int i=0; i<width; ++i) {
      
      float val = 255 * u[i][j];
      pixels[j*width+i] = color(val, val, val);
    
    }
  }
  
  updatePixels();
  
  // saveFrame("#####.jpg");
  
}


void update(){
  
  for (int j = 1; j < height; j++) {
    for (int i = 1; i < width; i++) {
   
      float Du = (u[i+1][j] + u[i][j+1] + u[i-1][j] + u[i][j-1] - 4.0f * u[i][j]) / h2;
      float Dv = (v[i+1][j] + v[i][j+1] + v[i-1][j] + v[i][j-1] - 4.0f * v[i][j]) / h2;
      float f = - u[i][j] * sq(v[i][j]) + a * (1.0f - u[i][j]);
      float g = u[i][j] * sq(v[i][j]) - b * v[i][j];
      u1[i][j] = u[i][j] + (cu * Du + f) * dt;
      v1[i][j] = v[i][j] + (cv * Dv + g) * dt;
    }
  }
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      u[i][j] = u1[i][j];
      v[i][j] = v1[i][j];
    }
  }
  
}

void boundary(){
 
  for (int j = 0; j < height; j++){
    for (int i = 0; i < width; i++){
      u[i][0] = u[i][height];
      u[i][height+1] = u[i][1];
      u[0][j] = u[width][j];
      u[width+1][j] = u[1][j];
      v[i][0] = v[i][height];
      v[i][height+1] = v[i][j];
      v[0][j] = v[width][j];
      v[width+1][j] = v[1][j];
     }
  }
  
}
