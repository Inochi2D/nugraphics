/**
    NuGraphics Color Types and Math

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.math.color;
import nulib.math;

/**
    Porter-Duff Blending operators
*/
enum CompositeOp {
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
    The color format of an image.
*/
enum PixelFormat {
    
    /**
        8-bit normalized unsigned "alpha" value.
    */
    a8Unorm,
    
    /**
        32-bit floating point "alpha" value.
    */
    a32f,

    /**
        32-bit RGB colors, stored as normalized unsigned 8-bit components.

        The last component is left undefined as padding.
    */
    rgb32Unorm,

    /**
        32-bit BGR colors, stored as normalized unsigned 8-bit components.

        The last component is left undefined as padding.
    */
    bgr32Unorm,
    
    /**
        32-bit RGBA colors, stored as normalized unsigned 8-bit components.
    */
    rgba32Unorm,

    /**
        32-bit BGRA colors, stored as normalized unsigned 8-bit components.
    */
    bgra32Unorm,

    /**
        128-bit RGB colors, stored as 32-bit floating point values.    

        The last component is left undefined as padding.    
    */
    rgb128f,

    /**
        128-bit BGR colors, stored as 32-bit floating point values.  

        The last component is left undefined as padding.      
    */
    bgr128f,

    /**
        128-bit RGBA colors, stored as 32-bit floating point values.        
    */
    rgba128f,

    /**
        128-bit BGRA colors, stored as 32-bit floating point values.        
    */
    bgra128f,
}

/**
    Gets the byte alignment from a pixel format.
*/
uint toAlignment(PixelFormat format) @nogc nothrow pure {
    final switch(format) with(PixelFormat) {
        case a8Unorm:
            return 1;

        case rgba32Unorm:
        case bgra32Unorm:
        case rgb32Unorm:
        case bgr32Unorm:
        case a32f:
            return 4;

        case rgba128f:
        case bgra128f:
        case rgb128f:
        case bgr128f:
            return 16;
    }
}

/**
    Gets the channel count for a pixel format.
*/
uint toChannelCount(PixelFormat format) @nogc nothrow pure {
    final switch(format) with(PixelFormat) {
        
        case a8Unorm:
        case a32f:
            return 1;

        case rgb32Unorm:
        case bgr32Unorm:
            return 3;

        case rgba32Unorm:
        case bgra32Unorm:
        case rgba128f:
        case bgra128f:
        case rgb128f:
        case bgr128f:
            return 4;
    }
}

/**
    Whether the given format has a transparency channel
    which is relevant for compositing.

    Alpha-only pixel formats do not count towards this.
*/
bool hasTransparency(PixelFormat format) {
    final switch(format) with(PixelFormat) {
        
        case rgb32Unorm:
        case bgr32Unorm:
        case a8Unorm:
        case a32f:
            return false;

        case rgba32Unorm:
        case bgra32Unorm:
        case rgba128f:
        case bgra128f:
        case rgb128f:
        case bgr128f:
            return true;
    }
}

/**
    An 32-bit floating point RGBA color, suitable for color related
    math operations.
*/
struct Color {
@nogc:

    // Allows indexing color as if it was a slice.
    alias data this;
    union {
        struct {
            
            /**
                Red Channel
            */
            float r = 0;
            
            /**
                Green Channel
            */
            float g = 0;
            
            /**
                Blue Channel
            */
            float b = 0;
            
            /**
                Alpha Channel
            */
            float a = 0;
        }
        float[4] data;
    }

    /**
        Creates a color from HSV.
    */
    pragma(inline, true)
    static Color fromSlice(float[] slice) {
        return Color(data: slice[0..4]);
    }

    /**
        Creates a color from HSV.
    */
    pragma(inline, true)
    static Color fromHSV(float h, float s, float v) {
        return Color.fromHSVA(h, s, v, 1);
    }

