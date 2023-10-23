
import com.thomasdiewald.pixelflow.java.geometry.DwIcosahedron;
import com.thomasdiewald.pixelflow.java.geometry.DwCube;
import com.thomasdiewald.pixelflow.java.geometry.DwIndexedFaceSetAble;
import com.thomasdiewald.pixelflow.java.geometry.DwMeshUtils;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle3D;
import com.thomasdiewald.pixelflow.java.accelerationstructures.DwCollisionGrid;
import com.thomasdiewald.pixelflow.java.accelerationstructures.DwCollisionObject;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PGraphics;
import processing.core.PShape;

void setupParticleSystem(){

  //param_physics.bounds  = new float[]{ 0, 0, 0, viewport_w*2, viewport_h*2, viewport_w * 3};
  param_physics.bounds  = new float[]{ -width/2, -width/4.f, -height/2, width/2, width*2, height/2};
  param_physics.iterations_collisions = 2;//2
  param_physics.iterations_springs    = 8;//8

  // particle system object
  particlesystem = new ParticleSystem(this, param_physics.bounds);

  //particlesystem.PARTICLE_COUNT                = 6400;//4960;//64000; // 2500 w/o Lights , 500 w/
  particlesystem.PARTICLE_COUNT                = numBalls;
  particlesystem.PARTICLE_SCREEN_FILL_FACTOR   = 0.01f; //0.08f. w/0 lIghts ,  0.02 w/
  particlesystem.particle_param.DAMP_BOUNDS    = 0.949;//0.989f; // .989
  particlesystem.particle_param.DAMP_COLLISION = 0.95;//0.859f; // .859
  particlesystem.particle_param.DAMP_VELOCITY  = 0.990;//0.995;//0.999f; //.999
  particlesystem.initParticles();
}



public class ParticleSystem {
  
  // for customizing the particle we just extends the original class and
  // Override what we want to customize
  public class CustomVerletParticle3D extends DwParticle3D{
    PVector spin;
    public CustomVerletParticle3D(int idx) {
      super(idx);
      spin = new PVector(0,0,0);
    }
    
    @Override
    public void updateShapeColor(){
    }
    
  }
  
  
  // particle system
  public float PARTICLE_SCREEN_FILL_FACTOR = 0.5f;
  public int   PARTICLE_COUNT              = 500;
  public float MAX_RAD = 1;
  public float MIN_RAD = 1;
      //float radius = 18;//15; // venus
  float DEFINED_RADIUS = 15;
  
  DwParticle3D.Param particle_param = new DwParticle3D.Param();
  
  
  public PApplet papplet;
  
  public CustomVerletParticle3D[] particles;
  public PShape shp_particlesystem;
  
  public PImage texture;
  PShape shp_obj;

  protected DwCollisionGrid grid = new DwCollisionGrid();
  
  public float[] bounds;
  public int size_y;
  public int size_z;
  
  public ParticleSystem(PApplet papplet, float[] bounds){
    this.papplet = papplet;
    this.bounds = bounds;
    //shp_obj = loadShape("data/venus3.obj");
    //shp_obj.rotateZ(PI);    

    //shp_obj.scale(bounds[3]/540 * 5); // good for venus
    //shp_obj.translate(bounds[3]/2,bounds[4]/2,bounds[3]/2);
    
  }

  
  public void setParticleCount(int count){
    if( count == PARTICLE_COUNT && particles != null &&  particles.length == PARTICLE_COUNT){
      return;
    }
    PARTICLE_COUNT = count;
    initParticles();
  }
  
  //public void setFillFactor(float screen_fill_factor){
  //  if(screen_fill_factor == PARTICLE_SCREEN_FILL_FACTOR){
  //    return;
  //  }
  //  PARTICLE_SCREEN_FILL_FACTOR = screen_fill_factor;
  //  initParticlesSize();
  //  initParticleShapes();
  //}
  

  
  public void initParticles(){
    particles = new CustomVerletParticle3D[PARTICLE_COUNT];
    for (int i = 0; i < PARTICLE_COUNT; i++) {
      particles[i] = new CustomVerletParticle3D(i);
      particles[i].setCollisionGroup(i);
      particles[i].setParamByRef(particle_param);
    }
    initParticlesSize();
    //initParticlesPosition();
    //setParticlePositionsToVenus();
    setParticlePositionsToVenusExperiment();
    initParticleShapes();
  }
  
  
  public void initParticlesSize(){
    
    float bsx = bounds[3] - bounds[0];
    float bsy = bounds[4] - bounds[1];
    float bsz = bounds[5] - bounds[2];
    
    float volume = bsx * bsy * bsz * PARTICLE_SCREEN_FILL_FACTOR;
    
    float volume_per_particle = volume / PARTICLE_COUNT;
    //float radius = (float) (Math.pow(volume_per_particle, 1/3.0) * 0.5);
    //float radius = 18;//15; // venus
    float radius = DEFINED_RADIUS;//16; // hands

    radius = Math.max(radius, 1);
    float rand_range = .5f;
    float r_min = radius * (1.0f - rand_range);
    float r_max = radius * (1.0f + rand_range/2.f);


    MAX_RAD = max(r_max, MAX_RAD);
    MIN_RAD = min(r_min,MIN_RAD);
    DwParticle3D.MAX_RAD = MAX_RAD;
    println("DwParticle3D.MAX_RAD: ", DwParticle3D.MAX_RAD);
    println("r_max", r_max);
    papplet.randomSeed(0);
    for (int i = 0; i < PARTICLE_COUNT; i++) {
      float pr = papplet.random(r_min, r_max);
      particles[i].setRadius(pr);
      //particles[i].setMass(r_max*r_max/(pr*pr) );
      //particles[i].setMass(pr*pr);
      particles[i].setMass(2*pr*pr);
    }    
  }
  
