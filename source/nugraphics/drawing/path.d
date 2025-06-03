/**
    NuGraphics Paths

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.drawing.path;
import nugraphics.math;
import nulib.collections.vector;
import nulib.math;
import numem;

/**
    The cap shape of line segments when stroking.
*/
enum LineCap {
    
    /**
        Lines are capped off flat line.
    */
    butt,

    /**
        Lines are capped off with a square extending
        slightly past the endpoint.
    */
    square,

    /**
        Lines are capped off with a half-circle extending
        slightly past the endpoint.
    */
    circle
}

/**
    The shape of connecting line segments when stroking.
*/
enum LineJoin {
    
    /**
        Extend the shape of the lines until they meet.
    */
    miter,

    /**
        Connect the line segments with triangles.
    */
    bevel,

    /**
        Connect the line segments with arcs.
    */
    round
}

/**
    A logical path; a series of lines which makes up shapes.

    Higher level primitves such as splines are decomposed into
    simple line segments.
*/
class Path : NuRefCounted {
private:
@nogc:

    /// Default value for the axis aligned bounding box.
    enum aabbDefault = rect(float.infinity, -float.infinity, float.infinity, -float.infinity);
    
    vector!Subpath subpaths_;
    rect aabb = aabbDefault;
    vec2 cursor_;

    //
    //      Internal handling
    //

    void recalcBounds(vec2 pos) {

        // Resize X axis bounds
        if (pos.x < aabb.xMin)
            aabb.xMin = pos.x;
        if (pos.x > aabb.xMax)
            aabb.xMax = pos.x;

        // Resize Y axis.
        if (pos.y < aabb.yMin)
            aabb.yMin = pos.y;
        if (pos.y > aabb.yMax)
            aabb.yMax = pos.y;
    }

    void push(vec2 p1, vec2 p2, bool move = true) {
        this.subpath.segments ~= line(p1, p2);
        this.recalcBounds(p1);
        this.recalcBounds(p2);

        if (move) this.cursor_ = p2;
    }

public:

    /**
        How many times to subdivide curves.
    */
    uint curveSubdivisions = 24;

    /**
        Gets the current active subpath.
    */
    final
    @property ref Subpath subpath() {
        if (this.subpaths_.length > 0)
            return this.subpaths_[$-1];

        this.subpaths_ ~= Subpath();
        return this.subpaths_[$-1];
    }

    /**
        Subpaths of the path
    */
    final
    @property Subpath[] subpaths() {
        return subpaths_[];
    }
    
    /**
        Bounds of the path.
    */
    final
    @property rect bounds() {
        return aabb;
    }

    /**
        Current cursor position within the path.
    */
    final
    @property vec2 cursor() {
        return cursor_;
    }

    // Destructor
    ~this() { this.clear(); }

    /**
        Begins a path
    */
    void moveTo(vec2 pos) {
        this.closePath();
        this.cursor_ = pos;
    }

    /**
        Draws a line to the given point
    */
    void lineTo(vec2 target) {
        this.push(cursor_, target);
    }

    /**
        Draws a quadratic curve to the given target.
    */
    void quadTo(vec2 ctrl1, vec2 target) {
        float step = 1.0/cast(float)curveSubdivisions;
        vec2 qstart = cursor_;

        foreach(i; 1..curveSubdivisions) {
            float t = cast(float)i*step;
            this.lineTo(quad(qstart, ctrl1, target, t));
        }
    }

    /**
        Draws a cubic spline to the given target.
    */
    void cubicTo(vec2 ctrl1, vec2 ctrl2, vec2 target) {
        float step = 1.0/cast(float)curveSubdivisions;
        vec2 qstart = cursor_;

        foreach(i; 1..curveSubdivisions) {
            float t = cast(float)i*step;
            this.lineTo(cubic(qstart, ctrl1, ctrl2, target, t));
        }
    }

    /**
        Closes the current subpath and starts a new one.
    */
    void closePath() {

        // No need to close a path that does not have any
        // data.
        if (this.subpath.length == 0)
            return;
        
        vec2 start = subpaths[$-1].start;
        vec2 end = subpaths[$-1].end;
        this.push(end, start);

        this.subpaths_ ~= Subpath();
    }

    /**
        Clears all subpaths from the path.
    */
    void clear() {

        // Free subpaths.
        foreach(ref subpath; this.subpaths_) {
            subpath.clear();
        }
        this.subpaths_.clear();
        
        // Reset state.
        this.cursor_ = vec2.zero;
        this.aabb = aabbDefault;
    }

    /**
        Makes a copy of the path
    */
    Path clone() {
        Path npath = nogc_new!Path();
        foreach(ref Subpath subpath; subpaths_[]) {
            npath.subpaths_ ~= subpath.clone();
        }
        return npath;
    }
}

/**
    A mathematical description of lines and curves to be drawn.
*/
struct Subpath {
private:
    vector!line segments;

public:
@nogc:

    /**
        A list of line segments in the subpath.
    */
    @property line[] lines() {
        return segments[];
    }

    /**
        The length of the subpath (in line segments).
    */
    @property size_t length() { 
        return segments.length; 
    }

    /**
        The start of the path.
    */
    @property vec2 start() {
        if (segments.length == 0)
            return vec2.init;
        
        return segments[0].p1;
    }

    /**
        The end point of the path.
    */
    @property vec2 end() {
        if (segments.length == 0)
            return vec2.init;
        
        return segments[$-1].p2;
    }

    /**
        Whether the subpath is closed.
    */
    @property bool isClosed() {
        vec2 sp = start;
        vec2 ep = end;

        if (!sp.isFinite || !ep.isFinite)
            return false;
        return sp == ep;
    }
    
    /**
        Pushes a line segment to the subpath.
    */
    void push(line lineSegment) {
        this.segments ~= lineSegment;
    }

    /**
        Clears the subpath of line segments.
    */
    void clear() {
        this.segments.clear();
    }

    /**
        Clones the subpath.
    
        Returns:
            A cloned version of the subpath,
            the caller is responsible for clearing/freeing it.
    */
    Subpath clone() {

        Subpath newPath;
        newPath.segments ~= this.lines;
        return newPath;
    }
}
