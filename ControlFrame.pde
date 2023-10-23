class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;
  CallbackListener cb;
  int curSliderY = 10;
  Textlabel filenameLabel;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{_name}, this);
  }

  public void settings() {
    size(w, h, P3D);
  }

  private int heightOffset(){
    heightOffset(25);
    return curSliderY;
  }

  private int heightOffset(int offset){
    curSliderY += offset;
    return curSliderY;
  }
  
  void draw() {
    background(190);
  }
  
  void keyPressed(KeyEvent ke){
    myKeyPressed(ke);
  }

  public void setup() {
    surface.setLocation(10, 10);
    cp5 = new ControlP5(this);
    int cp5width = 200;      
  ;


       
       
    cp5.addSlider("distanceFromCenter")
       .setValue(distanceFromCenter)
       .plugTo(parent, "distanceFromCenter")
       .setRange(-5, 5)
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       ;
       
    cp5.addSlider("exposure")
       .setValue(exposure)
       .plugTo(parent, "exposure")
       .setRange(0.5, 10)
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       ;
       
    cp5.addSlider("metallic")
       .setValue(metallic)
       .plugTo(parent, "metallic")
       .setRange(0.001, 4.0)
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       ;
       
    cp5.addSlider("roughness")
       .setValue(roughness)
       .plugTo(parent, "roughness")
       .setRange(0.001, 1.5)
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       ;
       
    cp5.addSlider("occlusion")
       .setValue(occlusion)
       .plugTo(parent, "occlusion")
       .setRange(0.001, 10.f)
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       ;
       
    cp5.addSlider("rim")
       .setValue(rim)
       .plugTo(parent, "rim")
       .setRange(0.001, 10.f)
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       ;

    //cp5.addSlider("noiseScale")
    //   .setValue(noiseScale)
    //   .plugTo(parent, "noiseScale")
    //   .setRange(0.0001, 0.005)
    //   .setPosition(20, heightOffset())
    //   .setSize(cp5width, 10)
    //   ;

    //cp5.addSlider("strokeThick")
    //   .setValue(strokeThick)
    //   .plugTo(parent, "strokeThick")
    //   .setRange(0.001, 3.0)
    //   .setPosition(20, heightOffset())
    //   .setSize(cp5width, 10)
    //   ;

    cp5.addToggle("gravityOn")
       .setValue(gravityOn)
       .plugTo(parent, "gravityOn")
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       .setMode(ControlP5.SWITCH)
     ;
     
     cp5.addToggle("starStreakOn")
       .setValue(starStreakOn)
       .plugTo(parent, "starStreakOn")
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       .setMode(ControlP5.SWITCH)
     ;
     
     cp5.addToggle("channelsOn")
       .setValue(channelsOn)    
       .plugTo(parent, "channelsOn")
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       .setMode(ControlP5.SWITCH)
     ;
     
     cp5.addToggle("gaussianOn")
       .setValue(gaussianOn)    
       .plugTo(parent, "gaussianOn")
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       .setMode(ControlP5.SWITCH)
     ;
     
     cp5.addToggle("blurOn")
       .setValue(blurOn)    
       .plugTo(parent, "blurOn")
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       .setMode(ControlP5.SWITCH)
     ;
     
      cp5.addToggle("glitchOn")
       .setValue(glitchOn)    
       .plugTo(parent, "glitchOn")
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       .setMode(ControlP5.SWITCH)
     ;
     
      cp5.addToggle("grainOn")
       .setValue(grainOn)    
       .plugTo(parent, "grainOn")
       .setPosition(20, heightOffset())
       .setSize(cp5width, 10)
       .setMode(ControlP5.SWITCH)
     ;

     
    cp5.addButton("exportingVideo")    
       .plugTo(parent, "videoExport")
       .setPosition(20, heightOffset(50))
       .setSize(cp5width, 20)
     ;
     

    cp5.addButton("exportSVG")
       .plugTo(parent, "exportSVG")
       .setPosition(20, heightOffset())
       .setSize(cp5width, 20)
       ;
       
    cp5.addButton("sendTestOSCMessage")    
       .plugTo(parent, "sendTestOSCMessage")
       .setPosition(20, heightOffset(50))
       .setSize(cp5width, 20)
     ;

     
     cp5.addTextlabel("frameRate")
       .plugTo(parent, str(frameRate))
       .setPosition(20, heightOffset(50))
       .setSize(cp5width, 20)
      ;
      
     

       
   
    cb = new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        ////println(event.getController().getName());
        ////println(event.getController());
        ////println(event.getAction());
        //switch(event.getAction()) {
        //  case(ControlP5.ACTION_BROADCAST):

        //    switch(event.getController().getName()){
        //      case("randomPointSize"):
        //        randomizePointSize();
        //        break;
        //      case("point size"):
        //        randomizePointSize();
        //        break;   
        //      case("num of points"):
        //        rs = new RandomSphere (randomPoints, radius);
        //        break;
        //      //case("ambient color"):
        //      //  setColor();
        //      //  break;   
        //    }
        //    break;
        //  // case(ControlP5.ACTION_CLICK):
        //  // case(ControlP5.ACTION_DRAG):          
        //  // case(ControlP5.ACTION_RELEASE):
        //  default:
        //    if(event.getController().getName().contains("color")){
        //        setColor();
        //        break;
        //    }
        //}

      }
    };
    
    cp5.addCallback(cb);    
  }


}
