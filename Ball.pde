class Ball {

    int id;
    float r;
    PVector pos;
    PVector vel;
    PVector acl;
    PVector spin;
    float mass;
    color myColor;

    Ball() {
      id = balls.size();
      reset();
    }

    void reset() {
      r = random(width / 100, width / 40);
      //r = random(width / 100, width / 60);
      float rnd = random(0, 360);
      float _z = 100;
      //pos = new PVector(sin(rnd) * width/2, cos(rnd) * width/2, _z);
      pos = randomSpherePoint(width/4);
      vel = new PVector(1, 1, 1);
      acl = new PVector();
      mass = r;
      spin = new PVector(r,r,r);
      myColor = color(255,0,0);
      //myColor = colors[(int) random(colors.length)];
    }

    
    PVector randomSpherePoint (float sphereRadius){
      float a=0, b=0, c=0, d=0, k=99;
      while (k >= 1.0) { 
        a = random (-1.0, 1.0);
        b = random (-1.0, 1.0);
        c = random (-1.0, 1.0);
        d = random (-1.0, 1.0);
        k = a*a +b*b +c*c +d*d;
      }
      k = k / sphereRadius;
      return new PVector( 2*(b*d + a*c) / k 
          , 2*(c*d - a*b) / k  
          , (a*a + d*d - b*b - c*c) / k);
      
  }
    

    void move() {
        for (int i = id + 1; i < balls.size(); i++) {
            Ball other = balls.get(i);
            float dist = pos.dist(other.pos);
            //float dist = pos.dist(other.pos) + r + other.r/2;
            //float c = (r / 2 + other.r / 2);
            float c = r + other.r;
            if (dist < c) {
                //ref: https://stackoverflow.com/questions/345838/ball-to-ball-collision-detection-and-handling
                PVector delta = PVector.sub(pos, other.pos);
                float d = pos.dist(other.pos);
                PVector mtd = delta.copy().mult((c - d) / d);
                float im1 = 1 / mass;
                float im2 = 1 / other.mass;

                pos.add(PVector.mult(mtd.copy(), im1 / (im1 + im2)));
                other.pos.sub(PVector.mult(mtd.copy(), im2 / (im1 + im2)));

                PVector v = PVector.sub(vel, other.vel);
                float vn = v.dot(PVector.mult(mtd.copy().normalize(), 1));

                float im = (-(1 + 0.85f) * vn) / (im1 + im2);
                PVector impulse = PVector.mult(mtd.copy().normalize(), im);

                vel.add(PVector.mult(impulse.copy(), im1));
                other.vel.sub(PVector.mult(impulse.copy(), im2));
            }
        }
        
        PVector grav = pos.copy().mult(distanceFromCenter);
        acl.add(PVector.sub(grav, pos));
        //acl.add(PVector.sub(center, pos));
        
        acl.div(gravityDivider);
        //acl.div(1000);
        //acl.div(10000);
        //acl.div(100000);
        vel.add(acl);
        vel.mult(0.98f);
        pos.add(vel);
        spin.add(vel);
        //push();
        //fill(myColor);
        //circle(pos.x, pos.y, r);
        //pop();
    }
    
    void display(PGraphics canvas) {
      canvas.noStroke();

      //canvas.fill(200);
      //canvas.fill(200);
      //canvas.fill(0xffffffff);
      //canvas.fill(0xff111111);
      //float hue = r/(width) * 20;
      float hue = float(id)/(float)numBalls * 50;
      float bright = noise(id);
      //float bright = 1.f;
      //float sat = noise(id+100)/5;
      //float sat = 1.f;
      float sat = 0.f;
      color c = java.awt.Color.HSBtoRGB(hue,sat,bright);
      canvas.fill(c);
      canvas.pushMatrix();
      canvas.translate(pos.x,pos.y,pos.z);
      //canvas.rotateX(rot);
      canvas.rotateX(spin.x/50.f);
      canvas.rotateY(spin.y/50.f);
      canvas.rotateZ(spin.z/50.f);
      //canvas.rotateY(r);
      canvas.sphere(r);
      //canvas.box(r);
      //stroke(255);
      //circle(0,0,r);

      canvas.popMatrix();
  }
}


class CenterBall extends Ball {

    float r2;

    CenterBall() {
        super();
        reset();
    }

    void reset() {
        r2 = r = 200;
        pos = new PVector(0, 0);
        vel = new PVector();
        acl = new PVector();
        mass = 1000;
    }

    void move() {
        r += (r2 - r) / 10;
        for (int i = id + 1; i < balls.size(); i++) {
            Ball other = balls.get(i);
            float dist = pos.dist(other.pos);
            float c = (r / 2 + other.r / 2);
            if (dist < c) {
                PVector delta = PVector.sub(pos, other.pos);
                float d = pos.dist(other.pos);
                PVector mtd = delta.copy().mult((c - d) / d);
                float im1 = 1 / mass;
                float im2 = 1 / other.mass;

                other.pos.sub(PVector.mult(mtd.copy(), im2 / (im1 + im2)));
                //PVector distCenter = PVector.sub(new PVector(0,0,0), pos);
                //PVector distCenter = delta.copy().mult(r);
                ////other.pos.add(distCenter);
                //other.pos.set(distCenter);

                PVector v = PVector.sub(vel, other.vel);
                float vn = v.dot(PVector.mult(mtd.copy().normalize(), 1));

                float im = (-(1 + 0.85f) * vn) / (im1 + im2);
                PVector impulse = PVector.mult(mtd.copy().normalize(), im);

                other.vel.sub(PVector.mult(impulse.copy(), im2));
                //other.vel.add(delta.copy().normalize());
            }
        }
      //display(canvas);
    }
    
    void display(PGraphics canvas){
    }
}
