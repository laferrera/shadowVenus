public void initDefaultPass() {
    defaultShader = new PShader(this, "data/shaders/defaultVert.vert", "data/shaders/defaultFrag.frag");
    //shader(defaultShader = new PShader(this, "vertsource.vert", "fragsource.frag"));
    scaledPG.noStroke();
    //perspective(60 * DEG_TO_RAD, (float)width / height, 10, 1000);
    scaledPG.perspective(60 * DEG_TO_RAD, (float)width / height, 10, width*8);
}

 
public void initShadowPass() {
    shadowShader = new PShader(this, "data/shaders/shadowmapVert.vert", "data/shaders/shadowmapFrag.frag");
    //shadowMap = createGraphics(1024, 1024, P3D);
    //shadowMap = createGraphics(2048, 2048, P3D);
    //shadowMap = createGraphics(4096, 4096, P3D);
    
    shadowMap = createGraphics(max(width,height)*4, max(width,height)*4, P3D);


    shadowMap.noSmooth(); // Antialiasing on the shadowMap leads to weird artifacts
    //shadowMap.loadPixels(); // Will interfere with noSmooth() (probably a bug in Processing)
    shadowMap.beginDraw();
    shadowMap.noStroke();
    shadowMap.shader(shadowShader);
    //ortho
    //shadowMap.ortho(-200, 200, -200, 200, 10, 400); // Setup orthogonal view matrix for the directional light
    // perspective
    //shadowMap.perspective(60 * DEG_TO_RAD, 1, 10, 1000);
    shadowMap.perspective(60 * DEG_TO_RAD, 1, 10, width*8);
    shadowMap.endDraw();
}

void updateDefaultShader(SimplePBRMat thisMat) {

    // Bias matrix to move homogeneous shadowCoords into the UV texture space
    PMatrix3D shadowTransform = new PMatrix3D(
        0.5, 0.0, 0.0, 0.5, 
        0.0, 0.5, 0.0, 0.5, 
        0.0, 0.0, 0.5, 0.5, 
        0.0, 0.0, 0.0, 1.0
    );

    // Apply project modelview matrix from the shadow pass (light direction)
    shadowTransform.apply(((PGraphicsOpenGL)shadowMap).projmodelview);

    // Apply the inverted modelview matrix from the default pass to get the original vertex
    // positions inside the shader. This is needed because Processing is pre-multiplying
    // the vertices by the modelview matrix (for better performance).
    //PMatrix3D modelviewInv = ((PGraphicsOpenGL)g).modelviewInv;
    PMatrix3D modelviewInv = ((PGraphicsOpenGL)scaledPG).modelviewInv;
    shadowTransform.apply(modelviewInv);

    // Convert column-minor PMatrix to column-major GLMatrix and send it to the shader.
    // PShader.set(String, PMatrix3D) doesn't convert the matrix for some reason.
    defaultShader.set("shadowTransform", new PMatrix3D(
        shadowTransform.m00, shadowTransform.m10, shadowTransform.m20, shadowTransform.m30, 
        shadowTransform.m01, shadowTransform.m11, shadowTransform.m21, shadowTransform.m31, 
        shadowTransform.m02, shadowTransform.m12, shadowTransform.m22, shadowTransform.m32, 
        shadowTransform.m03, shadowTransform.m13, shadowTransform.m23, shadowTransform.m33
    ));
    thisMat.setShadowTransform(shadowTransform);

    // Calculate light direction normal, which is the transpose of the inverse of the
    // modelview matrix and send it to the default shader.
    float lightNormalX = lightDir.x * modelviewInv.m00 + lightDir.y * modelviewInv.m10 + lightDir.z * modelviewInv.m20;
    float lightNormalY = lightDir.x * modelviewInv.m01 + lightDir.y * modelviewInv.m11 + lightDir.z * modelviewInv.m21;
    float lightNormalZ = lightDir.x * modelviewInv.m02 + lightDir.y * modelviewInv.m12 + lightDir.z * modelviewInv.m22;
    float normalLength = sqrt(lightNormalX * lightNormalX + lightNormalY * lightNormalY + lightNormalZ * lightNormalZ);
    defaultShader.set("lightDirection", lightNormalX / -normalLength, lightNormalY / -normalLength, lightNormalZ / -normalLength);
    PVector thisLightDir = new PVector(lightNormalX / -normalLength, lightNormalY / -normalLength, lightNormalZ / -normalLength);
    thisMat.setLightDirection(thisLightDir);

    // Send the shadowmap to the default shader
    defaultShader.set("shadowMap", shadowMap);
    thisMat.setShadowMap(shadowMap);
}

void updateMatShader(SimplePBRMat thisMat) {

    // Bias matrix to move homogeneous shadowCoords into the UV texture space
    PMatrix3D shadowTransform = new PMatrix3D(
        0.5, 0.0, 0.0, 0.5, 
        0.0, 0.5, 0.0, 0.5, 
        0.0, 0.0, 0.5, 0.5, 
        0.0, 0.0, 0.0, 1.0
    );

    // Apply project modelview matrix from the shadow pass (light direction)
    shadowTransform.apply(((PGraphicsOpenGL)shadowMap).projmodelview);

    // Apply the inverted modelview matrix from the default pass to get the original vertex
    // positions inside the shader. This is needed because Processing is pre-multiplying
    // the vertices by the modelview matrix (for better performance).
    //PMatrix3D modelviewInv = ((PGraphicsOpenGL)g).modelviewInv;
    PMatrix3D modelviewInv = ((PGraphicsOpenGL)scaledPG).modelviewInv;
    shadowTransform.apply(modelviewInv);

    // Convert column-minor PMatrix to column-major GLMatrix and send it to the shader.
    // PShader.set(String, PMatrix3D) doesn't convert the matrix for some reason.
    thisMat.setShadowTransform(shadowTransform);

    // Calculate light direction normal, which is the transpose of the inverse of the
    // modelview matrix and send it to the default shader.
    float lightNormalX = lightDir.x * modelviewInv.m00 + lightDir.y * modelviewInv.m10 + lightDir.z * modelviewInv.m20;
    float lightNormalY = lightDir.x * modelviewInv.m01 + lightDir.y * modelviewInv.m11 + lightDir.z * modelviewInv.m21;
    float lightNormalZ = lightDir.x * modelviewInv.m02 + lightDir.y * modelviewInv.m12 + lightDir.z * modelviewInv.m22;
    float normalLength = sqrt(lightNormalX * lightNormalX + lightNormalY * lightNormalY + lightNormalZ * lightNormalZ);
    
    PVector thisLightDir = new PVector(lightNormalX / -normalLength, lightNormalY / -normalLength, lightNormalZ / -normalLength);
    thisMat.setLightDirection(thisLightDir);

    // Send the shadowmap to the default shader
    thisMat.setShadowMap(shadowMap);

}
