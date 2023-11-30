// Turing patterns 01 //

int scl = 4, dirs = 9, lim = 128;
int dx, dy, w, h, s;
float[] pat;
float[] pnew;
float[][] pmedian;
float[][] prange;
float[][] pvar;
  
void setup() {
  
  size(640, 480);
  background(255);
  
  w = width;
  h = height;
  s = w*h;
  
  pat = new float[s];

  for(int i=0; i<s; i++) pat[i] = random(TWO_PI);
  
}

 
void draw() {
  
  float R = random(TWO_PI);
  pnew = new float[s];

  for(int i=0; i<s; i++) pnew[i] = pat[i];

  pmedian = new float[s][scl];
  prange = new float[s][scl];
  pvar = new float[s][scl];

  for(int i=0; i<scl; i++) {
    
    float d = (2<<i);
     
    for(int j=0; j<dirs; j++) {
      
      float dir = j*TWO_PI/dirs+R;
      int dx = int (d * cos(dir));
      int dy = int (d * sin(dir));
      for(int l=0; l<s; l++) { 
        int x1 = l + dx, y1 = l/w + dy;
        if(x1<0) x1 = w-1-(-x1-1); if(x1>=w) x1 = x1%w;
        if(y1<0) y1 = h-1-(-y1-1); if(y1>=h) y1 = y1%h;
        pmedian[l][i] += pat[x1+y1*w] / dirs;
         
      }
    }

    for(int j=0; j<dirs; j++) {
      float dir = j*TWO_PI/dirs+R;
      int dx = int (d * cos(dir));
      int dy = int (d * sin(dir));
      for(int l=0; l<s; l++) { 
        
        int x1 = l + dx, y1 = l/w + dy;
        if(x1<0) x1 = w-1-(-x1-1); if(x1>=w) x1 = x1%w;
        if(y1<0) y1 = h-1-(-y1-1); if(y1>=h) y1 = y1%h;
        pvar[l][i] += abs( pat[x1+y1*w]  - pmedian[l][i] ) / dirs;   
        prange[l][i] += pat[x1+y1*w] > (lim + i*10) ? +1 : -1;   
    
      }
    }    
  }
 
  for(int l=0; l<s; l++) { 

    int imin=0, imax=scl;
    float vmin = MAX_FLOAT;
    float vmax = -MAX_FLOAT;
    for(int i=0; i<scl; i+=1) {
      if (pvar[l][i] <= vmin) { vmin = pvar[l][i]; imin = i; }
      if (pvar[l][i] >= vmax) { vmax = pvar[l][i]; imax = i; }
    }
     
   for(int i=0; i<=imin; i++) pnew[l] += prange[l][i];
       
  }
 

  float vmin = MAX_FLOAT;
  float vmax = -MAX_FLOAT;
  for(int i=0; i<s; i++)  {
    if (pnew[i] < vmin) vmin = pnew[i];
  if (pnew[i] > vmax) vmax = pnew[i];
  }      
  float dv = vmax - vmin;
  for(int i=0; i<s; i++)
    pat[i] = (pnew[i] - vmin) * 255 / dv;
   

  for(int x=0; x<w; x++)
    for(int y=0; y<h; y++) {

      int i = x+y*w;
      float val = pat[i];
      stroke(val);
      point(x,y);
       
    }
    
  // saveFrame("#####.jpg");
     
}
