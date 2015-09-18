class Plant {
  
  //Property Vars
  PVector location;
  PVector velocity;
  PVector acceleration;
  float radius;
  float mass;
  int divCycle;
  int divCycleLength;
  
  //Torrific Vars
  int ghostX;
  int ghostY;
  
  //GUI Vars
  int sWeight;
  
  Plant(float m, float x, float y) {
    //Property Vars
    mass = m;
    radius = sqrt(m/PI);
    location = new PVector(x, y);
    velocity = new PVector();
    acceleration = new PVector();
    divCycleLength = (int )(Math. random() * 5 + 10);
    divCycle = divCycleLength;
    
    //Torrific Vars
    ghostX = 0;
    ghostY = 0;
    
    sWeight = 2;
  }
  
  Plant(float m, float x, float y, PVector velocity) {
    this(m, x, y);
    this.velocity = new PVector(velocity.x, velocity.y);
  }
  
  boolean update() {
    if (mass < 5) return true; //Self-destruct
    
    acceleration.mult(0);
    
    //Movement
    acceleration = grid.getFlow(location);
    acceleration.setMag(radius*0.8);
    acceleration.div(mass);
    
    velocity.add(acceleration);
    velocity.limit(1);
    location.add(velocity);
    
    //Torification
    torify();
    
    //Division
    if (mass > DIVSIZEP && divCycle % divCycleLength == 0) {
      int neighbors;
      
      for (int i = 0; i < plants.size(); i++) {
        if (torusPointer(location, plants.get(i).location).mag() <= 100) neighbors++;
      }
      if (neighbors <= 4) divide();
    }
    if(divCycle > divCycleLength) divCycle = 0;
    else divCycle++;
    
    //Growth limitation
    if (mass < DIVSIZEP/2) mass *= growthRate;
    else {
      float g = map(mass, 0, DIVSIZEP*2, 0, growthRate-1);
      mass *= growthRate - g;
    }
    
    radius = sqrt(mass/PI);
    return false;
  }
  
  void divide() {
    PVector split = new PVector.random2D();
    split.mult(2);
    
    plants.add(new Plant(mass*0.5, location.x, location.y, PVector.add(velocity, split)));
    
    split.mult(-1);
    velocity.add(split);
    mass *= 0.5;
    radius = sqrt(mass/PI);
  }

  void display() {
    radius = sqrt(mass/PI);
    stroke(43, 71, 20);
    strokeWeight(sWeight);
    fill(93, 156, 51, 240);
    ellipse(location.x, location.y, radius, radius);
  }
  
  //Display toriod ghost if applicable
  void displayGhosts() {
    radius = sqrt(mass/PI);
    stroke(43, 71, 20);
    strokeWeight(sWeight);
    fill(93, 156, 51, 240);
    
    if (ghostX != 0 && ghostY != 0) {
      displayGhost(ghostX*sWidth, 0);
      displayGhost(0, ghostY * sHeight);
      displayGhost(ghostX*sWidth, ghostY * sHeight);
    }
    else if (ghostX != 0) displayGhost(ghostX*sWidth, 0);
    else if (ghostY != 0) displayGhost(0, ghostY * sHeight);
  }
  
  //Subfunction for displayGhost
  void displayGhost(int xShift, int yShift) {
    ellipse(location.x+xShift, location.y+yShift, radius, radius);
  }
  
  PVector torusPointer(PVector p1, PVector p2) {
    float x, y;
    float a, b;
    
    //Determine x
    if (p1.x > p2.x) {
      a = p1.x - p2.x;
      b = p1.x - (p2.x+sWidth);
      if (abs(a) <= abs(b)) x = a;
      else x = b;
    }
    else if (p1.x < p2.x) {
      a = p1.x - p2.x;
      b = p1.x - (p2.x-sWidth);
      if (abs(a) <= abs(b)) x = a;
      else x = b;
    }
    else x = 0;
    
    //Determine y
    if (p1.y > p2.y) {
      a = p1.y - p2.y;
      b = p1.y - (p2.y+sHeight);
      if (abs(a) <= abs(b)) y = a;
      else y = b;
    }
    else if (p1.y < p2.y) {
      a = p1.y - p2.y;
      b = p1.y - (p2.y-sHeight);
      if (abs(a) <= abs(b)) y = a;
      else y = b;
    }
    else y = 0;
    
    return new PVector(x, y);
  }
  
  //Makes sketch even more torrific than before :D
  void torify() {
    if (location.x <= PBORDERSIZE) {
      ghostX = 1;
      if (location.x <= 0) {
        location.x += sWidth;
        ghostX = -1;
      }
    }
    else if (location.x >= sWidth - PBORDERSIZE) {
      ghostX = -1;
      if (location.x >= sWidth) {
        location.x -= sWidth;
        ghostX = 1;
      }
    }
    else ghostX = 0;
    
    if (location.y <= PBORDERSIZE) {
      ghostY = 1;
      if (location.y <= 0) {
        location.y += sHeight;
        ghostY = -1;
      }
    }
    else if (location.y >= sHeight - PBORDERSIZE) {
      ghostY = -1;
      if (location.y >= sHeight) {
        location.y -= sHeight;
        ghostY = 1;
      }
    }
    else ghostY = 0;
  }
  void focus() {
    sWeight = 8;
  }
  
  void unFocus() {
    sWeight = 2;
  }
}


