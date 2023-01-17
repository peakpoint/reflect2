// store n pieces of info with different types

static class Triplet<A, B, C> {
    A v1;
    B v2;
    C v3;
    
    Triplet () {
        this.v1 = null;
        this.v2 = null;
        this.v3 = null;
    }
    
    Triplet (A v1, B v2, C v3) {
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
    }
    
    Pair<A, B> toPair12() {
        return new Pair(this.v1, this.v2);
    }
}

static class Quartet<A, B, C, D> {
    A v1;
    B v2;
    C v3;
    D v4;
    
    Quartet (A v1, B v2, C v3, D v4) {
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
        this.v4 = v4;
    }
}
