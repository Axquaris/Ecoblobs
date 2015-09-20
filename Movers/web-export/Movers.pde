import de.bezier.guido.*;

//Simulation Vars
public int sHeight;
public int sWidth;
final static int DIVSIZEC = 300;
final static int DIVSIZE = 1000;
final static int DIVSIZEP = 200;
final static float NOMFACTOR = 1.2; //if (myMass > itsMass * NOMFACTOR) then its NOMABBLE
final float BORDERSIZE = sqrt(DIVSIZE/PI);
final float PBORDERSIZE = sqrt(10000/PI);
float metabolismRateC, metabolismRate, growthRate;
  
public GridField grid;
public ArrayList<Carnivore> carnivores = new ArrayList<Carnivore>();
public ArrayList<Mover> movers = new ArrayList<Mover>();
public ArrayList<Plant> plants = new ArrayList<Plant>();

//UI ELEMENTS
UiButton reset;
UiSlider moversCtrl;
UiSlider plantsCtrl;
UiSlider moversMCtrl;
UiSlider plantsMCtrl;
Object focus;
int focusN;
UiGrapherIII graph;
UiProperties display;

//Debug Mode
public boolean debug;

void setup() {
  frameRate(32);
  size(1000,800);
  sHeight = 700;
  sWidth = width;
  ellipseMode(RADIUS);
  
  metabolismRateC = 0.9975;
  metabolismRate = 0.998;
  growthRate = 1.008;
  
  //Create Field
  grid = new GridField(50);
  
  //UI
  Interactive.make( this );
  setupUi();
  
  //Spawn Blobs
  spawnBlobs();
  
  //Debug
  debug = false;
  
  //noLoop(); //Starts sketch paused for blog
}

void draw() {
  background(255);
  
  //Update Carnivores
  float cMass = 0;
  for (int i = 0; i < carnivores.size(); i++) {
    if(carnivores.get(i).update()) carnivores.remove(i);
    else cMass += carnivores.get(i).mass;
  }
  graph.plotC(cMass);
  
  //Update Movers
  float mMass = 0;
  for (int i = 0; i < movers.size(); i++) {
    if(movers.get(i).update()) movers.remove(i);
    else mMass += movers.get(i).mass;
  }
  graph.plotA(mMass);
  
  //Update Plants
  float pMass = 0;
  for (int i = 0; i < plants.size(); i++) {
    if(plants.get(i).update()) plants.remove(i);
    else pMass += plants.get(i).mass;
  }
  graph.plotB(pMass);
  
  if (debug) grid.displayFlow();
  
  //Display blobs
  for (int i = 0; i < plants.size(); i++) plants.get(i).display();
  for (int i = 0; i < movers.size(); i++) movers.get(i).display();
  for (int i = 0; i < carnivores.size(); i++) carnivores.get(i).display();

  //GUI
  strokeWeight(1);
  fill(57, 103, 144);
  rect(0, sHeight, 650, 100);
  
  if (focusN == -1)  graph.render();
  else display.render(focus, focusN);
  
  if (debug) {
    fill(200, 0, 0);
    textAlign( LEFT, TOP );
    textSize( 40 );
    text("FPS: "+(int)frameRate, 10, 10);
  }
}

void keyPressed() {
  if (key == 'd') {
    debug = !debug;
  }
}

void toggleDebug() {
  debug = !debug;
}

void mousePressed() {
  for (int i = 0; i < carnivores.size(); i++) carnivores.get(i).unFocus();
  for (int i = 0; i < movers.size(); i++) movers.get(i).unFocus();
  for (int i = 0; i < plants.size(); i++) plants.get(i).unFocus();
  
  for (int i = carnivores.size()-1; i >=0 ; i--) {
    float distance = sqrt(pow(carnivores.get(i).location.x-mouseX, 2)
                         +pow(carnivores.get(i).location.y-mouseY, 2));
    if ( distance <= carnivores.get(i).radius ) {
      carnivores.get(i).focus();
      focus = carnivores.get(i);
      focusN = i;
      return;
    }
  }
  for (int i = movers.size()-1; i >=0 ; i--) {
    float distance = sqrt(pow(movers.get(i).location.x-mouseX, 2)
                         +pow(movers.get(i).location.y-mouseY, 2));
    if ( distance <= movers.get(i).radius ) {
      movers.get(i).focus();
      focus = movers.get(i);
      focusN = i;
      return;
    }
  }
  for (int i = plants.size()-1; i >=0 ; i--) {
    float distance = sqrt(pow(plants.get(i).location.x-mouseX, 2)
                         +pow(plants.get(i).location.y-mouseY, 2));
    if ( distance <= plants.get(i).radius ) {
      plants.get(i).focus();
      focus = plants.get(i);
      focusN = i;
      return;
    }
  }
  
  focusN = -1;
}

