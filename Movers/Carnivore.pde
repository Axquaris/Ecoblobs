class Carnivore extends Mover{
  
  Carnivore (float m, float x, float y) {
    super(m, x, y);
  }
  
  Carnivore (float m, float x, float y, PVector velocity) {
    super(m, x, y, velocity);
  }
  
  boolean update() {
    //Reset vars
    target.mult(0);
    tDivisor = 0;
    acceleration.mult(0);

    if (mass < 5) return true; //Self destruct
    
    closestThreat = 1000;
    
    for (int j = 0; j < carnivores.size(); j++) {
      if (!this.equals(carnivores.get(j))) {
        considerC(carnivores.get(j));
      }
    }
    for (int j = 0; j < movers.size(); j++) {
      if (!this.equals(movers.get(j))) {
        consider(movers.get(j));
        slurp(movers.get(j));
      }
    }
    
    //Movement Calculations
    target.div(tDivisor);
    acceleration = target;
    acceleration.setMag((mass*200)/DIVSIZE*1.25);
    acceleration.div(mass);
    
    velocity.add(acceleration);
    velocity.limit((1+mass/DIVSIZE)*1.25);
    noseEnd = new PVector(velocity.x*radius, velocity.y*radius);
    location.add(velocity);
    
    //Torification :)
    torify();
    
    //Division test
    if (mass > DIVSIZE && closestThreat > 100) {
      divide();
    }
    
    //Consider Metabolism
    mass *= metabolismRateC;
    radius = sqrt(mass/PI);
    
    return false;
  }

  void display() {
    radius = sqrt(mass/PI);
    
    stroke(20, 2, 0);
    strokeWeight(sWeight);
    fill(112+30 - 10*(mass/DIVSIZE), 30+30 - 10*(mass/DIVSIZE), 21+30 - 10*(mass/DIVSIZE), 200);
    
    displayGhosts();//Function from Blob class
    ellipse(location.x, location.y, radius, radius);
    line(location.x, location.y, location.x+noseEnd.x, location.y+noseEnd.y);
  }
  
  //Subfunction for displayGhosts in Blob class
  void displayGhost(int xShift, int yShift) {
    ellipse(location.x+xShift, location.y+yShift, radius, radius);
    line(location.x+xShift, location.y+yShift, location.x+xShift+noseEnd.x, location.y+yShift+noseEnd.y);
  }
  
  void considerC(Carnivore m) {
    PVector pointer = torusPointer(m.location, location);
    float distance = pointer.mag();
    distance = constrain(distance, 5.0, 3000.0);
    float strength = 0;
    
    //AI decisions
    if (distance < 1.5*(radius + m.radius)) strength = -1000/distance/distance;
    
    //Set importance of target
    pointer.mult(strength);
    //Add new desired location
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void consider(Mover m) {
    PVector pointer = torusPointer(m.location, location);
    float distance = pointer.mag();
    distance = constrain(distance, 5.0, 3000.0);
    float strength = 0;
    
    //AI decisions
    if (mass <= DIVSIZE) {
      strength = m.mass*10000/pow(distance, 4);
      if (distance < closestThreat) closestThreat = distance;
    } 
    else {
      strength = -m.mass/distance/distance;
      if (distance < closestThreat) closestThreat = distance;
    }
    
    //Set importance of target
    pointer.mult(strength);
    //Add new desired location
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void slurp(Mover m) {
    float distance = torusPointer(m.location, location).mag();
    if (distance <= radius + m.radius) {
      float slurp = 0;
      
      if (m.mass <= mass/25) slurp = m.mass;
      else slurp = mass/25;
      if (mass + slurp > DIVSIZE*1.5) slurp = DIVSIZE*1.5 - mass + 1;
      
      m.mass -= slurp;
      mass += slurp*0.8;
      m.radius = sqrt(m.mass/PI);
    }
  }
  
  void divide() {
    PVector split = new PVector(velocity.y, -velocity.x);
    split.mult(1);
    
    carnivores.add(new Carnivore(mass*0.5, location.x, location.y, PVector.add(velocity, split)));
    
    split.mult(-1);
    velocity.add(split);
    mass *= 0.5;
    radius = sqrt(mass/PI);
  }
  
  void focus() {
    sWeight = 6;
  }
  
  void unFocus() {
    sWeight = 2;
  }
}
