import controlP5.*;
import java.util.*;
import processing.svg.*;
import processing.video.*;
import com.hamoid.*;
import oscP5.*;
import netP5.*;
import processing.sound.*;
import themidibus.*;
import peasy.*;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle3D;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.antialiasing.FXAA.FXAA;

int numBalls = 2000;
float exposure = 2.0;
float gravityDivider = 1000;

VideoExport videoExport;
Movie srcVideo;
boolean cheatScreen;
ControlFrame cf;
int _frameRate = 60;

boolean exportingSVG = false;
boolean exportingVideo = false;

int numOfLines = 2000;

boolean gravityOn = false;
boolean greyScale = false;
boolean starStreakOn = false;
boolean channelsOn = false;
boolean gaussianOn = false;
boolean blurOn = false;
boolean glitchOn = false;
boolean grainOn = false;
 
PShader starglowstreak;
PShader radialStreak;
PShader tv;
PShader gaussian;
PShader myBlur2;
PShader channels;
PShader saturation;
PShader glitch;
PShader grain;
PShader waves;
PShader dupontSaturation;
PShader physarum;
PShader sdfCircle;

boolean kickGate = false;
Envelope kickADSR;
float kick =0;
float kickVel=0;
boolean snareGate = false;
Envelope snareADSR;
float snare = 0;
float snareVel=0;
boolean env3Gate = false;
Envelope env3ADSR;
float env3 =0;
boolean env4Gate = false;
Envelope env4ADSR;
float env4 = 0;


boolean cymGate = false;
Envelope cymADSR;
float cym;
boolean tomGate = false;
Envelope tomADSR;
float tom;
boolean rideGate = false;
Envelope rideADSR;
float ride;

Oscillator lfo1;
Oscillator lfo2;
Oscillator lfo3;
float lfo1Val;
float lfo2Val;
float lfo3Val;

//boolean trigger = false;

color dark = color(51,51,51);
color backgroundColor = dark;
color cream = color(255,245,245);
color lineColor = cream;
color cyan = color(00,147,211);
color magenta = color(204,01,107);
color yellow = color(255,241,13);
color green = color(01, 134,50);

float glitchAmp;
float amplitudeLFO = 1.f;
float tLFO = 1.f;
float fontSizeLFO = 1.f;
float ySliderLFO = 1.f;
float glitchAmount = 1;

OscP5 oscP5;
NetAddress myRemoteLocation;
MidiBus myBus;
MidiBus n16; 

PFont font;

AudioIn input;
Amplitude loudness;

float volume = 0;
float lastVolume = 0;

PeasyCam cam;

PGraphics scaledPG;
PShader defaultShader;
PShader shadowShader;
PGraphics shadowMap;
PGraphics shadowCanvas;

PVector[] colors = {new PVector(255,255,255), new PVector(0,189,189)};
PVector lightDir = new PVector();

SimplePBRMat mat; //normal
SimplePBRMat mat1; //metal
SimplePBRMat mat2; //rusted metal
SimplePBRMat mat3; // leather
SimplePBRMat mat4;// concrete
SimplePBRMat mat5; // foil
SimplePBRMat mat6; // fabric
SimplePBRMat mat7; // ground
SimplePBRMat mat8; // snow
SimplePBRMat mat9; // rusted metal 2
SimplePBRMat mat10; // tiles
SimplePBRMat mat11; // Metal044A
SimplePBRMat mat12; // Rock20
SimplePBRMat mat13; // PavingStones131
SimplePBRMat mat14; // Foil001



PShape ico;
PShape venus;

PShape tes;
int venusTesVertexTotal;

ArrayList<Ball> balls;
PVector center;
float distanceFromCenter;
float metallic = 1.0;
float roughness = 1.0;
float occlusion = 2.0;
float rim = 1.0;
boolean loadedMaterials = false;

DwPhysics.Param param_physics = new DwPhysics.Param();
DwPhysics<DwParticle3D> physics = new DwPhysics<DwParticle3D>(param_physics);
ParticleSystem particlesystem;
FXAA fxaa;
PGraphics2D canvas_pre_aa;
PGraphics2D canvas_aa;
DwPixelFlow context;


