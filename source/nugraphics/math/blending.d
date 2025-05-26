/**
    NuGraphics Blending Logic

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.math.blending;
import nugraphics.math.color;
import nulib.math;

/**
    Porter-Duff Blending operators
*/
enum BlendingOp {
    clear,
    source,
    destination,
    srcOver,
    dstOver,
    srcIn,
    dstIn,
    srcOut,
    dstOut,
    srcAtop,
    dstAtop,
    xor,
    plus,
}

/**
    Performs alpha blending given the specified operator.
*/
pragma(inline, true)
Color alpha(Color dst, Color src, BlendingOp op) {
    final switch(op) with(BlendingOp) {
        case clear:
            return Color(0, 0, 0, 0);
        
        case source:
            return src;

        case destination:
            return dst;
        
        case srcOver:
            return Color(
                (src.a * src.r) + (dst.a * dst.r * (1 - src.a)),
                (src.a * src.g) + (dst.a * dst.g * (1 - src.a)),
                (src.a * src.b) + (dst.a * dst.b * (1 - src.a)),
                src.a + dst.a * (1.0 - src.a),
            );

        case dstOver:
            return Color(
                (src.a * src.r) * (1.0 - dst.a) + (dst.a * dst.r),
                (src.a * src.g) * (1.0 - dst.a) + (dst.a * dst.g),
                (src.a * src.b) * (1.0 - dst.a) + (dst.a * dst.b),
                src.a * (1.0 - dst.a) + dst.a,
            );
        
        case srcIn:
            return Color(
                (src.a*src.r) * dst.a,
                (src.a*src.g) * dst.a,
                (src.a*src.b) * dst.a,
                src.a*dst.a
            );

        case dstIn:
            return Color(
                (dst.a*dst.r) * src.a,
                (dst.a*dst.g) * src.a,
                (dst.a*dst.b) * src.a,
                dst.a*src.a
            );

        case srcOut:
            return Color(
                (src.a * src.r) * (1.0 - dst.a),
                (src.a * src.g) * (1.0 - dst.a),
                (src.a * src.b) * (1.0 - dst.a),
                src.a * (1.0 - dst.a)
            );

        case dstOut:
            return Color(
                (dst.a * dst.r) * (1.0 - src.a),
                (dst.a * dst.g) * (1.0 - src.a),
                (dst.a * dst.b) * (1.0 - src.a),
                dst.a * (1.0 - src.a)
            );

        case srcAtop:
            return Color(
                (src.a * src.r * dst.a) + (dst.a * dst.r * (1.0 - src.a)),
                (src.a * src.g * dst.a) + (dst.a * dst.g * (1.0 - src.a)),
                (src.a * src.b * dst.a) + (dst.a * dst.b * (1.0 - src.a)),
                src.a * dst.a + dst.a * (1.0 - src.a)
            );

        case dstAtop:
            return Color(
                (dst.a * dst.r * src.a) + (src.a * src.r * (1.0 - dst.a)),
                (dst.a * dst.g * src.a) + (src.a * src.g * (1.0 - dst.a)),
                (dst.a * dst.b * src.a) + (src.a * src.b * (1.0 - dst.a)),
                dst.a * src.a + src.a * (1.0 - dst.a)
            );

        case xor:
            return Color(
                src.a * src.r * (1.0 - dst.a) + dst.a * dst.r * (1.0 - src.a),
                src.a * src.g * (1.0 - dst.a) + dst.a * dst.g * (1.0 - src.a),
                src.a * src.b * (1.0 - dst.a) + dst.a * dst.b * (1.0 - src.a),
                src.a * (1.0 - dst.a) + dst.a * (1.0 - src.a)
            );

        case plus:
            return Color(
                (src.a*src.r) + (dst.a*dst.r),
                (src.a*src.g) + (dst.a*dst.g),
                (src.a*src.b) + (dst.a*dst.b),
                src.a+dst.a
            );
    }
}

