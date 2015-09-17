//Code inspired by:
// Daniel Shiffman's The Nature of Code @ http://natureofcode.com

class GridField {
  
  //FlowField
  int rows, cols;
  int resolution;
  PVector[][] field;
  //BlobField
  int rowsS, colsS;
  int resolutionS = 100;
  ArrayList<ArrayList<ArrayList<Blob>>> squares;

  GridField(int r) {
    resolution = r;
    cols = sWidth/resolution;
    rows = sHeight/resolution;
    
    field = new PVector[cols][rows];
    newFlowField();
    
    
    colsS = sWidth/resolutionS;
    rowsS = sHeight/resolutionS;
    
    squares = new ArrayList<ArrayList<ArrayList<Blob>>>();
    for (int i = 0; i < colsS; i++) {
      squares.add(new ArrayList<ArrayList<Blob>>());
      for (int j = 0; j < rowsS; j++) {
        squares.get(i).add(new ArrayList<Blob>());
      }
    }
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
  
  PVector getSquare(PVector location) {
    return new PVector(int(constrain(location.x/resolutionS,0,colsS-1)),
                       int(constrain(location.y/resolutionS,0,rowsS-1)));
  }

  PVector updateSquare(PVector location, PVector lastSq, Blob updater) {
    PVector curSq = getSquare(location);
    
    if (lastSq.x == -1 && lastSq.y == -1) {
      squares.get((int)curSq.x).get((int)curSq.y).add(updater);
    }
    
    else if (!curSq.equals(lastSq)) {
      squares.get((int)lastSq.x).get((int)lastSq.y).remove(updater);
      squares.get((int)curSq.x).get((int)curSq.y).add(updater);
    }
    return curSq;
  }
  
  ArrayList<Blob> getNeighbors(PVector location, int distance) {
    ArrayList<Blob> neighbors = new ArrayList<Blob>();
    
    for (int i = 0; i < colsS; i++) {
      ArrayList<ArrayList<Blob>> squaresCol = squares.get(i);
      
      for (int j = 0; j < rowsS; j++) {
        ArrayList<Blob> square = squaresCol.get(j);
        
        if (torusDistance(location, new PVector((i+.5)*resolutionS, (j+.5)*resolutionS)) <= distance) {
          neighbors.addAll(square);
        }
      }
    }
    
    return neighbors;
  }
  
  float torusDistance(PVector p1, PVector p2) {
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
    
    return new PVector(x, y).mag();
  }
}





