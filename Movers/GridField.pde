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