/*
    Tian Chen
    ICS4UI
    March 26, 2021
*/

/*

A (more or less) deterministic light and mirror simulator. Version 2.

Left click + drag to add a light beam.
Right click + drag to add a mirror.

Click + drag a mirror endpoint to move that vertex.
Click + drag anywhere else on the mirror to move the entire mirror.

Right click a mirror to cycle it's side type.
Control click a mirror to remove it.



Mirrors have two sides which can have one of three behaviours:
    transparent: lets light through
    reflective: bounces light back
    opaque: absorbs the light

*/

import g4p_controls.*;

float lenTail = 80; // length of the light tail
float distPerFrame = 20; // distance the light travels every frame
float maxBounces = 40; // the beam will disappear on the next collision

// ==============================

float distBuffer = 300; // calculate extra distance

final int guideRadius = 5;
final int guideLength = 40;
float guidePathLength = 1000;
final color guidePathCol = color(80);

final int mirrorWidth = 4; // width for drawing the mirrors
final color mirrorReflCol = color(200);
final color mirrorOpaqueCol = color(0);

PVector mousePressedPos = new PVector();
PVector mouseReleasedPos = new PVector();
PVector mouseMovedPos = new PVector();
PVector m = new PVector();

Beam mouseDragBeam = new Beam(mousePressedPos, m);

boolean displayBeamGuide = false;
boolean displayMirrorGuide = false;

boolean mouseOverMirror = false;
Mirror hoverMirror = null;
boolean mouseOverLR = false;
PVector hoverMirrorLR = null;
boolean mouseDraggingMirror = false;
boolean negateNormal = false;

boolean ctrlDown = false;
boolean pauseTime = false;

final int highlightDist = 8;
final int highlightDragDist = 10;

Scene s;

void setup() {
    size(800, 600);
    ellipseMode(RADIUS);
    
    createGUI();
    
    mouseDragBeam.setTailLen(guidePathLength);
    
    s = new Scene();
    
    Mirror m1 = new Mirror(new PVector(100, 100), new PVector(700, 100), 2, 0);
    Mirror m2 = new Mirror(new PVector(100, 300), new PVector(700, 300), 1, 1);
    
    s.addMirror(m1);
    s.addMirror(m2);
}

void draw() {
    background(100);
    
    if (displayBeamGuide) drawBeamGuide();
    if (displayMirrorGuide) drawMirrorGuide();
    
    if (!mouseDraggingMirror && !pauseTime) {
        s.stepTime();
        s.continuePath(s.lightDist + distBuffer);
    }
    
    s.displayMirrors();
    s.displayBeamsTime();
    // s.debugPaths();
    
    if (mouseOverMirror) {
        stroke(0, 200, 230);
        noFill();
        
        hoverMirror.highlight(10, 6);
        
        stroke(220, 50, 0);
        hoverMirror.highlightNormal(negateNormal ? -1 : 1, 8, 4);
        
        stroke(255, 0, 0);
        
        if (mouseOverLR) {
            circle(hoverMirrorLR.x, hoverMirrorLR.y, 10);
        }
    }
}
