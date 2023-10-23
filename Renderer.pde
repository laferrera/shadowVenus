
  
void render(){
  
  
  physics.setParticles(particlesystem.particles, particlesystem.particles.length);
  
  //int particleCount = min(frameCount*8 + int(pow(frameCount,1.1)) - 500, particlesystem.particles.length);
  int particleCount = min(frameCount + int(pow(frameCount,1.1)) - 500, particlesystem.particles.length);
  //float[] thisGrav = { 0, 0, 0 };
  if(gravityOn){
    //thisGrav[1] = -0.5f;
  
  //float[] thisGrav = { 0, -0.5f, 0};
  //float[] thisGrav = { -(cam.getRotations()[1]/TWO_PI) * 10, -0.5f, 0};
   //float[] thisGrav = { (cam.getRotations()[1]/TWO_PI) * 10, -0.5f, cam.getRotations()[0]/TWO_PI * 10}; //-cam.getRotations()[0]/HALF_PI
  //float[] thisGrav = { map(mouseX,0,width,-1, 1), -1.5f, map(mouseY,0,height,1,-1)};
  
  float[] thisGrav = { sin(float(frameCount)/64), -2.5f, cos(float(frameCount)/64)};

 

    for(int i=0;i < particlesystem.particles.length;i++){
       //if(i < particleCount || particlesystem.particles[i].getVelocity() > 0.8 ){
          particlesystem.particles[i].addGravity(thisGrav);
          particlesystem.particles[i].spin.add(
            (particlesystem.particles[i].cz - particlesystem.particles[i].pz),
            (particlesystem.particles[i].cy - particlesystem.particles[i].py),
            (particlesystem.particles[i].cx - particlesystem.particles[i].px)
          );
    }
      physics.update(1);
  }

  
    // update physics simulation

  
  //int sphereDetail = 50;
  //shadowMap.sphereDetail(sphereDetail);
  //scaledPG.sphereDetail(sphereDetail);
  float lightAngle = frameCount * 0.02;  
  SimplePBR.setExposure(exposure);
  lightDir.set(sin(lightAngle) * width, width, cos(lightAngle) * height);
  cam.getState().apply(scaledPG);
  
  
  shadowMap.beginDraw();
    shadowMap.camera(lightDir.x, lightDir.y, lightDir.z, 0, 0, 0, 0, 1, 0);
    shadowMap.background(0xffffffff); // Will set the depth to 1.0 (maximum depth)
    renderLandscape(shadowMap, false);
  shadowMap.endDraw();
  
  updateDefaultShader(mat);
  
  renderLandscape(scaledPG, false);
  
  scaledPG.background(0xff008800);
  renderLandscape(scaledPG, true);
  //renderLandscape(scaledPG, false);
  scaledPG.shader(defaultShader);
}


