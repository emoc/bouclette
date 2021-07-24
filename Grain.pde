class Grain {
  
  float x, y;                        // coordonnées à l'écran (en pixels)
  int id;
    
  Grain(float x_, float y_, int id_) {
    x = x_;
    y = y_;
    id = id_;
  }
  
  void miseajour() {
    noFill();
    stroke(255, 200);
    strokeWeight(1);
    line(x, y-5, x, y+5);
    line(x-5, y, x+5, y);
  }
}