    /**
        Creates a color from HSV with an alpha component.
    */
    pragma(inline, true)
    static Color fromHSVA(float h, float s, float v, float a) {
        Color ret;
        if(s == 0.0f) { // s
            ret.data[0..$] = v;
            ret.a = a;
            return ret; // v
        } else {
            float var_h = h * 6;
            float var_i = floor(var_h);
            float var_1 = v * (1 - s);
            float var_2 = v * (1 - s * (var_h - var_i));
            float var_3 = v * (1 - s * (1 - (var_h - var_i)));

            if(var_i == 0.0f)      return Color(v, var_3, var_1, a);
            else if(var_i == 1.0f) return Color(var_2, v, var_1, a);
            else if(var_i == 2.0f) return Color(var_1, v, var_3, a);
            else if(var_i == 3.0f) return Color(var_1, var_2, v, a);
            else if(var_i == 4.0f) return Color(var_3, var_1, v, a);
            else                   return Color(v, var_1, var_2, a);
        }
    }

    /**
        Creates from normalized SRGB colors.
    */
    pragma(inline, true)
    static Color fromSRGB(float r, float g, float b) {
        return Color.fromSRGBA(r, g, b, 1);
    }

    /**
        Creates from normalized SRGBA colors.
    */
    pragma(inline, true)
    static Color fromSRGBA(float r, float g, float b, float a) {
        return Color(
            r ^^ 2.2, 
            g ^^ 2.2, 
            b ^^ 2.2, 
            a
        );
    }

    /**
        Converts the current color to grayscale.

        Note this is without SRGB normalization.
    */
    float toGrayscale() const {
        return ((r * 0.2126) + (g * 0.7152) + (b * 0.0722)) * a;
    }

    /**
        Converts the current color to linear from SRGB.
    */
    Color toLinear() {
        return Color(
            (r ^^ 1.0/2.2),
            (g ^^ 1.0/2.2),
            (b ^^ 1.0/2.2),
            a
        );
    }

    /**
        Converts the current color to an opqaue equivalent.
    */
    Color toOpaque() {
        return Color(
            r,
            g,
            b,
            1
        );
    }

    /**
        Binary operators
    */
    auto opOpAssign(string op, T)(T value) {
        import std.format : format;

        mixin(q{this = this %s value;}.format(op));
        return this;
    }

    /**
        Binary operators
    */
    auto opBinary(string op, R)(const R rhs) const {
        import std.format : format;

        Color ret = this;
        static if (is(R : Color)) {
            mixin(q{ret[0..$] %s= rhs[0..$];}.format(op));
            return ret;
        } else {
            mixin(q{ret[0..$] %s= rhs;}.format(op));
            return ret;
        }
    }

    /**
        Binary operators
    */
    Color opBinaryRight(string op, L)(const L lhs) const if (__traits(isScalar, L)) {
        import std.format : format;

        return mixin(q{Color(
            cast(float)lhs %s r,
            cast(float)lhs %s g,
            cast(float)lhs %s b,
            cast(float)lhs %s a,
        )}.format(op, op, op, op));
    }

