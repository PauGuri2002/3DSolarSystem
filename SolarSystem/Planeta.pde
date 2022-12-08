class Planeta {
  int r, size;
  float v, ov, vr = 0, ovr, ringAngle;
  PShape p, l;
  ArrayList<Planeta> moons = new ArrayList<Planeta>();

  Planeta(int radio, int tam, float vel_orbital, float vel_rotacion, PImage tex) {
    r = radio;
    v = random(TWO_PI);
    ov = vel_orbital;
    ovr = vel_rotacion;
    size = tam;
    p = createShape(SPHERE, tam);
    p.setTexture(tex);
    ringAngle = radians(random(10, 30));
  }
  
  Planeta addMoon(int radio, int tam, float vel_orbital, float vel_rotacion, PImage tex) {
    Planeta m = new Planeta(radio, tam, vel_orbital, vel_rotacion, tex);
    moons.add(m);
    return m;
  }

  void render(float tspeedMultiplier, float rspeedMultiplier) {
    
    push();
    rotate(v);
    translate(r, 0, 0);
    push();
    rotateX(radians(-90));
    rotateY(vr);
    shape(p);
    pop();
    for(int i = 0; i<moons.size(); i++){
      moons.get(i).render(tspeedMultiplier, rspeedMultiplier);
    }

    pop();

    v = v + ov*tspeedMultiplier/frameRate;
    vr = vr + ovr*rspeedMultiplier/(24*frameRate);
  }
  
  void renderRing(PImage img){
    push();
      rotate(v);
      translate(r, 0, 0);
      scale(0.9);
      rotateX(ringAngle);
      image(img, -152.5, -152.5);
    pop();
  }
  
  float[] getPosition(){
    float[] pos = {r*cos(v), r*sin(v)};
    return pos;
  }
  
  int getSize(){
    return size;
  }
}
