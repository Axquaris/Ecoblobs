import de.bezier.guido.*;

public int sHeight;
public int sWidth;
final static int DIVSIZE = 3000;
final static float NOMFACTOR = 1.2; //if (myMass > itsMass * NOMFACTOR) then its NOMABBLE
float metabolismRate, growthRate;

  
final float BORDERSIZE = (1/4)*(width+sHeight)/2;
  
public ArrayList<Mover> movers = new ArrayList<Mover>();
public ArrayList<Plant> plants = new ArrayList<Plant>();

float g = 0.4;

//UI ELEMENTS
UiButton reset;
UiSlider moversCtrl;
UiSlider plantsCtrl;
UiSlider moversMCtrl;
UiSlider plantsMCtrl;
UiGrapherII graph;

void setup() {
  size(1200,900);
  sHeight = 800;
  sWidth = width;
  ellipseMode(RADIUS);
  
  metabolismRate = 0.998;
  growthRate = 1.01;
  
  movers = new ArrayList<Mover>();
  for (int i = 0; i < 30; i++) movers.add(new Mover(random(500,3000),random(width),random(sHeight)));
  plants = new ArrayList<Plant>();
  for (int i = 0; i < 4; i++) plants.add(new Plant(random(100, 500),random(width-BORDERSIZE*2)+BORDERSIZE,random(sHeight-BORDERSIZE*2)+BORDERSIZE));
  
  //UI
  Interactive.make( this );
  setupUi();
  
  //noLoop(); //Starts sketch paused for blog spoilers
}

void draw() {
  background(255);
  
  float mMass = 0;
  for (int i = 0; i < movers.size(); i++) {
    if(movers.get(i).update()) movers.remove(i);
    else mMass += movers.get(i).mass;
  }
  graph.plotA(mMass);
  
  float pMass = 0;
  for (int i = 0; i < plants.size(); i++) {
    if(plants.get(i).update()) {
      plants.remove(i);
      plants.add(new Plant(random(100, 500),random(width-BORDERSIZE*2)+BORDERSIZE,random(sHeight-BORDERSIZE*2)+BORDERSIZE));
    }
    else pMass += plants.get(i).mass;
  }
  graph.plotB(pMass);
  
  for (int i = 0; i < movers.size(); i++) movers.get(i).display();
  for (int i = 0; i < plants.size(); i++) plants.get(i).display();
  
  fill(57, 103, 144);
  rect(0, sHeight, 650, 100);
  
  graph.render();
}

void setupUi() {
  reset = new UiButton ( 10, sHeight+10, 120, 80, "RESET");
  moversCtrl = new UiSlider( 150, sHeight+10, 240, 35, 30/100, 100, 35 );
  moversCtrl.button = color(75);
  plantsCtrl = new UiSlider( 150, sHeight+55, 240, 35, 4/10, 10, 35 );
  plantsCtrl.button = color(93, 156, 51, 250);
  
  
  moversMCtrl = new UiSlider( 400, sHeight+10, 240, 35, 0.998, -1 , 70);
  moversMCtrl.button = color(75);
  moversMCtrl.buttonW = moversMCtrl.height*2;
  plantsMCtrl = new UiSlider( 400, sHeight+55, 240, 35, 1.01, -2, 70 );
  plantsMCtrl.button = color(93, 156, 51, 250);
  plantsMCtrl.buttonW = plantsMCtrl.height*2;
  
  graph = new UiGrapherII(670, sHeight-100, 530, 200, "Blob Masses");
}

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
    if (mass < 50) return true;

    if (mass < 5000) mass *= growthRate;
    else {
      float g = map(mass, 5000, 50000, 0, growthRate-1);
      mass *= growthRate - g;
    }
    radius = sqrt(mass/PI);
    return false;
  }

  void display() {
    radius = sqrt(mass/PI);
    stroke(0);
    strokeWeight(2);
    fill(93, 156, 51, 250);
    ellipse(location.x, location.y, radius, radius);
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
        //ESSENTIALLY A RESET
        movers = new ArrayList<Mover>();
        for (int i = 0; i < moversCtrl.value*100; i++) movers.add(new Mover(random(500,3000),random(sWidth),random(sHeight)));
        plants = new ArrayList<Plant>();
        for (int i = 0; i < plantsCtrl.value*10; i++) plants.add(new Plant(random(100, 500),random(sWidth-BORDERSIZE*2)+BORDERSIZE,random(sHeight-BORDERSIZE*2)+BORDERSIZE));
        metabolismRate = moversMCtrl.value;
        growthRate = plantsMCtrl.value;
        graph.reset();
        
        pressed = true;
    }

    void draw () {
        if ( !mousePressed ) pressed = false;
        
        if ( !pressed ) fill( 128 );
        else fill( 80 );
        
        rect( x, y, width, height, (width+height)/2/10 );
        fill( 0 );
        textSize( 30 );
        textAlign( CENTER, CENTER );
        if ( pressed ) text( s, x+width/2, y+height/2);
        else text( s, x+width/2, y+height/2);
    }
}
public class UiGrapherII{
  int x, y, w, h;
  String title;
  
