class Mover {
  //Property Vars
  PVector location;
  PVector velocity, noseEnd;
  PVector acceleration;
  float radius;
  float mass;
  
  //AI Vars
  PVector target;
  float tDivisor;
  float closestThreat;
  
  //Torrific Vars
  int ghostX;
    // 0 = no change
    // 1 = ghost on right
    // -1 = ghost on left
  int ghostY;
    // 0 = no change
    // 1 = ghost on bottom
    // -1 = ghost on top
  
  Mover(float m, float x, float y) {
    //Property Vars
    location = new PVector(x, y);
    velocity = new PVector();
    noseEnd = new PVector();
    acceleration = new PVector();
    mass = m;
    radius = sqrt(m/PI);
    
    //AI Vars
    target = new PVector();
    tDivisor = 0;
    closestThreat = 1000;
    
    //Torrific Vars
    ghostX = 0;
    ghostY = 0;
  }
  
  Mover(float m, float x, float y, PVector velocity) {
    this(m, x, y);
    this.velocity = new PVector(velocity.x, velocity.y);
   }
  
  void addTarget(PVector aTarget, float strength) {
    target.add(aTarget);
    tDivisor += abs(strength);
  }

  boolean update() {
    //Reset vars
    target.mult(0);
    tDivisor = 0;
    acceleration.mult(0);

    if (mass < 20) return true; //Self destruct
    
    closestThreat = 1000;
    
    for (int j = 0; j < movers.size(); j++) {
      if (!this.equals(movers.get(j))) {
        consider(movers.get(j));
        slurp(movers.get(j));
      }
    }
    for (int j = 0; j < plants.size(); j++) {
      if (!this.equals(plants.get(j))) {
        if (mass <= DIVSIZE) considerP(plants.get(j));
        slurpP(plants.get(j));
      }
    }
    
    //Movement Calculations
    target.div(tDivisor);
    acceleration = target;
    acceleration.setMag((mass*200)/DIVSIZE);
    
    acceleration.div(mass);
    velocity.add(acceleration);
    velocity.limit(1+mass/DIVSIZE);
    noseEnd = new PVector(velocity.x*radius, velocity.y*radius);
    location.add(velocity);
    
    //Torification :)
    torify();
    
    //Division test
    if (mass > DIVSIZE && closestThreat > 100) {
      divide();
    }
    
    //Consider Metabolism
    mass *= metabolismRate;
    radius = sqrt(mass/PI);
    
    return false;
  }

  void display() {
    radius = sqrt(mass/PI);
    stroke(0);
    strokeWeight(2);
    fill(150 - 100*(mass/DIVSIZE), 200);
    ellipse(location.x, location.y, radius, radius);
    line(location.x, location.y, location.x+noseEnd.x, location.y+noseEnd.y);
    line(location.x, location.y, location.x+target.x, location.y+target.y);
  }
  
  void consider(Mover m) {
    PVector pointer = torusPointer(m.location, location);
    float distance = pointer.mag();
    distance = constrain(distance, 5.0, 3000.0);
    float strength;
    
    //AI decisions
    if (mass <= DIVSIZE) {
      if (mass > m.mass * NOMFACTOR) strength = m.mass/pow(distance, 2);
      else if (m.mass > mass * NOMFACTOR * .95) {
        strength = -m.mass* 200/distance/distance/distance;
        if (m.mass > mass * 0.45 && distance < closestThreat) closestThreat = distance;
      }
      else if (distance < 3*(radius + m.radius)) strength = -10000/distance/distance/distance;
      else strength = 0;
      
      if (distance < closestThreat) closestThreat = distance;
    }
    else {
      if (m.mass > mass * 0.45) {
        strength = -m.mass/distance/distance;
        if (distance < closestThreat) closestThreat = distance;
      }
      else if (distance < 3*(radius + m.radius) && distance >= closestThreat) strength = -10000/distance/distance/distance;
      else strength = 0;
    }
    
    //Set importance of target
    pointer.mult(strength);
    //Add new desired location
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void slurp(Mover m) {
    float distance = torusPointer(m.location, location).mag();
    if (distance <= radius + m.radius && mass > m.mass * NOMFACTOR) {
      float slurp = 0;
      
      if (m.mass <= mass/25) slurp = m.mass;
      else slurp = mass/25;
      if (mass + slurp > DIVSIZE*1.5) slurp = DIVSIZE*1.5 - mass + 1;
      
      m.mass -= slurp;
      mass += slurp;
      m.radius = sqrt(m.mass/PI);
    }
  }
  
  void considerP(Plant m) {
    PVector pointer = torusPointer(m.location, location);
    float distance = pointer.mag();
    distance = constrain(distance, 5.0, 3000.0);
    
    //AI decision
    float strength = m.mass/pow(distance, 2)/4;
    
    //Set importance of target
    pointer.mult(strength);
    //Add new desired location
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void slurpP(Plant m) {
    float distance = torusPointer(m.location, location).mag();
    if (distance <= radius + m.radius) {
      float slurp = 0;
      
      if (m.mass <= mass/30) slurp = m.mass;
      else slurp = mass/30;
      if (mass + slurp > DIVSIZE*1.5) slurp = DIVSIZE*1.5 - mass + 1;
      
      m.mass -= slurp;
      mass += slurp*0.3;
      m.radius = sqrt(m.mass/PI);
    }
  }
  
  void divide() {
    PVector split = new PVector(velocity.y, -velocity.x);
    split.mult(1);
    
    movers.add(new Mover(mass*0.5, location.x, location.y, PVector.add(velocity, split)));
    
    split.mult(-1);
    velocity.add(split);
    mass *= 0.5;
    radius = sqrt(mass/PI);
  }
  
  //Find the shortest path between 2 objects on torus
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
  
  //Display toriod ghost if applicable
  void displayGhosts() {
    radius = sqrt(mass/PI);
    stroke(0);
    strokeWeight(2);
    fill(150 - 100*(mass/DIVSIZE), 200);
    
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
    line(location.x+xShift, location.y+yShift, location.x+xShift+noseEnd.x, location.y+yShift+noseEnd.y);
  }
  
  //Makes sketch even more torrific than before :D
  void torify() {
    if (location.x <= BORDERSIZE) {
      ghostX = 1;
      if (location.x <= 0) {
        location.x += sWidth;
        ghostX = -1;
      }
    }
    else if (location.x >= sWidth - BORDERSIZE) {
      ghostX = -1;
      if (location.x >= sWidth) {
        location.x -= sWidth;
        ghostX = 1;
      }
    }
    else ghostX = 0;
    
    if (location.y <= BORDERSIZE) {
      ghostY = 1;
      if (location.y <= 0) {
        location.y += sHeight;
        ghostY = -1;
      }
    }
    else if (location.y >= sHeight - BORDERSIZE) {
      ghostY = -1;
      if (location.y >= sHeight) {
        location.y -= sHeight;
        ghostY = 1;
      }
    }
    else ghostY = 0;
  }
}
