import peasy.*;
import controlP5.*;
import java.util.Map;

PeasyCam cam;
ArrayList<Planeta> sistema = new ArrayList<Planeta>();
String[] planetNames = {"Sol","Mercuri","Venus","Terra","Mart","Júpiter","Saturn","Urà","Neptú"};
PImage saturnRing;
int focusedPlanetIndex;

ControlP5 inputUI, copyTextUI, controlsTextUI;
DropdownList planetPicker;
Slider lightSlider;
Knob tspeedKnob;
Knob rspeedKnob;
Textlabel speedLabel, lightLabel;

float tspeed, rspeed;
boolean mouseMoving;
int mouseCooldown = 120;
int cooldownCount;
float ambientLightLevel = 50;


void setup() {
  
  fullScreen(P3D);
  noStroke();
  
  //////////////  PEASY CAM  ///////////////
  
  cam = new PeasyCam(this, 1600);
  cam.setMaximumDistance(1600);
  cam.setMinimumDistance(250);
  cam.setCenterDragHandler(null);
  perspective(PI/3.0, (float) width/height, 1, 5000);
  
  //////////////  PLANETES  ///////////////
  
  // Datos reales sacados de wikipedia :) //
  
  sistema.add(new Planeta(0, 100, 0, 0.20944, loadImage("sun.jpg"))); // sol
  sistema.add(new Planeta(200, 10, 0.07139, 0.00446, loadImage("mercury.jpg"))); // mercuri
  sistema.add(new Planeta(250, 10, 0.02805, 0.02586, loadImage("venus.jpg"))); // venus
  sistema.add(new Planeta(300, 15, 0.01724, 6.28318, loadImage("earth.jpg"))); // terra
  sistema.add(new Planeta(350, 14, 0.00914, 6.25000, loadImage("mars.jpg"))); // mart
  sistema.add(new Planeta(600, 60, 0.00145, 16.7552, loadImage("jupiter.jpg"))); // júpiter
  sistema.add(new Planeta(800, 50, 0.00058, 14.3616, loadImage("saturn.jpg"))); // saturn
  sistema.add(new Planeta(1000, 30, 0.00021, 8.87455, loadImage("uranus.jpg"))); // urà
  sistema.add(new Planeta(1150, 30, 0.00011, 9.36391, loadImage("neptune.jpg"))); // neptú
  sistema.get(3).addMoon(25, 4, 0.21299, 0.23271, loadImage("moon.jpg"));
  saturnRing = loadImage("saturnring.png");
  
  //////////////  UI  ///////////////
  
  PFont font, smallFont;
  font= createFont("arial", 40);
  smallFont = createFont("arial",20);
  
  inputUI = new ControlP5(this);
  copyTextUI = new ControlP5(this);
  controlsTextUI = new ControlP5(this);
   
  inputUI.setPosition(300, height-300);
  inputUI.setAutoDraw(false); 
  
  tspeedKnob = inputUI.addKnob("tspeed")
    .setLabel("Vel. traslació")
    .setPosition(0,0)
    .setRange(0,60)
    .setRadius(100)
    .setDragDirection(Knob.HORIZONTAL)
    .setValue(1)
    .setNumberOfTickMarks(60)
    .snapToTickMarks(true)
    .hideTickMarks()
    .setDecimalPrecision(0)
    .setFont(font)
    .plugTo(tspeed);
  tspeedKnob.getCaptionLabel().setColor(color(0, 116, 217)).toUpperCase(false);
  
  speedLabel = inputUI.addLabel("tspeedLabel")
    .setText("dies / s")
    .setFont(smallFont)
    .setLineHeight(20)
    .setSize(200,50)
    .setPosition(tspeedKnob.getPosition()[0], tspeedKnob.getPosition()[1] + 150);
    speedLabel.getValueLabel().alignX(ControlP5.CENTER);
    
    /////////////////////////////////////////////////////////////////
    
     rspeedKnob = inputUI.addKnob("rspeed")
    .setLabel("Vel. rotació")
    .setPosition(300,0)
    .setRange(0,24)
    .setRadius(100)
    .setDragDirection(Knob.HORIZONTAL)
    .setValue(1)
    .setNumberOfTickMarks(24)
    .snapToTickMarks(true)
    .hideTickMarks()
    .setDecimalPrecision(0)
    .setFont(font)
    .plugTo(rspeed);
  rspeedKnob.getCaptionLabel().setColor(color(0, 116, 217)).toUpperCase(false);
  
  speedLabel = inputUI.addLabel("rspeedLabel")
    .setText("hores / s")
    .setFont(smallFont)
    .setLineHeight(20)
    .setSize(200,50)
    .setPosition(rspeedKnob.getPosition()[0], rspeedKnob.getPosition()[1] + 150);
    speedLabel.getValueLabel().alignX(ControlP5.CENTER);
  
  lightSlider = inputUI.addSlider("ambientLight")
    .setPosition(600,0)
    .setSize(50,200)
    .setRange(0,100)
    .setValue(50)
    .showTickMarks(false) 
    .setFont(font)
    .setLabel("Ambient");
  lightSlider.getCaptionLabel().setColor(color(0, 116, 217)).toUpperCase(false);
  lightSlider.getValueLabel().setVisible(false);
  
  lightLabel = inputUI.addLabel("lightLabel")
    .setFont(font)
    .setLineHeight(50)
    .setSize(200,50);
  
  inputUI.addTextlabel("planetPickerLabel")
    .setText("Centre:")
    .setFont(font)
    .setPosition(800,50)
    .setColor(color(0, 116, 217));
  
  planetPicker = inputUI.addDropdownList("planetPicker")
    .setLabel("Sol")
    .setPosition(950,50)
    .setSize(300,240)
    .setFont(font)
    .setBarHeight(60)
    .setItemHeight(50)
    .setOpen(false);
  planetPicker.getCaptionLabel().toUpperCase(false);
  planetPicker.getCaptionLabel().getStyle().setMargin(12,6,0,6);
  planetPicker.getValueLabel().toUpperCase(false);
  planetPicker.getValueLabel().getStyle().setMargin(12,6,0,6);
  
  for(int i = 0; i<planetNames.length; i++){
    planetPicker.addItem(planetNames[i],i);
  }
  
  copyTextUI.setPosition(width-750,height-250);
  copyTextUI.setAutoDraw(false);
  copyTextUI.addTextarea("copyText")
    .setFont(font)
    .setSize(600,400)
    .setLineHeight(50)
    .setText("© David Pujol & Pau Guri\n3r Multimèdia\n\nProgramat amb Processing");
  
  controlsTextUI.setPosition(300,height-600);
  controlsTextUI.setAutoDraw(false);
  controlsTextUI.addTextarea("controlsText")
    .setFont(font)
    .setLineHeight(50)
    .setSize(500,300)
    .setText("Clic esquerre: Orbitar\nRodeta / Clic dret: Zoom");
}


