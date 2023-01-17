// mouse interactions

void mousePressed() {
    mousePressedPos.set(mouseX, mouseY);
    
    // cycle through mirror types
    if (mouseOverMirror && mouseButton == RIGHT) {
        if (negateNormal) hoverMirror.back = (hoverMirror.back + 1) % 3;
        else hoverMirror.front = (hoverMirror.front + 1) % 3;
        
        s.recalcBeams();
    }
    
    if (!mouseOverMirror) {
        if (mouseButton == LEFT) displayBeamGuide = true;
        else if (mouseButton == RIGHT) {
            displayMirrorGuide = true;
        }
    }
}

void mouseReleased() {
    mouseReleasedPos.set(mouseX, mouseY);
    
    if (!mouseOverMirror && (mousePressedPos.x != mouseReleasedPos.x || mousePressedPos.y != mouseReleasedPos.y)) {
        // add a beam
        if (mouseButton == LEFT && !pauseTime) {
            s.addBeam(new Beam(mousePressedPos.copy(), PVector.sub(mousePressedPos, mouseReleasedPos)));
        }
        
        // add a mirror
        if (mouseButton == RIGHT) {
            s.addMirror(new Mirror(mousePressedPos.copy(), mouseReleasedPos.copy()));
            
            if (!pauseTime) s.recalcBeams();
        }
    }
    
    // remove a mirror
    if (mouseOverMirror && keyPressed && keyCode == CONTROL) {
        s.mirrors.remove(hoverMirror);
        s.recalcBeams();
    }
    
    displayBeamGuide = false;
    displayMirrorGuide = false;
    
    if (mouseDraggingMirror && !pauseTime) s.recalcBeams();
    mouseDraggingMirror = false;
}

void mouseDragged() {
    if (mouseOverMirror && mouseButton == LEFT) {
        mouseDraggingMirror = true;
        
        // drag verticies
        if (mouseOverLR) {
            hoverMirrorLR.set(clamp(mouseX, 0, width), clamp(mouseY, 0, height));
            
            hoverMirror.setNormal();
        } else { // drag entire mirror
            PVector off = PVector.sub(new PVector(mouseX, mouseY), new PVector(pmouseX, pmouseY));
            hoverMirror.offsetAdd(off);
            
            if (!hoverMirror.inBounds()) {
                hoverMirror.offsetSub(off);
            }
        }
    }
}

void mouseMoved() {
    mouseMovedPos.set(mouseX, mouseY);
    mouseOverMirror = false;
    mouseOverLR = false;
    
    for (Mirror m : s.mirrors) {
        float d = m.dist(mouseMovedPos);
        
        if (!m.immutable && abs(d) <= highlightDist && m.projectionDist(mouseMovedPos) <= highlightDist) {
            mouseOverMirror = true;
            
            hoverMirror = m;
            
            negateNormal = d < 0;
                        
            float dLeft = abs(m.left.dist(mouseMovedPos));
            float dRight = abs(m.right.dist(mouseMovedPos));
            boolean bLeft = dLeft <= highlightDragDist;
            boolean bRight = dRight <= highlightDragDist;
            
            mouseOverLR = bLeft || bRight;
            
            // the bounds might overlap so choose the closer one
            if (bLeft && bRight) {
                hoverMirrorLR = dLeft < dRight ? m.left : m.right;
            } else if (bLeft) {
                hoverMirrorLR = m.left;
            } else if (bRight) {
                hoverMirrorLR = m.right;
            }
            
            break;
        }
    }
}

void drawBeamGuide() {
    noFill();
    stroke(50);
    
    m.set(mouseX, mouseY);
    
    circle(mousePressedPos.x, mousePressedPos.y, guideRadius);
    
    if (mousePressedPos.x != mouseX || mousePressedPos.y != mouseY) {
        PVector sub = PVector.sub(m, mousePressedPos).normalize();
        PVector a = PVector.mult(sub, guideRadius).add(mousePressedPos);
        PVector b = PVector.mult(sub, guideLength).add(mousePressedPos);
        
        line(a.x, a.y, b.x, b.y);
        
        stroke(guidePathCol);
        mouseDragBeam.resetDir(PVector.sub(mousePressedPos, m));
        
        mouseDragBeam.continuePath(s.mirrors, guidePathLength);
        mouseDragBeam.displayCalc(guidePathLength);
    }
}

void drawMirrorGuide() {
    noFill();
    stroke(50);
    
    m.set(mouseX, mouseY);
    
    line(mousePressedPos.x, mousePressedPos.y, m.x, m.y);
}

// void keyPressed() {
//     if (key == '=') {
//         distPerFrame += distChange;
//     } else if (key == '-' && distPerFrame > distChange) {
//         distPerFrame -= distChange;
//     } else if (keyCode == ENTER || keyCode == RETURN) {
//         redraw();
//     }
// }

int clamp(int val, int a, int b) {
    return min(max(a, val), b - 1); 
}
