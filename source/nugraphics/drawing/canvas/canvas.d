module nugraphics.drawing.canvas.canvas;
import nugraphics.drawing.canvas.pattern;
import nulib.collections.vector;
import nulib.collections.stack;
import nugraphics.drawing.path;
import nugraphics.math;
import numem;

/**
    A context container for drawing operations into an image.
*/
abstract
class Canvas : NuRefCounted {
private:
@nogc:
    CanvasState state;
    stack!CanvasState savedStates;

    /**
        The state of a canvas instance.
    */
    struct CanvasState {
        CompositeOp compositeOp;
        BlendingMode blendingMode;
        LineCap capStyle;
        LineJoin joinStyle;
        float lineWidth;
        float miterLimit = 10.0;
        Pattern pattern;
    }

protected:
public:

    final {

        /**
            The composition operation to be used during drawing operations.
        */
        @property CompositeOp compositeOp() { return state.compositeOp; }
        @property void compositeOp(CompositeOp compositeOp) { this.state.compositeOp = compositeOp; }

        /**
            The blending mode to use during drawing operations.
        */
        @property BlendingMode blendingMode() { return state.blendingMode; }
        @property void blendingMode(BlendingMode blendingMode) { this.state.blendingMode = blendingMode; }

        /**
            The cap style to use for stroked lines.
        */
        @property LineCap lineCap() { return state.capStyle; }
        @property void lineCap(LineCap capStyle) { this.state.capStyle = capStyle; }

        /**
            The join style to use for stroked lines.
        */
        @property LineJoin lineJoin() { return state.joinStyle; }
        @property void lineJoin(LineJoin joinStyle) { this.state.joinStyle = joinStyle; }

        /**
            The width of stroked lines.
        */
        @property float lineWidth() { return state.lineWidth; }
        @property void lineWidth(float lineWidth) { this.state.lineWidth = lineWidth; }

        /**
            The length limit for miter-styled lines.
        */
        @property float miterLimit() { return state.miterLimit; }
        @property void miterLimit(float miterLimit) { this.state.miterLimit = miterLimit; }

        /**
            The pattern style to use for drawing.
        */
        @property Pattern pattern() { return state.pattern; }
        @property void pattern(Pattern pattern) { this.state.pattern = pattern; }
    }

    /**
        Saves the current canvas state to a state store.
    */
    void save() {
        savedStates ~= state;
    }

    /**
        Restores previously saved state.
    */
    void restore() {
        CanvasState popped;
        if (savedStates.tryPop(popped)) {
            this.state = popped;
        }
    }

    /**
        Begins a path and moves the pen to the specified
        position.

        Params:
            target = The position to move the pen to.
    */
    abstract void moveTo(vec2 target);

    /**
        Draws a line to the specified position from the current
        pen position.

        Params:
            target = The target position.
    */
    abstract void lineTo(vec2 target);

    /**
        Draws a quadratic curve to the specified position from
        the current pen position.

        Params:
            ctrl1 = The first control point.
            target = The target position.
    */
    abstract void quadTo(vec2 ctrl1, vec2 target);

    /**
        Draws a cubic spline to the specified position from
        the current pen position.

        Params:
            ctrl1 = The first control point.
            ctrl2 = The second control point.
            target = The target position.
    */
    abstract void cubicTo(vec2 ctrl1, vec2 ctrl2, vec2 target);

    /**
        Closes the current subpath and starts a new one.
    */
    abstract void closePath();

    /**
        Strokes the currently stored path, then clears it
        from the canvas.
    */
    abstract void stroke();

    /**
        Fills the currently stored path, then clears it
        from the canvas.
    */
    abstract void fill();
}
