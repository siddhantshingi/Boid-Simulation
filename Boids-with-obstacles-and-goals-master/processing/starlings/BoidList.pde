
class BoidList
{
  ArrayList boids; 
  float h; //for color
  
  BoidList(int n,float ih)
  {
    boids = new ArrayList();
    h = ih;
    for(int i=0;i<n;i++)
      boids.add(new Boid(new PVector(width/2,height/2,600)));
  }
  
  void add()
  {
    boids.add(new Boid(new PVector(width/2,height/2)));
  }
  
  void addBoid(Boid b)
  {
    boids.add(b);
  }
  
  void run(boolean aW, boolean ali, boolean coh, boolean sep, boolean roost)
  {
    float ver_weight = 0.0003;
    float hor_weight = 0.01;
    if(roost)
      ver_weight = 0.001;
      hor_weight = 0.01;
    for(int i=0;i<boids.size();i++) 
    {
      Boid tempBoid = (Boid)boids.get(i); 
      tempBoid.h = h;
      tempBoid.avoidWalls = aW;
      tempBoid.align = ali;
      tempBoid.cohesion = coh;
      tempBoid.separation = sep;
      tempBoid.settle = roost;
      tempBoid.hor_weight = hor_weight;
      tempBoid.ver_weight = ver_weight;
      
      tempBoid.run(boids); 
    }
  }
}