  float[] pointsA, pointsB;
  int pNA, pNB; //Number of points ready for plotting
  float max, min;
  
  //Layout Vars
  int edge = 25;
  int titleEdge = 30;
  int numberEdge = 30;
  
  UiGrapherII(int x, int y, int w, int h, String title) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.title = title;
    
    pointsA = new float[w - edge - numberEdge];
    pNA = 0;
    pointsB = new float[w - edge - numberEdge];
    pNB = 0;
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
  
  void render(){
    fill(149, 90, 1, 150);
    rect(x, y, w, h);
    stroke(0);
    strokeWeight(4);
    for (int i = 0; i < pNA-1; i++) {
      line(x+numberEdge+i, getPosA(i), x+numberEdge+(i+1), getPosA(i+1));
    }
    stroke(66, 110, 36);
    for (int i = 0; i < pNB-1; i++) {
      line(x+numberEdge+i, getPosB(i), x+numberEdge+(i+1), getPosB(i+1));
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
    n += x + h - edge + titleEdge;
    
    return round(n);
  }
  int getPosB(int i) {
    float n = map(pointsB[i], min, max, 0, h-edge-titleEdge);
    n *= -1;
    n += x + h - edge + titleEdge;
    
    return round(n);
  }
  
  void reset() {
    pointsA = new float[w - edge - numberEdge];
    pNA = 0;
    pointsB = new float[w - edge - numberEdge];
    pNB = 0;
    max = 0;
    min = 0; 
  }
}
public class UiSlider
{
    float x, y, width, height;
    float valueX = 0, value, mult;
    color bar;
    color button;
    float buttonW;
    
    public UiSlider ( float xx, float yy, float ww, float hh, float value, float mult, float buttonW) 
    {
        x = xx; 
        y = yy; 
        width = ww; 
        height = hh;
        
        this.mult = mult;
        this.value = value;
        if (mult > 0) {
          valueX  = map( value, 0, 1, x, x+width-buttonW );
          
        }
        else if (mult == -1){
          valueX = map( value, .95, 1, x, x+width-buttonW );
        }
        else {
          valueX = map( value, 1, 1.05, x, x+width-buttonW );
        }
        
        // register it
        Interactive.add( this );
        
        bar = color(128);
        button = color(190);
        this.buttonW = buttonW;
    }
    
    // called from manager
    void mouseDragged ( float mx, float my ) { update(mx, my); }
    void mousePressed ( float mx, float my ) { update(mx, my); }
    
    //Called when mouse clicked or dragged
    void update ( float mx, float my ) {
      valueX = mx - buttonW/2;
      
      if ( valueX < x ) valueX = x;
      if ( valueX > x+width-buttonW ) valueX = x+width-buttonW;
      
      if (mult > 0)
        value = map( valueX, x, x+width-buttonW, 0, 1 );
      else if(mult == -1)
        value = getMR();
      else
        value = getGR();
    }

    public void draw () 
    {
        float f = 0.75; //How much smaller rail bar is
        stroke(0);
        fill( bar );
        rect(x, y + (1-f)*height/2, width, height*f );
        
        stroke(0);
        fill( button );
        rect( valueX, y, buttonW , height );
        
        textSize( 20 );
        textAlign( CENTER, CENTER );
        fill(0);
        if (mult > 0)
          text( round(value*mult), valueX+buttonW/2, y+height/2);
        else if (mult == -1)
          text( getMR(), valueX+buttonW/2, y+height/2);
        else
          text( getGR(), valueX+buttonW/2, y+height/2);
    }
    
    //Specific cases
    float getMR() {
      return 0.95+round(map( valueX, x, x+width-buttonW, 0, 50 )) * .001;
    }
    
    float getGR() {
      return 1+round(map( valueX, x, x+width-buttonW, 0, 50 )) * .001;
    }
}

