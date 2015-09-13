class Plant {

  PVector location;
  float radius;
  float mass;
  
  Plant(float m, float x, float y) {
    mass = m;
    radius = sqrt(m/PI);
    location = new PVector(x, y);
  }
  
  boolean update() {
    if (mass < 20) return true; //Self-destruct
    
    //Growth limitation
    if (mass < DIVSIZE*2) mass *= growthRate;
    else {
      float g = map(mass, DIVSIZE*2, 10000, 0, growthRate-1);
      mass *= growthRate - g;
    }
  
    radius = sqrt(mass/PI);
    return false;
  }

  void display() {
    radius = sqrt(mass/PI);
    stroke(43, 71, 20);
    strokeWeight(2);
    fill(93, 156, 51, 240);
    ellipse(location.x, location.y, radius, radius);
  }
}
