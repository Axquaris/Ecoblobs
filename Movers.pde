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

