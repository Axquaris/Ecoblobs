class Mover extends Blob{
  //Property Vars
  PVector noseEnd;
  
  //AI Vars
  PVector target;
  float tDivisor;
  float closestThreat;
  
  Mover(float m, float x, float y) {
    super(m, x, y);
    
    //Property Vars
    noseEnd = new PVector();
    
    //AI Vars
    target = new PVector();
    tDivisor = 0;
    closestThreat = 1000;
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

    if (mass < 5) return true; //Self destruct
    
    closestThreat = 1000;
    
    for (int j = 0; j < carnivores.size(); j++) {
      if (!this.equals(carnivores.get(j))) {
        consider(carnivores.get(j));
      }
    }
    for (int j = 0; j < movers.size(); j++) {
      if (!this.equals(movers.get(j))) {
        consider(movers.get(j));
      }
    }
    for (int j = 0; j < plants.size(); j++) {
      if (mass <= DIVSIZE) considerP(plants.get(j));
      slurpP(plants.get(j));
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
    if (mass > DIVSIZE && closestThreat > 300) {
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
    strokeWeight(sWeight);
    fill(150 - 100*(mass/DIVSIZE), 200);
    
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
    strength = -10000*m.mass/distance;
    if (distance < closestThreat) closestThreat = distance;
    
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
    if (distance < 2*(radius + m.radius)) strength = -10/distance/distance;
    
    //Set importance of target
    pointer.mult(strength);
    //Add new desired location
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void considerP(Plant m) {
    PVector pointer = torusPointer(m.location, location);
    float distance = pointer.mag();
    distance = constrain(distance, 5.0, 3000.0);
    
    //AI decisions
    float strength = m.mass/pow(distance, 3);
    
    //Set importance of target
    pointer.mult(strength);
    //Add new desired location
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void slurpP(Plant m) {
    float distance = torusPointer(m.location, location).mag();
    if (distance <= radius + m.radius && frame > 4) {
      float slurp = 0;
      
      if (m.mass <= mass/25) slurp = m.mass;
      else slurp = mass/25;
      if (mass + slurp > DIVSIZE*1.5) slurp = DIVSIZE*1.5 - mass + 1;
      
      m.mass -= slurp;
      mass += slurp*0.5;
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
  
  void focus() {
    sWeight = 6;
  }
  
  void unFocus() {
    sWeight = 2;
  }
}
