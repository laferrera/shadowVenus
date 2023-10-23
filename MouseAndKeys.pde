void myKeyPressed(KeyEvent ke){
  key = ke.getKey();
  switch (key) {
    case 'e': videoExport(); break;
    case 'g': saveFrame(); break;
    case 'p': printInfo(); break;
    case 'q': { videoExport.endMovie(); exit();}

    //case 't': {trigger = !trigger; break;}
  }
   
}

void myMousePressed(){
  //noiseOctaves = int(map(mouseX, 0, width,1,12));
  //noiseFallOff = map(mouseY, 0, height,0,0.5);
}
