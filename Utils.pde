void setGreyScale(){
  greyScale =! greyScale;
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

void videoExport(){
  if(exportingVideo){
    exportingVideo = false;
    videoExport.endMovie();
  } else{
    videoExport = new VideoExport(this, "data/exports/video_export_"+timestamp()+".mp4");
    videoExport.setFrameRate(_frameRate);  
    videoExport.startMovie();
    exportingVideo = true;
  }
}

public void exportSVG(){
  exportingSVG = true;
 
  println("begining export");
  clear();
  // P3D needs begin Raw
  //beginRecord(SVG, "data/exports/export_"+timestamp()+".svg");
  beginRaw(SVG, "data/exports/export_"+timestamp()+".svg");
  
  //do stuff...
  
  render();
  //endRecord();
  endRaw();
  println("finished export");  
  exportingSVG = false;
}

void toggleShader(String _string){
  println(_string);
  printInfo();
}

void printInfo(){
  println("starStreakOn: ,",starStreakOn);
}

void sendTestOSCMessage(){
  sendOSC("note_on", 100,100);
}

void trigger(){
  kickADSR.Retrigger(true);
}

void sendOSC(String target, float a, float b){
  //OscMessage myMessage = new OscMessage("/" + target);
  OscMessage myMessage = new OscMessage(target);
  
  myMessage.add(a);
  myMessage.add(b);
  oscP5.send(myMessage, myRemoteLocation); 
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  //println();
  //println("Note On:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Pitch:"+pitch); 
  //println("Velocity:"+velocity);
  
  // kick
  if(channel == 0 && pitch == 36){
    kickGate = true;
    kickVel = velocity;
  } else if(channel == 0 && pitch == 37){ //bunch of snares
     snareGate = true;
     snareVel = velocity;
  } else if(channel == 0 && pitch == 38){
     env3Gate = true;
  } else if(channel == 0 && pitch == 39){
     env4Gate = true;
  //} else if(channel == 0 && (pitch == 58 || pitch == 61)){ // 61 is another cymbal...
  //   cymGate = true;
  //} else if(channel == 0 && pitch >= 65 && pitch <= 72){ // tom range
  //   tomGate = true;
  //} else if(channel == 0 && pitch == 60){
  //   rideGate = true;
  } else if(channel == 0 && pitch >= 70 && pitch < 80){
      
    
  } else{ 
    println("Note On:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch); 
    println("Velocity:"+velocity);
  }
  
  if(channel == 1){
    //sinesRoot = pitch;
    //sinesRootChanged = true;
    //println("sinesRoot",sinesRoot);
  }
  
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  //println();
  //println("Note Off:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Pitch:"+pitch);
  //println("Velocity:"+velocity);
  if(channel == 0 && pitch == 36){
    kickGate = false;
    kickVel = 0;
  } else if(channel == 0 && pitch == 37){
     snareGate = false;
  } else if(channel == 0 && pitch == 38){
     env3Gate = false;
  } else if(channel == 0 && pitch == 39){
     env4Gate = false;
  //} else if(channel == 0 && (pitch == 58 || pitch == 61)){ // 61 is another cymbal...
  //   cymGate = false;
  //} else if(channel == 0 && pitch >= 65 && pitch <= 72){ // 67 is a tom
  //   tomGate = false;
  //} else if(channel == 0 && pitch == 60){ // ride
  //   rideGate = false;
  } else {
    println("Note Off:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch); 
    println("Velocity:"+velocity);
  }
}

void controllerChange(int channel, int number, int value) {

  
  
  if(channel == 0){
    List list = cf.cp5.getAll(Slider.class);
    //n16 cc changes start at 32
    number -=32;
  
    if(number < list.size()){
      Slider s = (Slider)list.get(number);
      float valToSet = map(value,0,127,s.getMin(),s.getMax());
      s.setValue(valToSet);
    }
  } else {
    // Receive a controllerChange
    println();
    println("Controller Change:");
    println("--------");
    println("Channel:"+channel);
    println("Number:"+number);
    println("Value:"+value);
  }

}
