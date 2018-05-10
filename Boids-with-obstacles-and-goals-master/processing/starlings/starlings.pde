int initBoidNum = 100; //amount of boids to start the program with
BoidList flock1;//,flock2,flock3;
float zoom=-1000;
boolean smoothEdges = false,avoidWalls = true, ali = true, coh = true, sep = true, roost = false;
PFont f;

import java.util.Collections;
void settings() {
  size(displayWidth,displayHeight,P3D);  
  if(smoothEdges)
    smooth();
  else
    noSmooth();
}

void setup()
{
  f = createFont("Arial",16,true);
  //create and fill the list of boids
  flock1 = new BoidList(initBoidNum,255);
  //flock2 = new BoidList(100,255);
  //flock3 = new BoidList(100,128);
}

void draw()
{
  textFont(f,16);
  fill(255);
  //clear screen
  beginCamera();
  camera();
  rotateX(map(mouseY - height/2,0,height/2,0,TWO_PI));
  rotateY(map(mouseX - width/2,width/2,0,0,TWO_PI));
  translate(0,0,zoom);
  endCamera();
  background(#A5CAED);
  directionalLight(255,255,255, 0, 1, -100); 
  noFill();
  stroke(0);
  
  line(0,0,300,  0,height,300);
  line(0,0,900,  0,height,900);
  line(0,0,300,  width,0,300);
  line(0,0,900,  width,0,900);
  
  line(width,0,300,  width,height,300);
  line(width,0,900,  width,height,900);
  line(0,height,300,  width,height,300);
  line(0,height,900,  width,height,900);
  
  line(0,0,300,  0,0,900);
  line(0,height,300,  0,height,900);
  line(width,0,300,  width,0,900);
  line(width,height,300,  width,height,900);
  
  flock1.run(avoidWalls, ali, coh, sep, roost);
  //flock2.run();
  //flock3.run();
}

void keyPressed()
{
  switch (keyCode)
  {
    case UP: zoom-=10; break;
    case DOWN: zoom+=10; break;
  }
  switch (key)
  {
    case 'e': smoothEdges = !smoothEdges; text("Hello Strings!",10,100);break;
    case 'w': avoidWalls = !avoidWalls; text("Hello Strings!",10,100);break;
    case 'a': ali = !ali; text("Hello Strings!",10,100);break;
    case 'c': coh = !coh; text("Hello Strings!",10,100);break;
    case 's': sep = !sep; text("Hello Strings!",10,100);break;
    case 'r': roost = !roost; text("Hello Strings!",10,100);break;
  }
}

void mousePressed()
{
  
}
