import java.util.Collections;
import java.util.Comparator;

class Boid implements Comparator<Boid>
{
  //fields
  PVector pos, vel, acc, ali, coh, sep; //pos, velocity, and acceleration in a vector datatype
  float neighborhoodRadius; //radius in which it looks for fellow boids
  float maxSpeed = 2; //maximum magnitude for the velocity vector
  float maxSteerForce = 0.05; //maximum magnitude of the steering vector
  float h; //hue
  float sc=3; //scale factor for the render of the boid
  float flap = 0;
  float t=0;
  float ver_weight, hor_weight;
  boolean avoidWalls = true, align = true, cohesion = true, separation = true, settle = false;
  
  float phase=random(0.095,0.14);

  //constructors
  Boid(PVector inPos)
  {
    pos = new PVector(random(width/4,width*3/4), random(height), random(width/4,width*3/4));    //pos.set(inPos);
    vel = new PVector(random(-1, 1), random(-1, 1), random(1, -1));
    acc = new PVector(0, 0, 0);
    neighborhoodRadius = 400;
  }
  Boid(PVector inPos, PVector inVel, float r)
  {
    pos = new PVector();
    pos.set(inPos);
    vel = new PVector();
    vel.set(inVel);
    acc = new PVector(0, 0);
    neighborhoodRadius = r;
  }

  void run(ArrayList bl)
  {
    t+=phase;

    //acc.add(steer(new PVector(mouseX,mouseY,300),true));
    //acc.add(new PVector(0,.002,0));
    if (avoidWalls)
    {
      //acc.add(PVector.mult(avoid(new PVector(pos.x, height, pos.z), true), 5));
      //keep desire to not hit ground strong
      acc.add(PVector.mult(avoid(new PVector(pos.x, 0, pos.z), true), 5));
      acc.add(PVector.mult(avoid(new PVector(width, pos.y, pos.z), true), 0.1));
      acc.add(PVector.mult(avoid(new PVector(0, pos.y, pos.z), true), 0.1));
      acc.add(PVector.mult(avoid(new PVector(pos.x, pos.y, 300), true), 0.1));
      acc.add(PVector.mult(avoid(new PVector(pos.x, pos.y, 900), true), 0.1));
    }
    flock(bl);
    move();
    //checkBounds();
    flap = 10*sin(t);
    render();
  }

  /////-----------behaviors---------------
  void flock(ArrayList bl)
  {
    ArrayList neighbours=nearestNeighbours(bl);
    //ArrayList neighbours=bl;
    ali = alignment(neighbours);
    coh = cohesion(neighbours);
    sep = seperation(neighbours);
    if(align && !settle)
    acc.add(PVector.mult(ali, 1));
    if(cohesion && !settle)
    acc.add(PVector.mult(coh, 3));
    if(separation && !settle)
    acc.add(PVector.mult(sep, 3));
    acc.add(PVector.mult(roost(bl),1));
  }

  void scatter()
  {
  }
  ////------------------------------------

  void move()
  {
    vel.add(acc); 
    vel.limit(maxSpeed); 
    pos.add(vel); 
    acc.mult(0); 
  }

  void checkBounds()
  {
    //if (pos.x>width) pos.x=0;
    //if (pos.x<0) pos.x=width;
    //if (pos.y>height) pos.y=0;
    if (pos.y<0) pos.y=height;
    //if (pos.z>900) pos.z=300;
    //if (pos.z<300) pos.z=900;
  }

  void render()
  {

    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateY(atan2(-vel.z, vel.x));
    rotateZ(asin(vel.y/vel.mag()));
    rotateX(-PI/2);
    stroke(h);
    noFill();
    noStroke();
    fill(h);
    //draw bird
    beginShape(TRIANGLES);
    vertex(3*sc,0,0);
    vertex(-3*sc,2*sc,0);
    vertex(-3*sc,-2*sc,0);

    vertex(3*sc,0,0);
    vertex(-3*sc,2*sc,0);
    vertex(-3*sc,0,2*sc);

    vertex(3*sc,0,0);
    vertex(-3*sc,0,2*sc);
    vertex(-3*sc,-2*sc,0);

    // wings
    vertex(2*sc, 0, 0);
    vertex(-1*sc, 0, 0);
    vertex(-1*sc, -8*sc, flap);

    vertex(2*sc, 0, 0);
    vertex(-1*sc, 0, 0);
    vertex(-1*sc, 8*sc, flap);


    vertex(-3*sc, 0, 2*sc);
    vertex(-3*sc, 2*sc, 0);
    vertex(-3*sc, -2*sc, 0);
    //
    endShape();
    //box(10);
    popMatrix();
  }

  //steering. If arrival==true, the boid slows to meet the target.
  PVector steer(PVector target, boolean arrival)
  {
    PVector steer = new PVector(); //creates vector for steering
    if (!arrival)
    {
      steer.set(PVector.sub(target, pos)); //steering vector points towards target (switch target and pos for avoiding)
      steer.limit(maxSteerForce); //limits the steering force to maxSteerForce
    } else
    {
      PVector targetOffset = PVector.sub(target, pos);
      float distance=targetOffset.mag();
      float rampedSpeed = maxSpeed*(distance/100);
      float clippedSpeed = min(rampedSpeed, maxSpeed);
      PVector desiredVelocity = PVector.mult(targetOffset, (clippedSpeed/distance));
      steer.set(PVector.sub(desiredVelocity, vel));
    }
    return steer;
  }