void setupUi() {
  reset = new UiButton ( 10, sHeight+10, 120, 80, "RESET");
  moversCtrl = new UiSlider( 150, sHeight+10, 240, 35, 0, 100, 10);
  moversCtrl.button = color(75);
  plantsCtrl = new UiSlider( 150, sHeight+55, 240, 35, 0, 50, 20);
  plantsCtrl.button = color(93, 156, 51, 250);
  
  
  moversMCtrl = new UiSlider( 400, sHeight+10, 240, 35, 0.950, 1, 0.998);
  moversMCtrl.button = color(75);
  plantsMCtrl = new UiSlider( 400, sHeight+55, 240, 35, 1.0, 1.050, 1.008);
  plantsMCtrl.button = color(93, 156, 51, 250);
  
  focus = null;
  focusN = -1;
  graph = new UiGrapherIII(650, height-150, 350, 150, "Blob Masses");
  display = new UiProperties(650, height-150, 350, 150);
}

void spawnBlobs() {
  carnivores = new ArrayList<Carnivore>();
  for (int i = 0; i < 3; i++) carnivores.add(new Carnivore(DIVSIZE*0.8,random(sWidth),random(sHeight)));
  movers = new ArrayList<Mover>();
  for (int i = 0; i < moversCtrl.getValue(); i++) movers.add(new Mover(random(DIVSIZE/3,DIVSIZE*1.1),random(sWidth),random(sHeight)));
  plants = new ArrayList<Plant>();
  for (int i = 0; i < plantsCtrl.getValue(); i++) plants.add(new Plant(random(200, 800),random(sWidth),random(sHeight)));
}

