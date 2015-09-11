class Mover {

  PVector location;
  PVector velocity, debug;
  PVector acceleration;
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
    debug = new PVector(0, 0);
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
    debug = new PVector(0, 0);
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
    ///////////////
    target.mult(0);
    tDivisor = 0;
    ///////////////
    if (mass < 50) return true;
    
    closestThreat = 9999;
    
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
  
    if (location.x < BORDERSIZE) velocity.x += pow(-location.x+BORDERSIZE, 1);
    else if (location.x > width-BORDERSIZE) velocity.x -= pow(location.x-(width-BORDERSIZE), 1);
    if (location.y < BORDERSIZE) velocity.y += pow(-location.y+BORDERSIZE, 1);
    else if (location.y > sHeight-BORDERSIZE) velocity.y -= pow(location.y-(sHeight-BORDERSIZE), 1);
    
    target.div(tDivisor);
    acceleration = target;
    acceleration.setMag((mass*200)/DIVSIZE);
    
    acceleration.div(mass);
    velocity.add(acceleration);
    velocity.limit(1+mass/DIVSIZE);
    debug = new PVector(velocity.x*radius, velocity.y*radius);
    location.add(velocity);
    
    //target.mult(0);
    //tDivisor = 0;
    acceleration.mult(0);
    
    mass *= metabolismRate;
    radius = sqrt(mass/PI);
    
    if (mass > DIVSIZE && closestThreat > 100) {
      divide();
    }
    
    return false;
  }

  void display() {
    radius = sqrt(mass/PI);
    stroke(0);
    strokeWeight(2);
    fill(0, 50 + 100*(mass/DIVSIZE));
    line(location.x, location.y, location.x+debug.x, location.y+debug.y);
    ///////////////////////////////////////////////////////////////////////
    line(location.x, location.y, location.x+target.x, location.y+target.y);
    ///////////////////////////////////////////////////////////////////////
    ellipse(location.x, location.y, radius, radius);
  }
  
  void consider(Mover m) {
    PVector pointer = PVector.sub(m.location, location);
    float distance = pointer.mag();
    distance = constrain(distance, 5.0, 3000.0);
    float strength;
    
    if (mass <= DIVSIZE) {
      if (mass > m.mass * NOMFACTOR) strength = m.mass/pow(distance, 2);
      else if (m.mass > mass * NOMFACTOR) strength = -m.mass/distance/distance;
      else if (distance < 3*(radius + m.radius)) strength = -10000/distance/distance/distance;
      else strength = 0;
    }
    else {
      if (m.mass > mass * 0.5) {
        strength = -m.mass/distance/distance;
        if (distance < closestThreat) closestThreat = distance;
        else if (distance < 3*(radius + m.radius)) strength = -10000/distance/distance/distance;
      }
      else strength = 0;
    }
    
    pointer.mult(strength);
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
    float strength = m.mass/pow(distance, 2);
    
    pointer.mult(strength);
    if (strength != 0) addTarget(pointer, strength);
  }
  
  void slurpP(Plant m) {
    float distance = PVector.sub(m.location, location).mag();
    if (distance <= radius + m.radius) {
      float slurp = 0;
      
      if (m.mass <= mass/25) slurp = m.mass;
      else slurp = mass/25;
      if (mass + slurp > DIVSIZE*1.1) slurp = DIVSIZE*1.1 - mass + 1;
      
      m.mass -= slurp;
      mass += slurp;
      m.radius = sqrt(m.mass/PI);
    }
  }
  
  void divide() {
    velocity.mult(-1);
    movers.add(new Mover(mass*0.5, location.x-5, location.y, velocity));
    velocity.mult(-1);
    
    mass *= 0.5;
    location.x += 5;
    radius = sqrt(mass/PI);
  }

}