void renderLandscape(PGraphics canvas, boolean bindMat){
  canvas.beginDraw();
  if(canvas == scaledPG){
    canvas.background(0xff000000);
  }
  
  //color lightCol1 = color(colors[0].x, colors[0].y, colors[0].z);
  //color lightCol2 = color(colors[1].x, colors[1].y, colors[1].z);
  //color lerpedColor = lerpColor(lightCol1, lightCol2, (frameCount%121)/120.f);
  //if((frameCount%240) > 120){ 
  //  lerpedColor = lerpColor(lightCol2, lightCol1, (frameCount%121)/120.f);
  //}
  //canvas.pointLight(red(lerpedColor), green(lerpedColor), blue(lerpedColor), lightDir.x, lightDir.y, lightDir.z);
  
  canvas.pointLight(colors[0].x,colors[0].y, colors[0].z, lightDir.x, lightDir.y, lightDir.z);
  //canvas.pointLight(colors[1].x,colors[1].y, colors[1].z, lightDir.z, lightDir.y, lightDir.x);

  
  
  if(bindMat){
    SimplePBRMat thisMat = mat2;
    //thisMat.setMetallic(1.5f);
    //thisMat.setRoughness(0.2f);
    //thisMat.setRim(0);
    updateMatShader(thisMat);
    thisMat.bind(canvas);
  }
  canvas.fill(0xff222222);
  //canvas.box(width, 10, width);
  canvas.pushMatrix();
    canvas.translate(0,-width/4,0);
    canvas.box(width, 10, height);
  canvas.popMatrix();
  
  //if(bindMat){
  //  SimplePBRMat thisMat = mat5;
  //  thisMat.setMetallic(metallic);
  //  thisMat.setRoughness(roughness);
  //  thisMat.setOcclusion(occlusion);
  //  thisMat.setRim(0);
  //  //thisMat.setMetallic(1.5f);
  //  //thisMat.setRoughness(0);
  //  //thisMat.setRim(rim);
  //  updateMatShader(thisMat);
  //  thisMat.bind(canvas);
  //}

  

  
  //for(int i=0; i < balls.size();i+=2){
  //  Ball ball = balls.get(i);
  //  ball.display(canvas);
  //}
  
  
  //if(bindMat){
  //  SimplePBRMat thisMat = mat8;
  //  thisMat.setMetallic(0);
  //  thisMat.setRoughness(1.5);
  //  thisMat.setOcclusion(occlusion);
  //  thisMat.setRim(0);
  //  //thisMat.setMetallic(1.5f);
  //  //thisMat.setRoughness(0);
  //  //thisMat.setRim(rim);
  //  updateMatShader(thisMat);
  //  thisMat.bind(canvas);
  //}

  
  //for(int i=1; i < balls.size();i+=2){
  //  Ball ball = balls.get(i);
  //  ball.display(canvas);
  //}
  
  
  if(bindMat){
    //SimplePBRMat thisMat = mat11;
    //SimplePBRMat thisMat = mat9;
    //SimplePBRMat thisMat = mat8;
    SimplePBRMat thisMat = mat5;
    //thisMat.setOcclusion(1.5);
    //SimplePBRMat thisMat = mat12;
    //SimplePBRMat thisMat = mat14;
    //SimplePBRMat thisMat = mat8;
    thisMat.setMetallic(metallic);
    thisMat.setRoughness(roughness);
    thisMat.setRim(rim);
    thisMat.setOcclusion(occlusion);
    updateMatShader(thisMat);
    thisMat.bind(canvas);
  }
  
  
  //for (Ball ball : balls) {
  //  ball.display(canvas);
  //}
  
  //canvas.shape(particlesystem.shp_particlesystem);
  
  for(int i=0;i < particlesystem.particles.length;i++){
     //if(i < particleCount || particlesystem.particles[i].getVelocity() > 0.8 ){ 
        //DwParticle3D p = particlesystem.particles[i];
        ParticleSystem.CustomVerletParticle3D p = particlesystem.particles[i];

            canvas.pushMatrix();
            float hue = float(p.idx)/(float)numBalls * 50;
            float bright = noise(p.idx);
            //float bright = 1.f;
            //float sat = noise(p.idx+100)/5;
            //float sat = 1.f;
            float sat = 0.f;
            color c = java.awt.Color.HSBtoRGB(hue,sat,bright);
            canvas.fill(c);
          //canvas.textureWrap(REPEAT);
          canvas.translate(p.x(),p.y(),p.z());
          canvas.rotateX(p.spin.x/100.f);
          canvas.rotateY(p.spin.y/100.f);
          canvas.rotateZ(p.spin.z/100.f);
          //canvas.sphere(p.rad());
          canvas.box(p.rad());
          //float size = p.rad()/2.f;
          //canvas.beginShape(QUAD);  
          //  canvas.vertex(-1 * size,  1 * size,  1 * size, 0, 0);
          //  canvas.vertex( 1 * size,  1 * size,  1 * size, 1, 0);
          //  canvas.vertex( 1 * size,  1 * size, -1 * size, 1, 1);
          //  canvas.vertex(-1 * size,  1 * size, -1 * size, 0, 1);
          //canvas.endShape();
          
        canvas.popMatrix();
     //}
  }


  
  //for(int i=0;i < venusTesVertexTotal-3;i = i+3){
  //      float noiseValue = noise((frameCount + i) * .01);
  //      //float noiseValue = 1.f;
  //      PVector iVert1 = tes.getVertex(i);
  //      PVector iVert2 = tes.getVertex(i+1);
  //      PVector iVert3 = tes.getVertex(i+2);
  //      canvas.beginShape(TRIANGLE);  
  //        //canvas.vertex(iVert1.x,  iVert1.y,  iVert1.z, 0, 0);
  //        //canvas.vertex(iVert2.x,  iVert2.y,  iVert2.z, 0, 1);
  //        //canvas.vertex(iVert3.x,  iVert3.y,  iVert3.z, 1, 0);
  //        canvas.vertex(iVert1.x * noiseValue,  iVert1.y * noiseValue,  iVert1.z * noiseValue, 0, 0);
  //        canvas.vertex(iVert2.x * noiseValue,  iVert2.y * noiseValue,  iVert2.z * noiseValue, 0, 1);
  //        canvas.vertex(iVert3.x * noiseValue,  iVert3.y * noiseValue,  iVert3.z * noiseValue, 1, 0);
  //      canvas.endShape();
  //  }
  
  
  canvas.pushMatrix();
    canvas.translate(0,width/8.f,0);
    //canvas.shape(ico);
    //canvas.sphere(width/10.f);
  canvas.popMatrix(); 
}
