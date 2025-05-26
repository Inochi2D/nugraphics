/**
    NuGraphics Samplers

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.drawing.sampler;
import nugraphics.drawing.image;
import nugraphics.math;
import numem;

/**
    Border wrapping mode
*/
enum BorderMode {
    
    /**
        Clamp-to-color
    */
    color,
    
    /**
        Clamp texture
    */
    clamp,
    
    /**
        Repeat texture infinitely in all directions
    */
    repeat,
    
    /**
        Mirror texture infinitely in all directions.
    */
    mirror
}

/**
    A filter used during sampling.
*/
enum Filter {
    /**
        Filter which choses the pixel which the position
        overlaps.
    */
    point   = 0x01,

    /**
        Filter which linearly interpolates between the surrounding
        pixels.
    */
    linear  = 0x02,

    /**
        Filter which interpolates between the surrounding
        pixels using a bicubic spline.
    */
    bicubic = 0x03
}

/**
    Samplers allow reading pixel data from arbitrary locations within an image.
*/
class Sampler : NuRefCounted {
public:
@nogc:

    /**
        How to handle borders.
    */
    BorderMode borderMode;

    /**
        The filter to use.
    */
    Filter filter;

    /**
        Border color to select with the color border mode.
    */
    Color borderColor;

    /**
        Applies the border mode to the given UV coordinate.

        Params:
            uv = The UV coordinates to apply the border mode to.

        Returns:
            The coordinates mapped to the border mode.
    */
    vec2 border(vec2 uv) {
        final switch(borderMode) {
            case BorderMode.clamp:
                return clamp(uv, vec2.zero, vec2.one);
            case BorderMode.repeat:
                return vec2(mod(uv.x, 1), mod(uv.y, 1));
            case BorderMode.mirror:
                float mulX = mod(abs(uv.x), 2) >= 1 ? -1 : 1;
                float mulY = mod(abs(uv.y), 2) >= 1 ? -1 : 1;
                float uvX = mod(uv.x, 1);
                float uvY = mod(uv.y, 1);
                return vec2(uvX*mulX, uvY*mulY).abs();
            case BorderMode.color:
                return uv;
        }
    }

    /**
        Samples an RGBA color from the image at the given
        UV coordinates.
    */
    Color sample(vec2 uv, Image image) {
        vec2 buv = border(uv);

        // OOB with mode being color.
        if (buv.x < 0 || buv.x > 1 || 
            buv.y < 0 || buv.y > 1)
            return borderColor;

        // Coordinates of pixel (truncated)
        float x = trunc(buv.x*cast(float)image.width);
        float y = trunc(buv.y*cast(float)image.height);
        final switch(filter) {
            case Filter.point:
                int cx = cast(int)x;
                int cy = cast(int)y;
                return image.getPixel(cx, cy);
            
            case Filter.linear:
                int cx = cast(int)(x+0.5f);
                int cy = cast(int)(y+0.5f);

                // Get square of pixels around our top left corner.
                Color pixTL = image.getPixel(cx,     cy);
                Color pixTR = image.getPixel(cx+1,   cy);
                Color pixBL = image.getPixel(cx,     cy+1);
                Color pixBR = image.getPixel(cx+1,   cy+1);
                
                Color pixTop = lerp(pixTR, pixTL, uv.x);
                Color pixBottom = lerp(pixBR, pixBL, uv.x);
                return lerp(pixTop, pixBottom, uv.y);
            
            // TODO: Actually implement bicubic filtering.
            case Filter.bicubic:
                int cx = cast(int)(x+0.5f);
                int cy = cast(int)(y+0.5f);

                // Get square of pixels around our top left corner.
                Color pixTL = image.getPixel(cx,     cy);
                Color pixTR = image.getPixel(cx+1,   cy);
                Color pixBL = image.getPixel(cx,     cy+1);
                Color pixBR = image.getPixel(cx+1,   cy+1);
                
                Color pixTop = lerp(pixTR, pixTL, uv.x);
                Color pixBottom = lerp(pixBR, pixBL, uv.x);
                return lerp(pixTop, pixBottom, uv.y);
        }
    }
}