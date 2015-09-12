class Mover {

  PVector location;
  PVector velocity, noseEnd;
  PVector acceleration;
  //Vars to calculate target
  PVector target;
  float tDivisor;
  
  float radius;
  float mass;
  float closestThreat;
  
  Mover(float m, float x, float y) {
    mass = m;
    radius = sqrt(m/PI);
    
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    noseEnd = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    target = new PVector(0, 0);
    tDivisor = 0;
    
    closestThreat = 0;
  }
  
  Mover(float m, float x, float y, PVector velocity) {
    mass = m;
    radius = sqrt(m/PI);
    
    location = new PVector(x, y);
    this.velocity = new PVector(velocity.x, velocity.y);
    noseEnd = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    target = new PVector(0, 0);
    tDivisor = 0;
    
    closestThreat = 0;
  }
  
  void addTarget(PVector aTarget, float strength) {
    target.add(aTarget);
    tDivisor += abs(strength);
  }

  boolean update() {
    target.mult(0);
    tDivisor = 0;

    if (mass < 20) return true; //Self destruct
    //Division test
    else if (mass > DIVSIZE && closestThreat > 500) {
      divide();
    }
    
    closestThreat = 1000;
    
    for (int j = 0; j < movers.size(); j++) {
      if (!this.equals(movers.get(j))) {
        consider(movers.get(j));
        slurp(movers.get(j));
      }
    }
    if (mass <= DIVSIZE) {
      for (int j = 0; j < plants.size(); j++) {
        if (!this.equals(plants.get(j))) {
          considerP(plants.get(j));
          slurpP(plants.get(j));
        }
      }
    }
    
    //TODO create a considerBoundaries() function to do below with better integreation
    if (location.x < BORDERSIZE) velocity.x += pow(-location.x+BORDERSIZE, 1);
    else if (location.x > width-BORDERSIZE) velocity.x -= pow(location.x-(width-BORDERSIZE), 1);
    if (location.y < BORDERSIZE) velocity.y += pow(-location.y+BORDERSIZE, 1);
    else if (location.y > sHeight-BORDERSIZE) velocity.y -= pow(location.y-(sHeight-BORDERSIZE), 1);
    
    //Movement Calculations
    target.div(tDivisor);
    acceleration = target;
    acceleration.setMag((mass*200)/DIVSIZE);
    
    acceleration.div(mass);
    velocity.add(acceleration);
    velocity.limit(1+mass/DIVSIZE);
    noseEnd = new PVector(velocity.x*radius, velocity.y*radius);
    location.add(velocity);
    
    acceleration.mult(0);
    
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
  }
  
  void consider(Mover m) {
    PVector pointer = PVector.sub(m.location, location);
    float distance = pointer.mag();
    distance = constrain(distance, 5.0, 3000.0);
    float strength;
    
    //AI decisions
    if (mass <= DIVSIZE) {
      if (mass > m.mass * NOMFACTOR) strength = m.mass/pow(distance, 2);
      else if (m.mass > mass * NOMFACTOR * .9) strength = -m.mass*500/distance/distance/distance;
      else if (distance < 3*(radius + m.radius)) strength = -10000/distance/distance/distance;
      else strength = 0;
    }
    else {
      if (m.mass > mass * 0.25) {
        strength = -m.mass/distance/distance;
        if (distance < closestThreat) closestThreat = distance;
        else if (distance < 3*(radius + m.radius)) strength = -10000/distance/distance/distance;
      }
      else strength = 0;
    }
    
    //Set importance of target
    pointer.setMag(strength);
    //Add new desired location
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void slurp(Mover m) {
    float distance = PVector.sub(m.location, location).mag();
    if (distance <= radius + m.radius && mass > m.mass * NOMFACTOR) {
      float slurp = 0;
      
      if (m.mass <= mass/25) slurp = m.mass;
      else slurp = mass/25;
      if (mass + slurp > DIVSIZE*1.1) slurp = DIVSIZE*1.1 - mass + 1;
      
      m.mass -= slurp;
      mass += slurp;
      m.radius = sqrt(m.mass/PI);
    }
  }
  
  void considerP(Plant m) {
    PVector pointer = PVector.sub(m.location, location);
    float distance = pointer.mag();
    distance = constrain(distance, 5.0, 3000.0);
    
    //AI decision
    float strength = m.mass/pow(distance, 2);
    
    //Set importance of target
    pointer.setMag(strength);
    //Add new desired location
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void slurpP(Plant m) {
    float distance = PVector.sub(m.location, location).mag();
    if (distance <= radius + m.radius) {
      float slurp = 0;
      
      if (m.mass <= mass/50) slurp = m.mass;
      else slurp = mass/50;
      if (mass + slurp > DIVSIZE*1.1) slurp = DIVSIZE*1.1 - mass + 1;
      
      m.mass -= slurp;
      mass += slurp*0.5;
      m.radius = sqrt(m.mass/PI);
    }
  }
  
  void divide() {
    velocity.mult(-1);
    movers.add(new Mover(mass*0.5, location.x, location.y, velocity));
    velocity.mult(-1);
    
    mass *= 0.5;
    radius = sqrt(mass/PI);
  }

}