/**
    Blending modes
*/
enum BlendingMode {
    normal,
    screen,
    overlay,
    darken,
    lighten,
    colorDodge,
    colorBurn,
    hardLight,
    softLight,
    difference,
    exclusion,
    add,
    subtract,
    multiply,
    divide,
}

/**
    Performs a "normal" blend operator.

    Operator:
        B(Cb, Cs) = Cs

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color normal(Color dst, Color src) {
    return dst.modulate(src, dst.a);
}

/**
    Performs a "add" blend operator.

    Operator:
        B(Cb, Cs) = Cb + Cs

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color add(Color dst, Color src) {
    return dst.modulate(dst+src, dst.a);
}

/**
    Performs a "subtract" blend operator.

    Operator:
        B(Cb, Cs) = Cb - Cs

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color subtract(Color dst, Color src) {
    return dst.modulate(dst-src, dst.a);
}

/**
    Performs a "multiply" blend operator.

    Operator:
        B(Cb, Cs) = Cb * Cs

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color multiply(Color dst, Color src) {
    return dst.modulate(dst*src, dst.a);
}

/**
    Performs a "subtract" blend operator.

    Operator:
        B(Cb, Cs) = Cb / Cs

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color divide(Color dst, Color src) {
    return dst.modulate(dst/src, dst.a);
}

/**
    Performs a "screen" blend operator.

    Operator:
        B(Cb, Cs) = 1 - (1 - Cb) * (1 - Cs)

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color screen(Color dst, Color src) {
    return dst.modulate(
        1 - (1 - dst) * (1 - src), 
        dst.a
    );
}

/**
    Performs a "overlay" blend operator.

    Operator:
        B(Cb, Cs) = hardLight(Cs, Cb)

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color overlay(Color dst, Color src) {
    return dst.modulate(
        1 - (1 - dst) * (1 - src), 
        dst.a
    );
}

/**
    Performs a "darken" blend operator.

    Operator:
        B(Cb, Cs) = min(Cb, Cs)

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color darken(Color dst, Color src) {
    return dst.modulate(
        Color(
            min(dst.r, src.r),
            min(dst.g, src.g),
            min(dst.b, src.b),
            src.a
        ),
        dst.a
    );
}

/**
    Performs a "lighten" blend operator.

    Operator:
        B(Cb, Cs) = min(Cb, Cs)

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color lighten(Color dst, Color src) {
    return dst.modulate(
        Color(
            max(dst.r, src.r),
            max(dst.g, src.g),
            max(dst.b, src.b),
            src.a
        ),
        dst.a
    );
}

/**
    Performs a "color dodge" blend operator.

    Operator:
        if(Cb == 0)
            B(Cb, Cs) = 0
        else if(Cs == 1)
            B(Cb, Cs) = 1
        else
            B(Cb, Cs) = min(1, Cb / (1 - Cs))

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color colorDodge(Color dst, Color src) {
    return dst.modulate(
        Color(
            clamp(min(1, dst.r / (1 - src.r)), 0, 1),
            clamp(min(1, dst.g / (1 - src.g)), 0, 1),
            clamp(min(1, dst.b / (1 - src.b)), 0, 1),
            src.a
        ),
        dst.a
    );
}

/**
    Performs a "color burn" blend operator.

    Operator:
        if(Cb == 0)
            B(Cb, Cs) = 0
        else if(Cs == 1)
            B(Cb, Cs) = 1
        else
            B(Cb, Cs) = min(1, Cb / (1 - Cs))

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color colorBurn(Color dst, Color src) {
    return dst.modulate(
        Color(
            clamp(min(1, (1 - dst.r) / src.r), 0, 1),
            clamp(min(1, (1 - dst.g) / src.g), 0, 1),
            clamp(min(1, (1 - dst.b) / src.b), 0, 1),
            src.a
        ),
        dst.a
    );
}

/**
    Performs a "hard light" blend operator.

    Operator:
        if(Cs <= 0.5)
            B(Cb, Cs) = Multiply(Cb, 2 x Cs)
        else
            B(Cb, Cs) = Screen(Cb, 2 x Cs -1)

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color hardLight(Color dst, Color src) {

    // Determine original factor.
    Color Cs = Color(
        (src.r <= 0.5) ? 2*src.r : 2 * src.r - 1,
        (src.g <= 0.5) ? 2*src.g : 2 * src.g - 1,
        (src.b <= 0.5) ? 2*src.b : 2 * src.b - 1,
        1
    );

    // Final factor.
    return dst.modulate(
        Color(
            Cs.r <= 0.5 ? dst.r * Cs.r : 1 - (1 - dst.r) * (1 - Cs.r),
            Cs.g <= 0.5 ? dst.g * Cs.g : 1 - (1 - dst.g) * (1 - Cs.g),
            Cs.b <= 0.5 ? dst.b * Cs.b : 1 - (1 - dst.b) * (1 - Cs.b),
            src.a
        ),
        dst.a
    );
}

/**
    Performs a "soft light" blend operator.

    Operator:
        if(Cb <= 0.25)
            D(Cb) = ((16 * Cb - 12) x Cb + 4) x Cb
        else
            D(Cb) = sqrt(Cb)
        if(Cs <= 0.5)
            B(Cb, Cs) = Cb - (1 - 2 x Cs) x Cb x (1 - Cb)
        else
            B(Cb, Cs) = Cb + (2 x Cs - 1) x (D(Cb) - Cb)

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color softLight(Color dst, Color src) {
    
    // Inline "D" function.
    pragma(inline, true)
    static float D(float cb) {
        return (cb <= 0.25) ? ((16 * cb - 12) * cb + 4) * cb : sqrt(cb);
    }

    // Inline "B" function.
    pragma(inline, true)
    static float B(float cb, float cs) {
        return cb <= 0.5 ?
            cb + (1 - 2 * cs) * cb * (1 - cb) :
            cb + (2 * cs - 1) * (D(cb) - cb);
    }

    // Final factor.
    return dst.modulate(
        Color(
            B(dst.r, src.r),
            B(dst.g, src.g),
            B(dst.b, src.b),
            src.a
        ),
        dst.a
    );
}

/**
    Performs a "difference" blend operator.

    Operator:
        B(Cb, Cs) = abs(Cb - Cs)

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color difference(Color dst, Color src) {
    return dst.modulate(
        Color(
            abs(dst.r - src.r),
            abs(dst.g - src.g),
            abs(dst.b - src.b),
            src.a
        ),
        dst.a
    );
}

/**
    Performs a "difference" blend operator.

    Operator:
        B(Cb, Cs) = abs(Cb - Cs)

    Params:
        dst = Destination color
        src = Source color
    
    Returns:
        Result color
*/
pragma(inline, true)
Color exclusion(Color dst, Color src) {
    return dst.modulate(
        Color(
            dst.r + src.r - 2 * dst.r * src.r,
            dst.g + src.g - 2 * dst.g * src.g,
            dst.b + src.b - 2 * dst.b * src.b,
            src.a
        ),
        dst.a
    );
}

/**
    Blends between 2 colors
*/
Color blend(Color dst, Color src, BlendingMode mode) {
    final switch(mode) with(BlendingMode) {
        case normal:        return .normal(dst, src);
        case screen:        return .screen(dst, src);
        case overlay:       return .overlay(dst, src);
        case darken:        return .darken(dst, src);
        case lighten:       return .lighten(dst, src);
        case colorDodge:    return .colorDodge(dst, src);
        case colorBurn:     return .colorBurn(dst, src);
        case hardLight:     return .hardLight(dst, src);
        case softLight:     return .softLight(dst, src);
        case add:           return .add(dst, src);
        case multiply:      return .multiply(dst, src);
        case subtract:      return .subtract(dst, src);
        case divide:        return .divide(dst, src);
        case difference:    return .difference(dst, src);
        case exclusion:     return .exclusion(dst, src);
    }
}