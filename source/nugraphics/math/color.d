/**
    NuGraphics Color Math

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.math.color;
public import nugraphics.math.blending;
import nulib.math;

/**
    An additive RGBA color model color.
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
Color modulate(Color a, Color b, float t) {
    return Color(
        (1 - t) * (b.r + t) * a.r,
        (1 - t) * (b.g + t) * a.g,
        (1 - t) * (b.b + t) * a.b,
        (1 - t) * (b.a + t) * a.a,
    );
}

/**
    Converts unsigned normalized values to a normalized
    float range.
*/
pragma(inline, true)
float fromUNorm(T)(T color) {
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
T toUNorm(T)(float color) {
    static if (__traits(isFloating, T))
        return cast(float)color;
    else
        return cast(T)(color*T.max);
}