void updateVars() {
  metabolismRate = moversMCtrl.getValue();
  growthRate = plantsMCtrl.getValue();
  graph.reset();
  grid.newFlowField();
}
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
    if (ghostX != 0 && ghostY != 0) {
      displayGhost(ghostX*sWidth, 0);
      displayGhost(0, ghostY * sHeight);
      displayGhost(ghostX*sWidth, ghostY * sHeight);
    }
    else if (ghostX != 0) displayGhost(ghostX*sWidth, 0);
    else if (ghostY != 0) displayGhost(0, ghostY * sHeight);
  }
  
  //Subfunction for displayGhost
  void displayGhost(int xShift, int yShift) {}
  
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
    velocity.limit((1+mass/DIVSIZE)*1.15);
    noseEnd = new PVector(velocity.x*radius, velocity.y*radius);
    location.add(velocity);
    
    //Torification :)
    torify();
    
    //Division test
    if (mass > DIVSIZE && closestThreat > 50) {
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
    if (distance < 2*(radius + m.radius)) strength = -1000/distance/distance;
    
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
      strength = m.mass*100/pow(distance, 3);
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
//Code inspired by:
// Daniel Shiffman's The Nature of Code @ http://natureofcode.com

class GridField {

  PVector[][] field;
  int rows, cols;
  int resolution;

  GridField(int r) {
    resolution = r;
    cols = sWidth/resolution;
    rows = sHeight/resolution;
    field = new PVector[cols][rows];
    newFlowField();
  }

  void newFlowField() {
    noiseSeed((int)random(10000));
    float xoff = 0;
    for (int i = 0; i < cols; i++) {
      float yoff = 0;
      for (int j = 0; j < rows; j++) {
        float theta = map(noise(xoff,yoff,0.005),0,1,0,TWO_PI);
        field[i][j] = new PVector(cos(theta),sin(theta));
        yoff += 0.1;
      }
      xoff += 0.1;
    }
  }

  void displayFlow() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        drawVector(field[i][j],(i+.5)*resolution,(j+.5)*resolution);
      }
    }

  }

  void drawVector(PVector v, float x, float y) {
    stroke(0);
    strokeWeight(1);
    v.setMag(resolution/2-1);
    line(x,y,x+v.x,y+v.y);
    line(x,y,x-v.x,y-v.y);
  }

  PVector getFlow(PVector location) {
    int column = int(constrain(location.x/resolution,0,cols-1));
    int row = int(constrain(location.y/resolution,0,rows-1));
    return field[column][row].get();
  }


}
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
    
    //Quick Fix
    //if (location.x == 0 && location.y == 0) location.add(new PVector(20, 20));
    
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
    if (distance < 2*(radius + m.radius)) strength = -100/distance/distance;
    
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
    if (distance <= radius + m.radius) {
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
    acceleration.setMag(radius*0.5);
    acceleration.div(mass);
    
    velocity.add(acceleration);
    velocity.limit(0.8);
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
public class UiButton {
  float x, y, width, height;
  String s;
  boolean pressed;
  
  public UiButton ( float xx, float yy, float w, float h, String s ) {
    x = xx; y = yy; width = w; height = h; this.s = s; pressed = false;
    Interactive.add( this );
  }
  
  
  public void mousePressed ( float mx, float my ) {
    //Resets simulation when button is pressed
    spawnBlobs();
    updateVars();
    
    pressed = true;
  }

  void draw () {
    if ( !mousePressed ) pressed = false;
    
    if ( !pressed ) fill( 128 );
    else fill( 80 );
    
    rect( x, y, width, height, (width+height)/2/10 );
    fill( 0 );
    textSize( 30 );
    strokeWeight(1);
    textAlign( CENTER, CENTER );
    if ( pressed ) text( s, x+width/2, y+height/2);
    else text( s, x+width/2, y+height/2);
  }
}
public class UiGrapherIII{
  int x, y, w, h;
  String title;
  
  float[] pointsA, pointsB, pointsC;
  int pNA, pNB, pNC; //Number of points ready for plotting
  float max, min;
  
  //Layout Vars
  int edge = 25;
  int titleEdge = 30;
  int numberEdge = 30;
  
  UiGrapherIII(int x, int y, int w, int h, String title) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.title = title;
    
    pointsA = new float[w - edge - numberEdge];
    pNA = 0;
    pointsB = new float[w - edge - numberEdge];
    pNB = 0;
    pointsC = new float[w - edge - numberEdge];
    pNC = 0;
    max = 0;
    min = 0;
  }
  
  void plotA (float p){
    for (int i = pointsA.length-1; i > 0; i--) {
      pointsA[i] = pointsA[i-1];
    }
    pointsA[0] = p;
    if (p > max) max = p;
    if (p < min) min = p;
    
    if (pNA < pointsA.length){
      pNA++;
    }
  }
  
  void plotB (float p){
    for (int i = pointsB.length-1; i > 0; i--) {
      pointsB[i] = pointsB[i-1];
    }
    pointsB[0] = p;
    if (p > max) max = p;
    if (p < min) min = p;
    
    if (pNB < pointsB.length){
      pNB++;
    }
  }
  
  void plotC (float p){
    for (int i = pointsC.length-1; i > 0; i--) {
      pointsC[i] = pointsC[i-1];
    }
    pointsC[0] = p;
    if (p > max) max = p;
    if (p < min) min = p;
    
    if (pNB < pointsC.length){
      pNC++;
    }
  }
  
  void render(){
    fill(173, 117, 77);
    rect(x, y, w, h);
    stroke(0);
    strokeWeight(3);
    //Draws graphs
    for (int i = 0; i < pNA-1; i++) {
      line(x+numberEdge+i, getPosA(i), x+numberEdge+(i+1), getPosA(i+1));
    }
    stroke(66, 110, 36);
    for (int i = 0; i < pNB-1; i++) {
      line(x+numberEdge+i, getPosB(i), x+numberEdge+(i+1), getPosB(i+1));
    }
    stroke(145, 15, 0);
    for (int i = 0; i < pNC-1; i++) {
      line(x+numberEdge+i, getPosC(i), x+numberEdge+(i+1), getPosC(i+1));
    }
    stroke(0);
    strokeWeight(1);
    line(x+numberEdge, y+titleEdge, x+numberEdge, y+h-edge);
    line(x+numberEdge, y+h-edge, x+w-edge, y+h-edge);
    
    
    fill(0);
    textSize( 20 );
    textAlign( CENTER, CENTER );
    text(title, x+w/2, y+titleEdge/2);
    textSize( 15 );
    text(round(max), x+numberEdge, y+titleEdge/2);
    text(round(min), x+numberEdge, y+h-edge/2);
  }
    
  int getPosA(int i) {
    float n = map(pointsA[i], min, max, 0, h-edge-titleEdge);
    n *= -1;
    n += x + h - edge;
    
    return round(n);
  }
    
  int getPosB(int i) {
    float n = map(pointsB[i], min, max, 0, h-edge-titleEdge);
    n *= -1;
    n += x + h - edge;
    
    return round(n);
  }
  
  int getPosC(int i) {
    float n = map(pointsC[i], min, max, 0, h-edge-titleEdge);
    n *= -1;
    n += x + h - edge;
    
    return round(n);
  }
  
  void reset() {
    pointsA = new float[w - edge - numberEdge];
    pNA = 0;
    pointsB = new float[w - edge - numberEdge];
    pNB = 0;
    pointsC = new float[w - edge - numberEdge];
    pNC = 0;
    max = 0;
    min = 0; 
  }
}
public class UiProperties{
  int x, y, w, h;
  