  //avoid. If weight == true avoidance vector is larger the closer the boid is to the target
  PVector avoid(PVector target, boolean weight)
  {
    PVector steer = new PVector(); //creates vector for steering
    steer.set(PVector.sub(pos, target)); //steering vector points away from target
    if (weight)
      steer.mult(1/sq(PVector.dist(pos, target)));
    //steer.limit(maxSteerForce); //limits the steering force to maxSteerForce
    return steer;
  }

  PVector seperation(ArrayList boids)
  {
    PVector posSum = new PVector(0, 0, 0);
    PVector repulse;
    for (int i=0; i<boids.size(); i++)
    {
      Boid b = (Boid)boids.get(i);
      float d = PVector.dist(pos, b.pos);
      if (d > 0 && d <= neighborhoodRadius)
      {
        repulse = PVector.sub(pos, b.pos);
        repulse.normalize();
        repulse.div(d);
        posSum.add(repulse);
      }
    }
    return posSum;
  }

  PVector alignment(ArrayList boids)
  {
    PVector velSum = new PVector(0, 0, 0);
    int count = 0;
    for (int i=0; i < boids.size(); i++)
    {
      Boid b = (Boid)boids.get(i);
      float d = PVector.dist(pos, b.pos);
      if (d > 0 && d <= neighborhoodRadius)
      {
        velSum.add(b.vel);
        count++;
      }
    }
    if (count>0)
    {
      velSum.div((float)count);
      velSum.limit(maxSteerForce);
    }
    return velSum;
  }

  PVector cohesion(ArrayList boids)
  {
    PVector posSum = new PVector(0, 0, 0);
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (int i=0; i<boids.size(); i++)
    {
      Boid b = (Boid)boids.get(i);
      float d = dist(pos.x, pos.y, b.pos.x, b.pos.y);
      if (d > 0 && d <= neighborhoodRadius)
      {
        posSum.add(b.pos);
        count++;
      }
    }
    if (count>0)
    {
      posSum.div((float)count);
    }
    steer = PVector.sub(posSum, pos);
    steer.limit(maxSteerForce); 
    return steer;
  }
  
  PVector roost(ArrayList boids) {
    PVector roostPos= new PVector(width/2,height/2,600);
    
    //calculate vertical force
    float vertWeight=ver_weight;
    PVector steer=new PVector(0,0,0);
    steer.y=roostPos.y-pos.y;
    steer.y=steer.y*vertWeight;
    
    //calculate horizontal force
    float horiWeight=hor_weight;
    PVector modPos=new PVector(0,0,0);
    modPos.x=pos.x;
    modPos.y=0;
    modPos.z=pos.z;
    PVector modPosDiff=new PVector(0,0,0);
    modPosDiff.add(roostPos);
    modPosDiff.sub(modPos);
    modPosDiff.y=0;
    modPosDiff.normalize();
    modPosDiff.mult(horiWeight);
    
    //PVector myVel=new PVector(vel.x,0,vel.z);
    //float dotProd=myVel.dot(modPosDiff);
    //float horiSteer=horiWeight*((1/2)+(1/2)*dotProd);
    //horiSteer=-abs(horiSteer);
    //steer.add(horiSteer,0,horiSteer);
    
    steer.add(modPosDiff);
    

    
    //modPosDiff=modPosDiff.mult(-horiSteer);
    
    //steer.add(
    return steer;
  }
  
  ArrayList<Boid> nearestNeighbours(ArrayList boids) {
    ArrayList<Boid> closestBoidsTemp=new ArrayList<Boid>(boids); // copy-constructor to avoid reaching out of our scope
    closestBoidsTemp.remove(this); // avoids considering ourselves
    Collections.sort(closestBoidsTemp, this);
    ArrayList<Boid> closestBoids = new ArrayList();
    for(int i=0;i<6;i++) {
      closestBoids.add(closestBoidsTemp.get(i));
    }
      
    //closestBoids.removeRange(6,closestBoids.size()-1);
  //  //ArrayList closestBoids=new ArrayList();
  //  //for(int i=0;i<6;i++){
  //  //  closestBoids.add(boids.get(i));
  //  //}
  //  //for(int i=0;i<6;i++){
  //  //  closestBoids.add(boids.get(i));
  //  //}
  //  //for(int i=0;i<boids.size();i++) {
  //  //  closest
  //  //    if(boids.get(i).pos.mag() sub(pos).mag()<30) {
  //  //      closestBoids.add(boids.get(i));
  //  //    }
  //  //}
      
  //  //}
  //  ////for(int i=0;i<boids.length;i++) {
  //  ////  for(int i=0
  //  ////}
  //      public class Fruit implements Comparable<Fruit> {
  //      @Override
  //      public int compare(Boid boid1, Boid boid2) {
  //        double dist1 = boid1.pos.sub(pos).mag();
  //         double dist2 = boid2.pos.sub(pos).mag();
  //          return  boid1.pos.sub(pos).mag().compareTo(boid2.pos.sub(pos).mag());
  //      }
  //  });
    //Collections.sort(closestBoids);
    return closestBoids;
  }
  
  int compare(Boid boid1, Boid boid2) {
    float dist1 = boid1.pos.dist(this.pos);
    float dist2 = boid2.pos.dist(this.pos);
    //print("Boid[" + System.identityHashCode(this) + "].compare(Boid[" + System.identityHashCode(boid1) + "], Boid[" + System.identityHashCode(boid2) + "]: dist1=" + dist1 + ", dist2=" + dist2 + "\n");
    if(dist1>dist2) {return 1;}
    if(dist1<dist2) {return -1;}
    else {return 0;}
    //return (int) Math.signum(boid1.pos.sub(this.pos).mag()-boid2.pos.sub(this.pos).mag());
  }
    
}
