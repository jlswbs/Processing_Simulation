// Gray Scott reaction diffusion //

float a[][], aNext[][];
float b[][], bNext[][];
  
int w, h;
int ssize = 8;

float deltaT = random(1.2, 5.0);
float reactionRate = random(0.49, 0.62);
float aRate = random(0.038, 0.04);
float bRate = random(0.008, 0.01);
float F = 0.007999998;
float k = 0.031000046;

int iNext[];
int jNext[];
int iPrev[];
int jPrev[];
  
  
void setup() {

  size(640, 480);
  background(255);
  
  w = width;
  h = height;
  
  iNext = new int[w];
  jNext = new int[h];
  iPrev = new int[w];
  jPrev = new int[h];
 
  a = new float[w][h];
  b = new float[w][h];
  aNext = new float[w][h];
  bNext = new float[w][h];
  
  for(int i=0;i<w;++i)
  {
    iNext[i] = (i+1)%w;
    iPrev[i] = (i-1+w)%w;
  }
  
  for(int j=0;j<h;++j)
  {
    jNext[j] = (j+1)%h;
    jPrev[j] = (j-1+h)%h;
  }
  
   for(int i=-ssize+w/2;i<ssize+w/2;++i) {
    for(int j=-ssize+h/2;j<ssize+h/2;++j) {
      a[i][j] = 0.5+random(-.01,.01);
      b[i][j] = 0.25+random(-.01,.01);
    }
  }
  
}
  
  
void draw() {
  
  diffusion();
  reaction();
  
  loadPixels();

  for(int i=0;i<w;++i) 
  {
    for(int j=0;j<h;++j) 
    {
      float val = 255 * a[i][j];
      pixels[j*width+i] = color(val, val, val);
    }
  }
  
  updatePixels();
  
  // saveFrame("#####.jpg");

}

  
void diffusion() {
  
  for(int i=0;i<w;++i) 
  {
    for(int j=0;j<h;++j) 
    {
      aNext[i][j] = a[i][j]+aRate*deltaT*
        (a[iNext[i]][j]+a[iPrev[i]][j]
        +a[i][jNext[j]]+a[i][jPrev[j]]
        -4*a[i][j]);
      
      bNext[i][j] = b[i][j]+bRate*deltaT*
        (b[iNext[i]][j]+b[iPrev[i]][j]
        +b[i][jNext[j]]+b[i][jPrev[j]]
        -4*b[i][j]);
    }
  }
  
  float[][] temp;
  temp = a;
  a = aNext;
  aNext = temp;
  temp = b;
  b = bNext;
  bNext = temp;
}
  
void reaction() {
  
  float valA, valB;
  float currA;

  for(int i=0;i<w;++i) 
  {
    for(int j=0;j<h;++j) 
    {
      valA = deltaT*reactionA(a[i][j],b[i][j]);
      valB = deltaT*reactionB(a[i][j],b[i][j]);
      a[i][j] += valA;
      b[i][j] += valB;
    }
  }
}
  
float reactionA(float aVal, float bVal) { return reactionRate*(-aVal*bVal*bVal+F*(1-aVal)); }
  
float reactionB(float aVal, float bVal) { return reactionRate*(aVal*bVal*bVal-(F+k)*bVal); }
