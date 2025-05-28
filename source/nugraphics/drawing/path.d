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
    A collection of subpaths to be drawn.
*/
class Path : NuRefCounted {
private:
@nogc:
    
    /**
        Bounds of the path.
    */
    rect aabb;

    /**
        Current cursor position within the path.
    */
    vec2 cursor_;

    /**
        Subpaths of the path
    */
    vector!Subpath subpaths_;

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
    uint curveSubdivisions;

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
}

/**
    A mathematical description of lines and curves to be drawn.
*/
struct Subpath {
public:
@nogc:

    ~this() { nogc_delete(segments); }

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
        The end of the path.
    */
    @property vec2 end() {
        if (segments.length == 0)
            return vec2.init;
        
        return segments[$-1].p2;
    }
    
    /**
        Line segments that make up the path.
    */
    vector!line segments;
}