  public void setParticlePositionsToVenus(){
    
      PShape tes = venus.getTessellation();
      int total = tes.getVertexCount();
      println("total tesselation vertices", total);
      ArrayList<PVector> vertices = new ArrayList<PVector>();
      PVector firstV = tes.getVertex(0);
      vertices.add(firstV);
      for (int i = 1; i < total; i++) {
        PVector iVert = tes.getVertex(i);
        boolean hasDupe = false;
        for (int j = 0; j < vertices.size(); j++) {
          PVector jVert = vertices.get(j);
          hasDupe = hasDupe ||
          (jVert.x == iVert.x 
          || jVert.y == iVert.y
          || jVert.z == iVert.z);
        }
        if(!hasDupe){
          vertices.add(iVert);
        }      
      }
      total = min(numBalls,vertices.size());
      for (int i = 0; i < total; i++) {
        PVector v = vertices.get(i);
        particles[i].setPosition(v.x, v.y, v.z);
      }
  }
  
  public void setParticlePositionsToVenusExperiment(){
    
      PShape tes = venus.getTessellation();
      int total = tes.getVertexCount();
      println("total tesselation vertices", total);
      ArrayList<PVector> vertices = new ArrayList<PVector>();
      PVector firstV = tes.getVertex(0);
      vertices.add(firstV);
      
      for (int i = 1; i < total; i = i+3) {
        PVector iVert1 = tes.getVertex(i);
        PVector iVert2 = tes.getVertex(i+1);
        PVector iVert3 = tes.getVertex(i+1);
        PVector newVert = new PVector( 
          (iVert1.x + iVert2.x + iVert3.x)/3.f,
          (iVert1.y + iVert2.y + iVert3.y)/3.f,
          (iVert1.z + iVert2.z + iVert3.z)/3.f
        );
        if(i < numBalls){
          vertices.add(newVert);
          particles[i].setPosition(newVert.x, newVert.y, newVert.z);
        }
      }

  }
  
  public void initParticlesPosition(){
    papplet.randomSeed(0);
    for (int i = 0; i < PARTICLE_COUNT; i++) {
      float px = papplet.random(bounds[0]+DwParticle3D.MAX_RAD, bounds[3]-DwParticle3D.MAX_RAD);
      float py = papplet.random(bounds[1]+DwParticle3D.MAX_RAD, bounds[4]-DwParticle3D.MAX_RAD);
      float pz = papplet.random(bounds[2]+DwParticle3D.MAX_RAD, bounds[5]-DwParticle3D.MAX_RAD);
      particles[i].setPosition(px, py, pz);
    }
    
  }
  
  public void initParticleShapes(){
    papplet.shapeMode(PConstants.CORNER);
    shp_particlesystem = papplet.createShape(PShape.GROUP);
    
    for (int i = 0; i < PARTICLE_COUNT; i++) {
      PShape shp_particle = createParticleShape(particles[i]);
      particles[i].setShape(shp_particle);
      shp_particlesystem.addChild(shp_particle);
    }

  }
  
  DwIndexedFaceSetAble ifs;
  
  // create the shape that is going to be rendered
  public PShape createParticleShape(DwParticle3D particle){
   
    PShape shp_particle = papplet.createShape(PShape.GEOMETRY);
    
    shp_particle.resetMatrix();
    shp_particle.translate(particle.cx, particle.cy, particle.cz);
    shp_particle.rotateX(papplet.random(PConstants.TWO_PI));
    shp_particle.rotateY(papplet.random(PConstants.TWO_PI));
    shp_particle.rotateZ(papplet.random(PConstants.TWO_PI));
    shp_particle.setStroke(false);
    float colorValue = (particle.rad / DwParticle3D.MAX_RAD) * 255;
    shp_particle.setFill(papplet.color(colorValue, colorValue, colorValue));    
    
    if(ifs == null) ifs = new DwIcosahedron(1);
    //if(ifs == null) ifs = new DwCube(1);
    DwMeshUtils.createPolyhedronShape(shp_particle, ifs, 1, 3, true);
    shp_particle.setTexture(texture);


    return shp_particle;
  }
  
  public boolean gotCollision(DwParticle3D object){
    float[] bounds = grid.bounds;
    if(object.x() - object.radCollision() < bounds[0]) return true;
    if(object.y() - object.radCollision() < bounds[1]) return true;
    if(object.z() - object.radCollision() < bounds[2]) return true;
    if(object.x() + object.radCollision() > bounds[3]) return true;
    if(object.y() + object.radCollision() > bounds[4]) return true;
    if(object.z() + object.radCollision() > bounds[5]) return true;
    //grid.solveCollision(object);
    //return (object.getCollisionCount() > 0);

    for (int i = 0; i < PARTICLE_COUNT; i++) {
      if(object.idx == i) { return false;}
        DwParticle3D otherParticle = particles[i];
        float distance = dist(object.x(), object.y(), object.z(), otherParticle.x(), otherParticle.y(), otherParticle.z());
        if(distance < object.radCollision() + otherParticle.radCollision()){
          return true;
        }
    }
    return false;
    
  }


  void display(PGraphics pg) {
    pg.shape(shp_particlesystem);
  }
  
  

}