  //Layout Vars
  int edge = 25;
  int titleEdge = 30;
  int titleS = 20;
  int infoS = 15;
  
  UiProperties(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void render(Object obj, int num){
    fill(173, 117, 77);
    rect(x, y, w, h);
    
    fill(0);
    stroke(0);
    strokeWeight(1);
    textAlign( LEFT, CENTER );
    textSize( titleS );
    
    //Carnivore
    if (obj instanceof Carnivore) {
      Plant blob = (Plant)obj;
      text("Plant #"+num, x+edge, y+titleEdge/2);
    }
    
    //Mover
    else if (obj instanceof Mover) {
      Mover blob = (Mover)obj;
      text("Herbivore #"+num, x+edge, y+titleEdge*3/4);
    }
    
    //Plant
    else if (obj instanceof Plant) {
      Plant blob = (Plant)obj;
      text("Carnivore #"+num, x+edge, y+titleEdge/2);
    }
    
    textSize( infoS );
    text("Location: "+(int)blob.location.x+", "+(int)blob.location.y,
      x+edge, y+titleEdge+titleS);
    text("Velocity: "+(double)Math.round(blob.velocity.x * 1000) / 1000+", "+(double)Math.round(blob.velocity.y * 1000) / 1000,
      x+edge, y+titleEdge+titleS*2);
    text("Acceleration: "+(double)Math.round(blob.acceleration.x * 1000) / 1000+", "+(double)Math.round(blob.acceleration.y * 1000) / 1000,
      x+edge, y+titleEdge+titleS*3);
    text("Mass: "+(int)blob.mass,
      x+edge, y+titleEdge+titleS*4);
    text("Radius: "+(int)blob.radius,
      x+edge, y+titleEdge+titleS*5);
  }
}
public class UiSlider
{
  float x, y, width, height;
  float valueX, value, mult;
  float min, max;
  color bar;
  color button;
  float buttonW;
  
  public UiSlider ( float xx, float yy, float ww, float hh, float min, float max, float value) 
  {
    x = xx; 
    y = yy; 
    width = ww; 
    height = hh;
    
    this.mult = mult;
    this.min = min;
    this.max = max;
    this.value = value;
    
    if (max-min < 1)
      buttonW = height*2;
    else
      buttonW = height;
      
    valueX  = map( value, min, max, x, x+width-buttonW );
    
    // register it
    Interactive.add( this );
    
    bar = color(128);
    button = color(190);
    
  }
  
  //Called by manager
  void mouseDragged ( float mx, float my ) { update(mx, my); }
  void mousePressed ( float mx, float my ) { update(mx, my); }
  
  //Called when mouse clicked or dragged
  void update ( float mx, float my ) {
    valueX = mx - buttonW/2;
    
    if ( valueX < x ) valueX = x;
    if ( valueX > x+width-buttonW ) valueX = x+width-buttonW;
    
    value = getValue();
  }
  
  public void draw () 
  {
    float f = 0.75; //How much smaller rail bar is
    stroke(0);
    fill( bar );
    strokeWeight(1);
    rect(x, y + (1-f)*height/2, width, height*f );
    
    stroke(0);
    fill( button );
    rect( valueX, y, buttonW , height );
    
    textSize( 20 );
    textAlign( CENTER, CENTER );
    fill(0);
    text( value, valueX+buttonW/2, y+height/2);
  }
  
  //Specific cases
  float getValue() {
    float v = map( valueX, x, x+width-buttonW, min, max );
    if (max-min < 1)
      return v;
    else
      return round(v);
  }
}