void setup() {
  //size(800, 800, P3D);
  size(540, 960, P3D);
  //size(1920, 1080, P3D);
  //size(1080, 1080, P3D);
  frameRate(_frameRate);
  //frameRate(24);
  //smooth(0);
  scaledPG = createGraphics(width, height, P3D);
  scaledPG.lightFalloff(0f, 0.0001f, 0.00001f);
  scaledPG.noSmooth();
  scaledPG.beginDraw();
  scaledPG.background(0); 
  scaledPG.blendMode(REPLACE); 
  scaledPG.endDraw();
  
  cf = new ControlFrame(this, 300, 600, "Controls");
  
  //starglowstreak = loadShader("myStarglowstreaks.glsl");
  //starglowstreak = loadShader("myRadialStreak.glsl");
  starglowstreak = loadShader("starStreak2.glsl");
  
  //radialStreak = loadShader(".glsl");
  tv = loadShader("tv1.glsl");
  gaussian = loadShader("myGaussian.glsl");
  myBlur2 = loadShader("myBlur2.glsl");
  channels = loadShader("channels.glsl");
  saturation = loadShader("mySaturation.glsl");
  glitch = loadShader("glitch.glsl");
  grain = loadShader("grain.glsl");
  waves = loadShader("waves.glsl");
  
  //oscP5 = new OscP5(this,10201);
  //myRemoteLocation = new NetAddress("127.0.0.1",2727);
  //sendTestOSCMessage();
  
  myBus = new MidiBus(this, "osxVirtualBus", 0);
  n16 = new MidiBus(this, "Port 1", 0);
  
  kickADSR = new Envelope(0.01, .01, 0.75, .2);
  snareADSR = new Envelope(0.01, .25, 0.75, .25);
  env3ADSR = new Envelope(0.01, .01, 0.75, .2);
  env4ADSR = new Envelope(0.01, .01, 0.75, .2);
  
  
  tomADSR = new Envelope(0.01, .25, 0.75, .1);
  cymADSR = new Envelope(0.1, .5, 0.75, 1.5);
  rideADSR = new Envelope(0.1, .25, 0.75, .25);

  lfo1 = new Oscillator(_frameRate);
  lfo1.SetFreq(.1);
  
  lfo2 = new Oscillator(_frameRate);
  lfo2.SetFreq(.05);
  
  lfo3 = new Oscillator(_frameRate);
  lfo3.SetFreq(.025);
  

  font = loadFont("C64ProMono-10.vlw");  
  
    
  oscP5 = new OscP5(this,10201);
  //myRemoteLocation = new NetAddress("norns.local",10111);
    
  // Create an Audio input and grab the 1st channel
  //input = new AudioIn(this, 0);
  //input.start();
  //loudness = new Amplitude(this);
  //loudness.input(input);
  
  cam = new PeasyCam(this, 1200);
  //cam.rotateX(-PI*.75);
  cam.rotateX(-HALF_PI);
  cam.setWheelScale(0.5);
  cam.setMaximumDistance(width*2);
   
  String path = sketchPath("data/");  
  SimplePBR.init(this, path + "textures/cubemap/Zion_Sunsetpeek"); // init PBR setting processed cubemap

  
  ico = loadShape("data/models/platonic.obj");
  //ico.scale(2);
  venus = loadShape("data/venus3.obj");
  venus.scale(4);
  venus.translate(0,150,0);
  tes = venus.getTessellation();
  venusTesVertexTotal = tes.getVertexCount();
  //venus.rotateZ(PI);
  
  initDefaultPass();
  initShadowPass();
  center = new PVector(0, 0);
  balls = new ArrayList<>();
  //addBalls();
  setupParticleSystem();
  //buildVenus();
  canvas_pre_aa = (PGraphics2D) createGraphics(width, height, P2D);
  canvas_pre_aa.smooth(0);
  canvas_aa = (PGraphics2D) createGraphics(width, height, P2D);
  canvas_aa.smooth(0);
  context = new DwPixelFlow(this);
    // FXAA filter (post processing)
  fxaa = new FXAA(context);
   
}


void addBalls(){
  for (int i = 0; i < numBalls; i++) {
      balls.add(new Ball());
  }
}

void updateBalls(){
  for (Ball ball : balls) {
    //ball.pos = ball.pos.copy().mult(distanceFromCenter*0.01);
    ball.pos = ball.pos.copy().mult(distanceFromCenter*0.01);
  }
  
}

void keyPressed(KeyEvent ke){
  myKeyPressed(ke);
}

void mousePressed(){
   myMousePressed();
}

  

