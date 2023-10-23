//package estudiolumen.simplepbr;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.opengl.PShader;
import processing.core.PMatrix3D;
import processing.core.PVector;
import processing.opengl.PGraphics3D;
//import processing.core.PConstants;

public class SimplePBRMat {
	PShader shader;
	//PImage albedoTex, metallicTex, roughnessTex, normalTex;
PImage materialTex, albedoTex, normalTex;
	float metallic;
	float roughness;
  float occlusion;
	float rim;
  PMatrix3D shadowTransform;
  PVector lightDir;
  PGraphics shadowMap;
		
	public SimplePBRMat(){
		metallic = 1;
		roughness = 1;
    occlusion = 2;
		rim = 1f;
		shader = SimplePBR.getPbrShader();
		albedoTex = SimplePBR.getWhiteTexture();
    materialTex = SimplePBR.getWhiteTexture();
		//metallicTex = SimplePBR.getWhiteTexture();
		//roughnessTex = SimplePBR.getWhiteTexture();
		normalTex = SimplePBR.getFlatNormalTexture();
    shadowTransform = new PMatrix3D(
        (float)0.5, (float)0.0, (float)0.0, (float)0.5, 
        (float)0.0, (float)0.5, (float)0.0, (float)0.5, 
        (float)0.0, (float)0.0, (float)0.5, (float)0.5, 
        (float)0.0, (float)0.0, (float)0.0, (float)1.0
    );
    lightDir = new PVector();
    //shadowMap = createGraphics(2048, 2048, processing.opengl.PGraphics3D);
    //shadowMap.noSmooth(); // Antialiasing on the shadowMap leads to weird artifacts
    ////shadowMap.loadPixels(); // Will interfere with noSmooth() (probably a bug in Processing)
    //shadowMap.beginDraw();
    //shadowMap.noStroke();
    //shadowMap.perspective(60 * DEG_TO_RAD, 1, 10, 1000);
    //shadowMap.endDraw();
	}
	
	public SimplePBRMat( String path){
		this();	
		PImage img = SimplePBR.getPapplet().loadImage(path+"albedo.png"); if(img != null)	albedoTex = img;
    PImage n = SimplePBR.getPapplet().loadImage(path+"normal.png"); if(n != null) normalTex = n;
		//PImage m = SimplePBR.getPapplet().loadImage(path+"metalness.png"); if(m != null) metallicTex = m;
		//PImage r  = SimplePBR.getPapplet().loadImage(path+"roughness.png"); if(r!= null) roughnessTex = r;


    PImage materialImg = SimplePBR.getPapplet().loadImage(path+"material.png"); if(materialImg != null)  materialTex = materialImg;
	}
	
	public SimplePBRMat(SimplePBRMat copy){
		this();
		metallic = copy.metallic;
		roughness = copy.roughness;
		rim = copy.rim;
		shader = copy.shader;  
		albedoTex = copy.albedoTex;
		//metallicTex = copy.metallicTex;
		//roughnessTex = copy.roughnessTex;
    materialTex = copy.materialTex;
		normalTex = copy.normalTex;
	}
	
	public void bind(){
		bind(SimplePBR.getPapplet().g);
	}
	
	public void bind(PGraphics pg){
		pg.resetShader();
		//shader.set("roughnessMap", roughnessTex);
		//shader.set("metalnessMap", metallicTex);
    shader.set("materialMap", materialTex);
		shader.set("albedoTex", albedoTex);	
		shader.set("normalMap", normalTex);
		shader.set("material", metallic, roughness, occlusion, rim);
    //System.out.println("metallic" + metallic);
    shader.set("shadowTransform", new PMatrix3D(
        shadowTransform.m00, shadowTransform.m10, shadowTransform.m20, shadowTransform.m30, 
        shadowTransform.m01, shadowTransform.m11, shadowTransform.m21, shadowTransform.m31, 
        shadowTransform.m02, shadowTransform.m12, shadowTransform.m22, shadowTransform.m32, 
        shadowTransform.m03, shadowTransform.m13, shadowTransform.m23, shadowTransform.m33
    ));
    shader.set("lightDirection",lightDir.x, lightDir.y, lightDir.z);
    shader.set("shadowMap", shadowMap);
		pg.shader(shader);
	}
	

	public PShader getShader() {
		return shader;
	}

	public SimplePBRMat setShader(PShader shader) {
		this.shader = shader;
		return this;
	}
	
  public SimplePBRMat setShadowTransform(PMatrix3D shadTrans){
    this.shadowTransform = shadTrans;
    return this;
  }
  
  public SimplePBRMat setLightDirection(PVector _lightDir){
    this.lightDir.set(_lightDir);
    return this;
  }
  
  public SimplePBRMat setShadowMap(PGraphics shadMap){
    this.shadowMap = shadMap;
    return this;
  }

	public float getMetallic() {
		return metallic;
	}

	public SimplePBRMat setMetallic(float metallic) {
		this.metallic = metallic;
		return this;
	}

	public float getRougness() {
		return roughness;
	}

	public SimplePBRMat setRoughness(float roughness) {
		this.roughness = roughness;
		return this;
	}

	public float getRim() {
		return rim;
	}

	public SimplePBRMat setRim(float rim) {
		this.rim = rim;
		return this;
	}

  public float getOcclusion() {
    return occlusion;
  }

  public SimplePBRMat setOcclusion(float occlusion) {
    this.occlusion = occlusion;
    return this;
  }

}
