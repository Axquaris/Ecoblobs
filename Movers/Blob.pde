class Blob {
  
  //Property Vars
  PVector location;
  PVector velocity;
  PVector acceleration;
  float radius;
  float mass;
  
  //Torrific Vars
  int ghostX;
  int ghostY;
  
  //GUI Vars
  int sWeight;
  
  Blob(float m, float x, float y) {
    //Property Vars
    mass = m;
    radius = sqrt(m/PI);
    location = new PVector(x, y);
    velocity = new PVector();
    acceleration = new PVector();
    
    //Torrific Vars
    ghostX = 0;
    ghostY = 0;
    
    //GUI Var
    sWeight = 2;
  }
}
