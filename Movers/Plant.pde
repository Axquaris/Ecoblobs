class Plant extends Blob{
  
  //Property Vars
  int divCycle;
  int divCycleLength;
  
  Plant(float m, float x, float y) {
    super(m, x, y);
    //Property Vars
    divCycleLength = (int)(Math. random() * 5 + 10);
    divCycle = divCycleLength;
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
      int neighbors = 0;
      
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
  
  void display() {
    radius = sqrt(mass/PI);
    
    stroke(43, 71, 20);
    strokeWeight(sWeight);
    fill(93, 156, 51, 240);
    
    displayGhosts(); //Function from Blob class
    ellipse(location.x, location.y, radius, radius);
  }
  
  //Subfunction for displayGhosts from Blob class
  void displayGhost(int xShift, int yShift) {
    ellipse(location.x+xShift, location.y+yShift, radius, radius);
  }
  
  void divide() {
    PVector split = PVector.random2D();
    split.mult(2);
    
    plants.add(new Plant(mass*0.5, location.x, location.y, PVector.add(velocity, split)));
    
    split.mult(-1);
    velocity.add(split);
    mass *= 0.5;
    radius = sqrt(mass/PI);
  }
  
  void focus() {
    sWeight = 8;
  }
  
  void unFocus() {
    sWeight = 2;
  }
}