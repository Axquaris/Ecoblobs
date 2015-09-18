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
    movers = new ArrayList<Mover>();
    for (int i = 0; i < moversCtrl.value*100; i++) movers.add(new Mover(random(DIVSIZE/3,DIVSIZE*1.1),random(sWidth),random(sHeight)));
    plants = new ArrayList<Plant>();
    for (int i = 0; i < plantsCtrl.value*20; i++) plants.add(new Plant(random(200, 800),random(sWidth),random(sHeight)));
    metabolismRate = moversMCtrl.value;
    growthRate = plantsMCtrl.value;
    graph.reset();
    grid.newFlowField();
    
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
