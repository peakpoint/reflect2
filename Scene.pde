class Scene {
    ArrayList<Beam> beams;
    ArrayList<Mirror> mirrors;
    float lightDist; // distance light would have travelled
    
    Scene() {
        this.beams = new ArrayList();
        
        this.mirrors = new ArrayList(4);
        
        this.addBoundary();
        
        for (Mirror m: this.mirrors) {
            m.immutable = true;
        }
        
        float lightDist = 0;
    }
    
    void addBoundary() {
        PVector tl = new PVector(0, 0);
        PVector tr = new PVector(width, 0);
        PVector bl = new PVector(0, height);
        PVector br = new PVector(width, height);
        
        // mirrors on the boundary
        this.mirrors.add(new Mirror(tl, tr));
        this.mirrors.add(new Mirror(tl, bl));
        this.mirrors.add(new Mirror(tr, br));
        this.mirrors.add(new Mirror(bl, br));
    }
    
    void addBeam(Beam b) {
        b.creationTime = lightDist;
        
        this.beams.add(b);
    }
    
    void addMirror(Mirror m) {
        this.mirrors.add(m);
    }
    
    void continuePath(float maxLength) {
        for (Beam b : this.beams) {
            b.continuePath(this.mirrors, maxLength - b.creationTime);
        }
    }
    
    void displayMirrors() {
        stroke(0);
        
        for (Mirror m : this.mirrors) {
            m.display();
        }
    }
    
    void displayBeams(int timeStart, float tailLength) {
        stroke(255, 255, 0);
        noFill();
        
        for (Beam b : this.beams) {
            b.displayCalc(timeStart);
        }
    }
    
    void stepTime() {
        this.lightDist += distPerFrame;
    }
    
    void displayBeamsTime() {
        stroke(255, 255, 0);
        noFill();
        
        for (Beam b : this.beams) {
            b.displayCalc(this.lightDist - b.creationTime);
        }
        
        // can't remove beams from inside the loop!
        this.cleanup();
    }
    
    void debugPaths() {
        for (Beam b : this.beams) {
            b.debugPath();
        }
    }
    
    // remove beams
    void cleanup() {
        Beam b;
        
        for (int i = this.beams.size() - 1; i >= 0; i--) {
            if (this.beams.get(i).eol) this.beams.remove(i);
        }
    }
    
    void recalcBeams() {
        for (Beam b : this.beams) {
            b.recalc(this.lightDist - b.creationTime);
            b.continuePath(this.mirrors, distPerFrame + 10);
        }
    }
}