void draw() {
  // agafar valors del ControlP5 
  ambientLightLevel = map(lightSlider.getValue(),0,100,0,255);
  
  // posició del target de la camera
  float[] camPos = sistema.get(focusedPlanetIndex).getPosition();
  cam.lookAt(camPos[0],camPos[1],0,0);
  
  background(0);
  noLights();
  sistema.get(0).render(tspeed, rspeed); // render del sol
  
  // llums
  pointLight(255, 255, 255, 0, 0, 0);
  ambientLight(ambientLightLevel,ambientLightLevel,ambientLightLevel);

  for (int i = 1; i<sistema.size(); i++) {
    sistema.get(i).render(tspeed,rspeed); // render dels planetes
  }
  sistema.get(6).renderRing(saturnRing); // render anell de saturn
  
  // mostrar/ocultar UI
  if(mouseMoving){
    gui();
    mouseMoving = false;
    cooldownCount = mouseCooldown;
  } else {
    cooldownCount--;
    if(cooldownCount <= 0){
      noCursor();
    } else {
      gui();
    }
  }
  
  println(frameRate);
}

void mouseMoved(){
  mouseMoving = true;
  cursor(CROSS);
}
void mouseDragged(){
  mouseMoving = true;
  cursor(CROSS);
}

void gui() {
  cursor(CROSS);
  if(inputUI.isMouseOver()){
    cam.setActive(false);
  } else {
    cam.setActive(true);
  }
  
  lightLabel.setText(floor(lightSlider.getValue()) + "%");
  lightLabel.setPosition(lightSlider.getPosition()[0] + 50, map(lightSlider.getValuePosition(),0,200,150,0));
  
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  inputUI.draw();
  copyTextUI.draw();
  controlsTextUI.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

// event selecció del dropdown list
void controlEvent(ControlEvent event) {
  if (event.isFrom(planetPicker)) {
    focusedPlanetIndex = floor(event.getController().getValue());
    cam.setMinimumDistance(sistema.get(focusedPlanetIndex).getSize() * 2.5);
  }
}
