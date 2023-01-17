import javafx.util.*; // imports Pair

class Beam {
    ArrayList<Pair<PVector, PVector>> path; // position + normalized direction
    ArrayList<Float> lengths; // lengths of each leg of the beam
    float pathLength;
    boolean pathTerminates;
    int totalBounces;
    
    Mirror lastM;
    float creationTime;
    
    boolean eol; // when it gets absorbed;
    boolean terminating;
    float defaultTailLength;
    float tailLength;
    
    float preTailLen; // length to display before the real tail
    
    Beam(PVector head, PVector dir) {
        this.path = new ArrayList();
        this.path.add(new Pair(head, dir.normalize(null)));
        
        this.lengths = new ArrayList();
        
        this.pathLength = 0;
        this.pathTerminates = false;
        
        this.totalBounces = 0;
        this.creationTime = 0;
        
        this.eol = false;
        this.terminating = false;
        this.lastM = null;
        
        this.defaultTailLength = lenTail;
        this.tailLength = this.defaultTailLength;
        this.preTailLen = 0;
    }
    
    void setTailLen(float l) {
        this.defaultTailLength = l;
    }
    
    void clear() {
        Pair<PVector, PVector> fst = this.path.get(0);
        
        this.path.clear();
        this.path.add(fst);
        
        this.lengths.clear();
        
        this.pathLength = 0;
        this.pathTerminates = false;
        
        this.totalBounces = 0;
        this.creationTime = 0;
        
        this.eol = false;
        this.terminating = false;
        this.lastM = null;
        
        this.tailLength = this.defaultTailLength;
        this.preTailLen = 0;
    }
    
    void debugPath() {
        stroke(50);
        
        beginShape();
        
        for (Pair<PVector, PVector> pair : this.path) {
            PVector p = pair.getKey();
            vertex(p.x, p.y);
            
            circle(p.x, p.y, 5);
        }
        
        endShape();
    }
    
    // different from clear
    void recalc(float lightDist) {
        if (this.terminating) return;
        
        Triplet<PVector, PVector, Integer> info = this.displayCalc(lightDist, false);
        
        // println("new head", pair.getKey(), pair.getValue());
        
        this.path.clear();
        this.path.add(info.toPair12());
        
        this.lengths.clear();
        this.pathTerminates = false;
        
        this.pathLength = 0;
        this.creationTime += lightDist;
        this.lastM = null;
        
        this.totalBounces = info.v3;
        
        this.tailLength = this.defaultTailLength;
        this.preTailLen = this.defaultTailLength;
    }
    
    void resetDir(PVector dir) {
        this.clear();
        this.path.get(0).getValue().set(dir).normalize();
    }
    
    float totalLength() {
        float l = 0;
        
        for (float n : this.lengths) {
            l += n;
        }
        
        return l;
    }
    
    void printPath() {
        for (Pair<PVector, PVector> p : this.path) {
            println(p.getKey());
        }
    }
    
    // given the mirrors, continue this.path up to maxLength
    void continuePath(ArrayList<Mirror> ms, float maxLength) {
        if (this.pathTerminates || this.pathLength >= maxLength) return;
        
        Pair<PVector, PVector> lastPair = this.path.get(this.path.size() - 1);
        PVector lastHead = lastPair.getKey();
        PVector lastDir = lastPair.getValue();
        
        // last mirror the beam bounced off
        // Mirror lastMirror = this.lastM; // Java having no null checks!!
        
        while (this.pathLength < maxLength) {
            Segment s = new Segment(lastHead, PVector.add(lastHead, lastDir));
            
            Quartet<Mirror, PVector, Float, Integer> data = firstMirrorInter(s, ms, this.lastM);
            
            this.lastM = data.v1;
            
            this.pathLength += data.v3;
            this.lengths.add(data.v3);
            
            PVector normal = data.v1.normal;
            
            PVector newDir = PVector.sub(lastDir, PVector.mult(normal, 2 * PVector.dot(lastDir, normal))).normalize();
            
            this.path.add(new Pair(data.v2, newDir));
            
            lastHead = data.v2;
            lastDir = newDir;
            
            this.totalBounces++;
            
            if (data.v4 == 2 || this.totalBounces > maxBounces) {
                this.pathTerminates = true;
                break;
            }
        }
        
    }
    
    // calculate the beam starting a distance of startLength along the path
    Triplet<PVector, PVector, Integer> displayCalc(float startLength, boolean render) {
        if (this.eol) return new Triplet();
        
        // deal with the eol of the beam
        if (render && startLength > pathLength && this.pathTerminates) {
            this.terminating = true;
            this.tailLength -= distPerFrame;
            
            if (this.tailLength < 0) {
                this.eol = true;
                return new Triplet();
            }
        }
        
        float length = 0;
        
        int i = 0;
        Pair<PVector, PVector> p = this.path.get(0);
        PVector lastHead = p.getKey();
        PVector lastDir = p.getValue();
        float lengthLastSeg = 0;
        float ld = 0;
        
        for (float d : this.lengths) {
            ld = length + d;
            
            i++;
            
            if (ld > startLength) {
                lengthLastSeg = startLength - length;
                float dPercent = lengthLastSeg / d;
                
                p = this.path.get(i);
                
                lastHead = PVector.sub(p.getKey(), lastHead).mult(dPercent).add(lastHead);
                break;
            }
            
            length = ld;
            
            lengthLastSeg = d;
            
            p = this.path.get(i);
            lastHead = p.getKey();
            lastDir = p.getValue();
        }
        
        // now, lastHead is as far as we can go
        
        if (render) this.display(lastHead, lengthLastSeg, i);
        
        return new Triplet(lastHead, lastDir, i);
    }
    
    Triplet<PVector, PVector, Integer> displayCalc(float startLength) {
        return this.displayCalc(startLength, true);
    }
    
    // actually do the displaying part
    void display(PVector lastHead, float d, int i) {
        float length = d;
        
        int j = i - 1;
        
        PVector head = this.path.get(j).getKey();
        PVector temp = new PVector();
        
        beginShape();
        
        if (j == 0 && length < this.preTailLen) {
            float diff = this.preTailLen - length;
            PVector firstVert = PVector.mult(this.path.get(0).getValue(), -diff).add(lastHead);
            
            vertex(firstVert.x, firstVert.y);
        } else {
            vertex(lastHead.x, lastHead.y);
        }
        
        while (true) {
            if (length > this.tailLength) {
                float dPercent = (length - this.tailLength) / d;
                
                temp = PVector.sub(lastHead, head).mult(dPercent).add(head);
                
                vertex(temp.x, temp.y);
                break;
            }
            
            vertex(head.x, head.y);
            
            if (j < 1) break;
            
            j--;
            
            lastHead = head;
            
            head = this.path.get(j).getKey();
            
            d = this.lengths.get(j);
            length += d;
        }
        
        endShape();
    }
}
