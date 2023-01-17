/*
Calculations for a (directed) segment.

            front

(left) -------------- (right)

            back

*/

class Segment {
    PVector left;
    PVector right;
    PVector normal;
    
    Segment() {
        this.left = new PVector();
        this.right = new PVector();
        
        this.normal = new PVector();
    }
    
    Segment(PVector l, PVector r) {
        this.left = l;
        this.right = r;
        
        this.normal = this.compNormal();
    }
    
    PVector compNormal() {
        // NOTE: the canvas is flipped from the normal plane!!
        PVector n = new PVector(this.right.y - this.left.y, this.left.x - this.right.x);
        n.normalize();
        return n;
    }
    
    void setNormal() {
        this.normal = this.compNormal();
    }
    
    void offsetAdd(PVector p) {
        this.left.add(p);
        this.right.add(p);
    }
    
    void offsetSub(PVector p) {
        this.left.sub(p);
        this.right.sub(p);
    }
    
    boolean inBounds() {
        return vecInBounds(this.left) && vecInBounds(this.right);
    }
    
    float length() {
        return PVector.dist(left, right);
    }
    
    // signed distance
    float dist(PVector p) {
        return PVector.dot(this.normal, PVector.sub(p, this.left));
    }
    
    // if the projction of p is on the segment
    // boolean projectionOn(PVector p) {
    //     // PVector n = new PVector(this.normal.y, -this.normal.x);
    //     return PVector.dot(PVector.sub(p, this.left), new PVector(-this.normal.y, this.normal.x)) >= 0
    //         && PVector.dot(PVector.sub(p, this.right), new PVector(this.normal.y, -this.normal.x)) >= 0;
    // }
    
    // distance from the projection to the segment
    float projectionDist(PVector p) {
        float dLeft = PVector.dot(PVector.sub(p, this.left), new PVector(this.normal.y, -this.normal.x));
        float dRight = PVector.dot(PVector.sub(p, this.right), new PVector(-this.normal.y, this.normal.x));
        
        return max(dLeft, dRight);
    }
    
    // 1 if positive distance, -1 if negative distance, 0 otherwise
    int direction(PVector p) {
        float d = this.dist(p);
        
        return d > 0 ? 1 : d < 0 ? -1 : 0;
    }
    
    // if this segment's line intersects `s`
    boolean intersectLine(Segment s) {
        return this.direction(s.left) * this.direction(s.right) == -1;
    }
    
    // calculate intersection parametrically
    // (t, u) with this.left + t (this.right - this.left)
    Pair<Float, Float> parametrizedInter(Segment sg) {
        PVector r = PVector.sub(this.right, this.left);
        PVector s = PVector.sub(sg.right, sg.left);
        
        PVector sub = PVector.sub(sg.left, this.left).div(twoDCross(r, s));
        
        return new Pair(twoDCross(sub, s), twoDCross(sub, r));
    }
    
    boolean intersect(Segment s) {
        return this.intersectLine(s) && s.intersectLine(this);
    }
    
    void print() {
        println(this.left, this.right);
    }
}

float twoDCross(PVector v, PVector w) {
    return v.x * w.y - v.y * w.x;
}

boolean vecInBounds(PVector p) {
    return 0 <= p.x && p.x < width && 0 <= p.y && p.y < height;
}
