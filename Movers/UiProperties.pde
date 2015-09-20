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
