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