void shaders(){
  scaledPG.beginDraw();
  if(frameCount % 30 < 12){
    glitchAmount = width * noise(frameCount) * glitchAmp * sin(frameCount);
  }
  
  channels.set("rbias", 0.0, 0.0);
  //channels.set("gbias", map(mouseY, 0, height, -0.2, 0.2), 0.0);
  //float gbias = -0.01 + .01 * cos(.005 * float(frameCount)) + 0.008 * noise(frameCount);
  float gbias = -0.001 + .0025 * sin(.052 * float(frameCount))- 0.0013 * noise(frameCount);
  gbias = map(snare, 0, 1, 0, .005);  
  gbias = gbias - (0.02 * lfo3Val);

  channels.set("gbias", gbias, 0.0);
  channels.set("bbias", 0.0, 0.0);
  
  //channels.set("gbias", 0.0, 0.0);
  //channels.set("bbias", 0.0, 0.0);
  

  float rmult = 1.001 + .0035 * sin(.035 * float(frameCount)) - 0.001 * noise(frameCount);
  rmult = rmult + (0.02 * glitchAmp);
  rmult = map(kick,0,1, 0.95,1.05);
  rmult = rmult + (0.02 * lfo3Val);
  
  channels.set("rmult", rmult, 1.0);
  channels.set("gmult", 1.0, 1.0);
  channels.set("bmult", 1.0, 1.0);
  
  //channels.set("rmult", 1.0, 1.0);
  //channels.set("gmult", 1.0, 1.0);
  //channels.set("bmult", 1.0, 1.0);

  
  starglowstreak.set("time", (float) millis()/1000.0);
  float range = 0.2;
  float trio = (kick+snare)/2;
  range = map(trio, 0, 1, 0, .075);
  range = max(range,0,0.05);
  starglowstreak.set("range", range);
  float bright = map(trio, 0, 1, 5, 15);
  starglowstreak.set("brightness", bright);
  if(starStreakOn) scaledPG.filter(starglowstreak);
  
  //radialStreak.set("time", (float) millis()/1000.0);
  //filter(radialStreak);
  
  if(channelsOn) scaledPG.filter(channels);
  
  ////gaussian.set("time", (float) millis()/1000.0);
  if(gaussianOn) scaledPG.filter(gaussian);
   
  //myBlur2.set("time", (float) millis()/1000.0);
  if(blurOn) scaledPG.filter(myBlur2);
  glitch.set("glitchAmount",glitchAmount); 
  if(glitchOn) scaledPG.filter(glitch);
  grain.set("time", (float) millis()/1000.0);
  grain.set("strength", 6.f);
  //if(grainOn) scaledPG.filter(grain);
  
  scaledPG.endDraw();
}
  

void draw() {
  if(!loadedMaterials){
    loadMaterials();
  } 
  background(0);
  cam.getState().apply(scaledPG);
  
  for (Ball ball : balls) {
    ball.move();
  }
  
  render();
  scaledPG.loadPixels();
  shaders();

  cam.beginHUD();
  //if(mousePressed){
    canvas_pre_aa.beginDraw();
    canvas_pre_aa.image(scaledPG,0,0,width,height);
    canvas_pre_aa.endDraw();
    fxaa.apply(canvas_pre_aa, canvas_aa);
    image(canvas_aa,0,0,width,height);
    //if(grainOn) filter(grain);
  //} else {
  //  image(scaledPG,0,0,width,height);
  //}
    
  cam.endHUD();
  

  if(exportingVideo){videoExport.saveFrame();}
}

void loadMaterials(){
  String path = sketchPath("data/");
    mat = new SimplePBRMat();
  //mat1 = new SimplePBRMat(path + "textures/material/Metal10/");
  //mat2 = new SimplePBRMat(path + "textures/material/Metal_Rusted_006/");
  mat2 = new SimplePBRMat(path + "textures/material/Metal_Rusted_Combine/");
  //mat3 = new SimplePBRMat(path + "textures/material/Leather_008_SD/");
  //mat4 = new SimplePBRMat(path + "textures/material/Concrete042A/");
  mat5 = new SimplePBRMat(path + "textures/material/FoilCombine/");
  //mat6 = new SimplePBRMat(path + "textures/material/FabricCombine/");
  //mat7 = new SimplePBRMat(path + "textures/material/Ground054Combine/");
  mat8 = new SimplePBRMat(path + "textures/material/Snow010A/");
  mat9 = new SimplePBRMat(path + "textures/material/Metal018/");
  //mat10 = new SimplePBRMat(path + "textures/material/Tiles129B/");
  mat11 = new SimplePBRMat(path + "textures/material/Metal044A/");
  //mat12 = new SimplePBRMat(path + "textures/material/Rock020/");
  //mat13 = new SimplePBRMat(path + "textures/material/PavingStones131/");
  //mat14 = new SimplePBRMat(path + "textures/material/Foil001/");
  loadedMaterials = true;
  //videoExport();
}