    /**
        Allows comparing the color to another
    */
    int opCmp(R)(const R other) const {
        static if (is(R : Color))
            return cast(int)((this.toGrayscale-other.toGrayscale())*100);
        else
            return cast(int)((this.toGrayscale-other)*100);
    }
}

/**
    Modulates the given color with a given alpha value.
*/
pragma(inline, true)
Color modulate(Color a, Color b, float t) @nogc nothrow {
    return Color(
        (1 - t) * (b.r + t) * a.r,
        (1 - t) * (b.g + t) * a.g,
        (1 - t) * (b.b + t) * a.b,
        (1 - t) * (b.a + t) * a.a,
    );
}

/**
    Gets the color from a scanline.

    Params:
        scanline = The scanline to fetch the data from.
        x = The pixel to get the color for.
        format = The pixel format to convert from.
    
    Returns:
        The color at the given scanline and X coordinate.
*/
pragma(inline, true)
Color fromLine(void[] scanline, uint x, PixelFormat format) @nogc nothrow {
    uint cCount = format.toChannelCount();
    uint cAlign = format.toAlignment();

    // Invalid X coordinate check
    if (x*cCount*cAlign >= scanline.length)
        return Color.init;
    
    // Handle the different interpretations here.
    ubyte[] cUnorm = (cast(ubyte[])scanline)[x..x+cCount];
    float[] cFloat = cAlign >= 4 ? (cast(float[])scanline)[x..x+cCount] : [];
    final switch (format) with(PixelFormat) {
        
        // UNORM
        case a8Unorm:
            float brightness = cUnorm[x].fromUNorm;
            return Color(brightness, brightness, brightness, brightness);
        
        case rgb32Unorm:
            return Color(cUnorm[0].fromUNorm, cUnorm[1].fromUNorm, cUnorm[2].fromUNorm, 1);

        case bgr32Unorm:
            return Color(cUnorm[2].fromUNorm, cUnorm[1].fromUNorm, cUnorm[0].fromUNorm, 1);
        
        case rgba32Unorm:
            return Color(cUnorm[0].fromUNorm, cUnorm[1].fromUNorm, cUnorm[2].fromUNorm, cUnorm[3].fromUNorm);

        case bgra32Unorm:
            return Color(cUnorm[2].fromUNorm, cUnorm[1].fromUNorm, cUnorm[0].fromUNorm, cUnorm[3].fromUNorm);
        
        // FLOATING
        case a32f:
            float brightness = cFloat[x];
            return Color(brightness, brightness, brightness, brightness);

        case rgb128f:
            return Color(cFloat[0], cFloat[1], cFloat[2], 1);

        case bgr128f:
            return Color(cFloat[2], cFloat[1], cFloat[0], 1);
        
        case rgba128f:
            return Color(cFloat[0], cFloat[1], cFloat[2], cFloat[3]);

        case bgra128f:
            return Color(cFloat[2], cFloat[1], cFloat[0], cFloat[3]);
    }
}

/**
    Converts unsigned normalized values to a normalized
    float range.
*/
pragma(inline, true)
float fromUNorm(T)(T color) @nogc nothrow {
    static if (T.sizeof < 4)
        return color/cast(float)T.max;
    else static if (__traits(isFloating, T))
        return cast(float)color;
    else
        return color/cast(float)T.max;
}

/**
    Converts a normalized float range to unsigned 
    normalized values.
*/
pragma(inline, true)
T toUNorm(T)(float color) @nogc nothrow {
    static if (__traits(isFloating, T))
        return cast(float)color;
    else
        return cast(T)(color*T.max);
}

/**
    Performs alpha compositing given the specified operator.
*/
pragma(inline, true)
Color alpha(Color dst, Color src, CompositeOp op) @nogc nothrow {
    final switch(op) with(CompositeOp) {
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
Color normal(Color dst, Color src) @nogc nothrow {
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
Color add(Color dst, Color src) @nogc nothrow {
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
Color subtract(Color dst, Color src) @nogc nothrow {
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
Color multiply(Color dst, Color src) @nogc nothrow {
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
Color divide(Color dst, Color src) @nogc nothrow {
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
Color screen(Color dst, Color src) @nogc nothrow {
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
Color overlay(Color dst, Color src) @nogc nothrow {
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
Color darken(Color dst, Color src) @nogc nothrow {
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
Color lighten(Color dst, Color src) @nogc nothrow {
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
Color colorDodge(Color dst, Color src) @nogc nothrow {
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
Color colorBurn(Color dst, Color src) @nogc nothrow {
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
Color hardLight(Color dst, Color src) @nogc nothrow {

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
Color softLight(Color dst, Color src) @nogc nothrow {
    
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
Color difference(Color dst, Color src) @nogc nothrow {
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
Color exclusion(Color dst, Color src) @nogc nothrow {
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
Color blend(Color dst, Color src, BlendingMode mode) @nogc nothrow {
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