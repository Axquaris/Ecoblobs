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
    strokeWeight(1);
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
