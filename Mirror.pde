/*

0 - transparent
1 - mirror
2 - opaque

*/

class Mirror extends Segment {
    int front;
    int back;
    boolean immutable;
    
    Mirror() {
        super();
        
        this.front = 1;
        this.back = 1;
        this.immutable = true;
    }
    
    Mirror (PVector l, PVector r) {
        super(l, r);
        
        this.front = 1;
        this.back = 1;
        this.immutable = false;
    }
    
    Mirror (PVector l, PVector r, int f, int b) {
        super(l, r);
        
        this.front = f;
        this.back = b;
        this.immutable = false;
    }
    
    // if a line through can intersect the mirror
    /*
    0 - transparent
    1 - mirror
    2 - opaque
    */
    int canIntersect (PVector p) {
        switch (this.direction(p)) {
            case 0:
                return 0;
            case 1:
                return this.front;
            case -1:
                return this.back;
        }
        
        return 0; // should not run
    }
    
    // will intersect if mirror opaque
    // 0 - pass
    int mIntersect(Segment s) {
        if (s.intersectLine(this)) {
            return this.canIntersect(s.left);
        }
        
        return 0;
    }
    
    void styleSide(int side) {
        switch (side) {
            case 0 : noFill(); break;
            case 1 : fill(mirrorReflCol); break;
            case 2 : fill(mirrorOpaqueCol); break;
        }
    }
    
    void displayNormal(PVector normal) {
        beginShape();
        vertex(this.left.x, this.left.y);
        vertex(this.left.x + normal.x, this.left.y + normal.y);
        vertex(this.right.x + normal.x, this.right.y + normal.y);
        vertex(this.right.x, this.right.y);
        endShape(CLOSE);
    }
    
    void display() {
        PVector normalM = PVector.mult(this.normal, mirrorWidth);
        
        this.styleSide(this.front);
        this.displayNormal(normalM);
        
        this.styleSide(this.back);
        this.displayNormal(PVector.mult(normalM, -1));
    }
    
    void highlight(float h, float w) {
        PVector normalH = PVector.mult(this.normal, h);
        PVector normalW = new PVector(this.normal.y, -this.normal.x).mult(w);
        
        beginShape();
        vertex(this.left.x + normalH.x + normalW.x,  this.left.y + normalH.y + normalW.y);
        vertex(this.left.x - normalH.x + normalW.x,  this.left.y - normalH.y + normalW.y);
        vertex(this.right.x - normalH.x - normalW.x, this.right.y - normalH.y - normalW.y);
        vertex(this.right.x + normalH.x - normalW.x, this.right.y + normalH.y - normalW.y);
        endShape(CLOSE);
    }
    
    void highlightNormal(float m, float h, float w) {
        // PVector norm = PVector.mult(this.normal, m);
        PVector normalH = PVector.mult(this.normal, h * m);
        PVector normalW = new PVector(this.normal.y, -this.normal.x).mult(w);
        
        beginShape();
        vertex(this.left.x + normalH.x + normalW.x,  this.left.y + normalH.y + normalW.y);
        vertex(this.left.x + normalW.x,  this.left.y + normalW.y);
        vertex(this.right.x - normalW.x, this.right.y - normalW.y);
        vertex(this.right.x + normalH.x - normalW.x, this.right.y + normalH.y - normalW.y);
        endShape(CLOSE);
    }
}


// first intersection mirror + intersection + distance
// make sure to box the area!
Quartet<Mirror, PVector, Float, Integer> firstMirrorInter(Segment s, ArrayList<Mirror> ms, Mirror lastMirror) {
    float minDist = Float.MAX_VALUE;
    Mirror cMirror = new Mirror();
    PVector cInter = new PVector();
    int cN = 0;
    
    for (Mirror m : ms) {
        // ignore the last mirror!
        if (m == lastMirror) continue;
        
        int n = m.mIntersect(s);
        
        if (n != 0) {
            Pair<Float, Float> pInter = s.parametrizedInter(m);
            float t = pInter.getKey();
            
            // check if intersection is on the ray or not
            if (t < 0) continue; 
            
            PVector inter = PVector.sub(m.right, m.left).mult(pInter.getValue()).add(m.left);
            
            float d = PVector.dist(s.left, inter);
            
            if (d < minDist) {
                minDist = d;
                cMirror = m;
                cInter = inter;
                cN = n;
            }
        }
    }
    
    return new Quartet(cMirror, cInter, minDist, cN);
}
