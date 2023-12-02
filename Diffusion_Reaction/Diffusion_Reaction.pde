// Chemical diffusion-reaction //

float U[][];
float V[][];
float dU[][];
float dV[][];
int offsetW[][];
int offsetH[][];
float diffU = 0.19f;
float diffV = 0.09f;
float paramF = 0.062f;
float paramK = 0.062f;


void setup(){
  
  size(640, 480);
  background(255);
  
  U = new float[width][height];
  V = new float[width][height];
  dU = new float[width][height];
  dV = new float[width][height];
  offsetW = new int[width][2];
  offsetH = new int[height][2];
  
  diffU = random(0.12f, 0.25f);
  diffV = random(0.081f, 0.099f);
    
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++){
      U[x][y] = 0.5f * (1.0f + random(-1.0f, 1.0f));
      V[x][y] = 0.25f * (1.0f + random(-1.0f, 1.0f));
    }
  }

  for (int i = 1; i < width-1; i++) {
    offsetW[i][0] = i-1;
    offsetW[i][1] = i+1;
  }
 
  offsetW[0][0] = width-1;
  offsetW[0][1] = 1;
  offsetW[width-1][0] = width-2;
  offsetW[width-1][1] = 0;

  for (int i = 1; i < height-1; i++) {
    offsetH[i][0] = i-1;
    offsetH[i][1] = i+1;
  }
 
  offsetH[0][0] = height-1;
  offsetH[0][1] = 1;   
  offsetH[height-1][0] = height-2;
  offsetH[height-1][1] = 0;

}

void timestep(float F, float K, float diffU, float diffV) {
      
  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
           
      float u = U[i][j];
      float v = V[i][j];
           
      int left = offsetW[i][0]%width;
      int right = offsetW[i][1]%width;
      int up = offsetH[j][0]%height;
      int down = offsetH[j][1]%height;
           
      float uvv = u*v*v;    
        
      float lapU = (U[left][j] + U[right][j] + U[i][up] + U[i][down] - 4.0f * u);
      float lapV = (V[left][j] + V[right][j] + V[i][up] + V[i][down] - 4.0f * v);
           
      dU[i][j] = diffU * lapU - uvv + F * (1.0f - u);
      dV[i][j] = diffV * lapV + uvv - (K + F) * v;
    }
  }
       
  for (int j = 0; j < height; j++){
    for (int i= 0; i < width; i++) {
      U[i][j] += dU[i][j];
      V[i][j] += dV[i][j];
    }
  }
}

void draw(){
 
  timestep(paramF, paramK, diffU, diffV);
  
  loadPixels();
  
  for(int j=0; j<height; ++j) {
    for(int i=0; i<width; ++i) {
      
      float val = 255 * U[i][j];
      pixels[j*width+i] = color(val, val, val);
    
    }
  }
  
  updatePixels();
  
  // saveFrame("#####.jpg");
  
}
