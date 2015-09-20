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
