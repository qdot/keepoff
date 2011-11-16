import oscP5.*;
import netP5.*;
import codeanticode.gsvideo.*;
 
import SimpleOpenNI.*;
GSCapture camera;

OscP5 oscP5;
String s = "Looking for user";
SimpleOpenNI context;
int i = 0;
PFont font;
PVector elCenter = new PVector();
float elRadius;
PVector lineStart = new PVector();
float lineLength;


float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);
NetAddress keepon;
void setup()
{
  size(640,480);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  oscP5 = new OscP5(this,12000);
  context = new SimpleOpenNI(this);
  keepon = new NetAddress("127.0.0.1",10000);
   camera = new GSCapture(this, 320, 240);
camera.start();
    OscMessage rotmsg = new OscMessage("/rotate");
    rotmsg.add(128);
    OscMessage bfmsg = new OscMessage("/bf");
    bfmsg.add(128);
    oscP5.send(rotmsg, keepon); 
    oscP5.send(bfmsg, keepon); 
  // disable mirror
  context.setMirror(false);

  // enable depthMap generation 
  context.enableRGB();
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  smooth(); 
  font = loadFont("FreeSans-18.vlw"); 
  textFont(font, 18);
  textAlign(CENTER);
  
  elCenter.x = width/6;
  elCenter.y = height/3;
  elRadius = 75;
  lineStart.x = (width/3);
  lineStart.y = height/3 + (elRadius/2);
  lineLength = 75;
 }
void captureEvent(GSCapture camera){
camera.read();
}
void draw()
{
  // update the cam
  context.update();

  background(0,0,0);
  if((context.nodes() & SimpleOpenNI.NODE_DEPTH) != 0)
  {
    if((context.nodes() & SimpleOpenNI.NODE_IMAGE) != 0)
    {
      image(context.depthImage(),0,240, 320, 240);   
      image(context.rgbImage(),320,240,320,240);   
    }
   else
      image(context.depthImage(),0,0);
  }
  image(camera, 320, 0);
  ellipse(elCenter.x, elCenter.y, elRadius, elRadius);
  color(255, 255,255);
  text(s, width/4, 40);
  strokeWeight(4);
  if(context.isTrackingSkeleton(1))
  {
    PVector nJ = new PVector();
    PVector rsJ = new PVector();
    PVector lhJ = new PVector();
    PVector rhJ = new PVector();
    float  confidence;

    //Calculate angle of shoulders in relation to camera z-axis
    confidence = context.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_NECK,nJ);
    if(confidence < 0.001f) 
      return;
    confidence = context.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rsJ);
    if(confidence < 0.001f) 
      return;
    float rotAngle = atan2(rsJ.z - nJ.z, rsJ.x - nJ.x);
    
    //Calculate angle between hip and neck joints base
      
    stroke(0,0,0);
    line(elCenter.x, elCenter.y, elCenter.x + ((elRadius/2) * cos(rotAngle -  PI/2)), elCenter.y + ((elRadius/2) * sin(rotAngle - PI/2))); 
  
    // draw the joint position
    confidence = context.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_HIP,lhJ);
    if(confidence < 0.001f) 
      return;
    confidence = context.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_HIP,rhJ);
    if(confidence < 0.001f) 
      return;
    // find midpoint between hips for center hip joint
    PVector chJ = PVector.add(lhJ, rhJ);
    chJ.div(2);
    float bendAngle = atan2(chJ.y - nJ.y, chJ.z - nJ.z);
    stroke(255,255,255);
    line(lineStart.x, lineStart.y, lineStart.x + (lineLength * cos(bendAngle)), lineStart.y + (lineLength * sin(bendAngle))); 
    drawSkeleton(1);
    OscMessage rotmsg = new OscMessage("/rotate");
    rotmsg.add(128 * ((PI + -rotAngle)/PI)); /* add an int to the osc message */
    oscP5.send(rotmsg, keepon);
    OscMessage bfmsg = new OscMessage("/bf");
    bfmsg.add(255- (128 * (-bendAngle/(PI/2))));
    println(rotAngle);
    /* send the message */
    oscP5.send(bfmsg, keepon); 
  }
  else
  {
    i++;
    //Draw rotation circle
    stroke(255,255,255);
    line(lineStart.x, lineStart.y - lineLength, lineStart.x, lineStart.y); 
    stroke(0,0,0);
    line(elCenter.x, elCenter.y, elCenter.x + ((elRadius/2) * cos(radians(i))), elCenter.y + ((elRadius/2) * sin(radians(i))));

  }

}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  strokeWeight(3);

  // to get the 3d joint data
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  

  strokeWeight(1);
 
}

void drawLimb(int userId,int jointType1,int jointType2)
{
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float  confidence;
  
  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId,jointType1,jointPos1);
  confidence = context.getJointPositionSkeleton(userId,jointType2,jointPos2);

  stroke(255,0,0,confidence * 200 + 55);
  float qw = width/4;
  float hh = 3*(height/4);
  // You know, sometimes, you just keep putting numbers in until things work.
  // Truncated out z because I don't really care if it doesn't line up.
  line((((1-(qw-(jointPos1.x/8))/qw))*qw)+qw,hh-(jointPos1.y/8),
       (((1-(qw-(jointPos2.x/8))/qw))*qw)+qw,hh-(jointPos2.y/8));
}

// SimpleOpenNI user events

void onNewUser(int userId)
{
  s = "Found User";
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  context.startPoseDetection("Psi",userId);
}

void onLostUser(int userId)
{
  s = "Looking for User";
  println("onLostUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  s = "Calibrating for Skeleton";
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  s = "Tracking Skeleton";
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  s = "Calibrating Skeleton";
  println("onStartdPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  s = "Finished Calibrating skeleton";
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

