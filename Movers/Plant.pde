class Plant extends Blob {
  
  PVector lastSquare;
  
  Plant(float m, float x, float y) {
    super(m, x, y);
    lastSquare = new PVector(-1, -1);
  }
  
  boolean update() {
    if (mass < 5) return true; //Self-destruct
    
    acceleration.mult(0);
    
    lastSquare = grid.updateSquare(location, lastSquare, this);
    
    //Growth limitation
    if (mass < DIVSIZE*2) mass *= growthRate;
    else {
      float g = map(mass, DIVSIZE*2, 10000, 0, growthRate-1);
      mass *= growthRate - g;
    }
    
    acceleration = grid.getFlow(location);
    acceleration.setMag(100);
    acceleration.div(mass);
    
    velocity.add(acceleration);
    velocity.limit(1);
    location.add(velocity);
    
    torify();
    
    radius = sqrt(mass/PI);
    return false;
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


