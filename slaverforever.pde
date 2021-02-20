import processing.serial.*;


int sensorNUM = 2; //センサーの数
int graphWidth = 1100;
int graphHeight = 600;
int graphPointX = 150;
int graphPointY = 70;

int graphMin = 30;
int graphMax = 120;

Serial myPort;

int hSplit = 3;
float xSpeed = 10;

boolean judge1 = false;
boolean judge2 = false;
float[][] sensors = new float[sensorNUM][int((graphWidth+5) / xSpeed)]; //センサーの値を格納する配列
int cnt; //カウンター

// グラフの線の色を格納
color[] col = new color[3];

PFont hello;

float r;
int R = 130;
int A;


void setup() {
  //size(800,400);
  fullScreen();
  frameRate(60);

 hello = loadFont("Bauhaus93-48.vlw");

  myPort = new Serial(this, "COM6", 9600);
  println("myPortHasOpened");
  myPort.bufferUntil('\n');
  println("myPortHasConnected");
  delay(100);

  initGraph();
}

void draw() {
  background(157,204,224);
  fill(255);
  noStroke();
  rect(graphPointX, graphPointY, graphWidth, graphHeight);
  stroke(col[2]);
  ;
  
  fill(0,204,255);

  A = 2;
  //drop
  pushMatrix();
  translate(graphPointX + 100, graphPointY + 150);
  rotate(radians(-90));
  beginShape();
  for (float t = 0; t < TWO_PI; t += 0.1) {
    r = 1 / (A * sin(t/2)+1);
    vertex( R * r * cos(t), R * r * sin(t));
  }
  endShape(CLOSE);
  popMatrix();
  
  //line(graphPointX, graphPointY, graphPointX+150, graphPointY);
  //line(graphPointX, graphPointY+100, graphPointX+150, graphPointY+100);
  //line(graphPointX, graphPointY, graphPointX, graphPointY+100);
  //line(graphPointX+150, graphPointY, graphPointX+150, graphPointY+100);

  if (!judge1) {
    textFont(hello, 40);
    fill(165, 2, 83);
    text("START", graphPointX + 100, graphPointY + 130);
  } else {
    textFont(hello, 40);
    fill(165, 2, 83);
    text("STOP", graphPointX + 100, graphPointY + 130);
  }
  
  

  
  drawTitle();
  drawsalivaLabels();
  drawtimeLabels();
  Labelsline();
  LabelsWord();

  for (int i = 0; i < sensors[0].length - 6; i++ ) {
    if ((sensors[1][i])<30) {
      stroke(col[2]);
      strokeWeight(3);
      line((i+5) * xSpeed + graphPointX, valuetoPointY(sensors[0][i+5]), (i+6) * xSpeed + graphPointX, valuetoPointY(sensors[0][i+6]));
      judge2 = false;
    }
    else {
      if (sensors[0][i]>90) {
        stroke(col[1]);
        strokeWeight(5);
        line((i+5) * xSpeed + graphPointX, valuetoPointY(sensors[0][i+5]), (i+6) * xSpeed + graphPointX, valuetoPointY(sensors[0][i+6]));   
        judge2 = false;
      } else {
        stroke(col[0]);
        strokeWeight(5);
        line((i+5) * xSpeed + graphPointX, valuetoPointY(sensors[0][i+5]), (i+6) * xSpeed + graphPointX, valuetoPointY(sensors[0][i+6]));      
        judge2 = true;
      }
    }
  }
} 

void mousePressed() {
  if (mouseX >graphPointX + 100 -R) {
    if (mouseX<(graphPointX+100 + R)) {
      if (mouseY>graphPointY + 150 -R) {
        if (mouseY<(graphPointY + 150 + R)) {
          judge1 = !judge1;
          println(judge1);
        }
      }
    }
  }
}

void drawTitle() {
  stroke(40, 71, 153);
  fill(255, 253, 0);
  textSize(50);
  text("Salivation volume", graphWidth-20, graphPointY-20);
}

void drawsalivaLabels() {
  stroke(40, 71, 153);
  fill(255, 253, 0);
  textSize(50);
  textLeading(15);
  textAlign(CENTER, CENTER);
  text("Humid", graphPointX/2, graphPointY + graphHeight/2);
}

void drawtimeLabels() {
  stroke(40, 71, 153);
  fill(255, 253, 0);
  textSize(50);
  textLeading(15);
  textAlign(CENTER, CENTER);
  text("Time", graphPointX + graphWidth/2, graphPointY*3/2+graphHeight);
}
void Labelsline() {
  for (int i=0; i<(hSplit); i++) {
    stroke(192, 192, 192);
    line(graphPointX, (graphPointY + (graphHeight*(i+1)/hSplit)), graphPointX+graphWidth, (graphPointY + (graphHeight*(i+1)/hSplit)));
  }
}

void LabelsWord() {
  for (int i=0; i<hSplit+1; i++) {
    fill(40, 71, 153);
    text(graphMin + ((graphMax - graphMin)/hSplit)*i, graphPointX-40, (graphPointY + graphHeight)-(graphHeight/hSplit*i) );
  }
}




void initGraph() {
  background(47);
  noStroke();
  cnt = 0;
  col[0] = color(255, 127, 31);
  //col[1] = color(31, 255, 127);
  //col[2] = color(127, 31, 255);
  col[1] = color(31, 127, 255);
  //col[4] = color(127, 255, 31);
  //col[5] = color(127);
  col[2] = color(85, 75, 70);

  fill(255);
  rect(graphPointX, graphPointY, graphWidth, graphHeight);
}

void serialEvent(Serial myPort) { 
  String myString = myPort.readStringUntil('\n');
  //print(myString);
  myString = trim(myString);
  println(myString);
  //println(float(split(myString, ',')[0]));
  //println(float(split(myString, ',')[1]));

  for (int i = 0; i < sensors[0].length - 1; i++) {
    sensors[0][i] = sensors[0][i+1];
  }
  sensors[0][sensors[0].length-1] = float(split(myString, ',')[0]);

  for (int i = 0; i < sensors[1].length - 1; i++) {
    sensors[1][i] = sensors[1][i+1];
  }
  sensors[1][sensors[1].length-1] = float(split(myString, ',')[1]);

  // println(sensors[1][sensors[1].length - 1]);
  if (judge1) {
    myPort.write(1);
    println("Movingswich");
  }
  if (judge2) {
    myPort.write(1);
    println("Movinghumid");
  }
}

float valuetoPointY(float value) {
  if(value < graphMin){
    value = graphMin;
  }
  float Point;
  Point = graphHeight*(graphMax - value)/(graphMax-graphMin)+graphPointY;
  return Point;
}
