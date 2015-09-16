import de.bezier.guido.*;

//Simulation Vars
public int sHeight;
public int sWidth;
final static int DIVSIZE = 1000;
final static float NOMFACTOR = 1.2; //if (myMass > itsMass * NOMFACTOR) then its NOMABBLE
final float BORDERSIZE = sqrt(DIVSIZE/PI);
final float PBORDERSIZE = sqrt(10000/PI);
float metabolismRate, growthRate;
  
public GridField grid;
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
UiGrapherII graph;
UiProperties display;

//Debug Mode
public boolean debug;

void setup() {
  frameRate(30);
  size(1000,800);
  sHeight = 700;
  sWidth = width;
  ellipseMode(RADIUS);
  
  metabolismRate = 0.998;
  growthRate = 1.01;
  
  //Create Blobs
  grid = new GridField(50);
  movers = new ArrayList<Mover>();
  for (int i = 0; i < 30; i++) movers.add(new Mover(random(DIVSIZE/3,DIVSIZE*1.1),random(sWidth),random(sHeight)));
  plants = new ArrayList<Plant>();
  for (int i = 0; i < 5; i++) plants.add(new Plant(random(100, 500),random(width-BORDERSIZE*2)+BORDERSIZE,random(sHeight-BORDERSIZE*2)+BORDERSIZE));
  
  //UI
  Interactive.make( this );
  setupUi();
  
  //Debug
  debug = false;
  
  //noLoop(); //Starts sketch paused for blog
}

void draw() {
  background(255);
  
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
    if(plants.get(i).update()) {
      plants.remove(i);
      plants.add(new Plant(random(100, 500),random(width-BORDERSIZE*2)+BORDERSIZE,random(sHeight-BORDERSIZE*2)+BORDERSIZE));
    }
    else pMass += plants.get(i).mass;
  }
  graph.plotB(pMass);
  
  if (debug) grid.displayFlow();
  
  //Display blobs
  for (int i = 0; i < plants.size(); i++) plants.get(i).displayGhosts();
  for (int i = 0; i < plants.size(); i++) plants.get(i).display();
  for (int i = 0; i < movers.size(); i++) movers.get(i).displayGhosts();
  for (int i = 0; i < movers.size(); i++) movers.get(i).display();

  //GUI
  fill(57, 103, 144);
  rect(0, sHeight, 650, 100);
  
  if (focusN == -1)  graph.render();
  else display.render(focus, focusN);
}

void keyPressed() {
  if (key == 'd') {
    debug = !debug;
  }
}

void mousePressed() {
  for (int i = 0; i < plants.size(); i++) plants.get(i).unFocus();
  for (int i = 0; i < movers.size(); i++) movers.get(i).unFocus();
  
  for (int i = 0; i < plants.size(); i++) {
    float distance = sqrt(pow(plants.get(i).location.x-mouseX, 2)
                        +pow(plants.get(i).location.y-mouseY, 2));
    if ( distance <= plants.get(i).radius ) {
      plants.get(i).focus();
      focus = plants.get(i);
      focusN = i;
      return;
    }
  }
  for (int i = 0; i < movers.size(); i++) {
    float distance = sqrt(pow(movers.get(i).location.x-mouseX, 2)
                        +pow(movers.get(i).location.y-mouseY, 2));
    if ( distance <= movers.get(i).radius ) {
      movers.get(i).focus();
      focus = movers.get(i);
      focusN = i;
      return;
    }
  }
  
  focusN = -1;
}

void setupUi() {
  reset = new UiButton ( 10, sHeight+10, 120, 80, "RESET");
  moversCtrl = new UiSlider( 150, sHeight+10, 240, 35, 30/100, 100, 35 );
  moversCtrl.button = color(75);
  plantsCtrl = new UiSlider( 150, sHeight+55, 240, 35, 5/10, 10, 35 );
  plantsCtrl.button = color(93, 156, 51, 250);
  
  
  moversMCtrl = new UiSlider( 400, sHeight+10, 240, 35, 0.998, -1 , 70);
  moversMCtrl.button = color(75);
  moversMCtrl.buttonW = moversMCtrl.height*2;
  plantsMCtrl = new UiSlider( 400, sHeight+55, 240, 35, 1.01, -2, 70 );
  plantsMCtrl.button = color(93, 156, 51, 250);
  plantsMCtrl.buttonW = plantsMCtrl.height*2;
  
  focus = null;
  focusN = -1;
  graph = new UiGrapherII(650, height-150, 350, 150, "Blob Masses");
  display = new UiProperties(650, height-150, 350, 150);
}

