/**
    Bitmaps

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.bitmap;
import numem;

/**
    A bitmap is a raw collection of pixels.

    A bitmap has no special functionality and, by itself
    is not that useful outside of being a container capable
    of being passed between NuImage and APIs with specific
    alignment requirements and the like.
*/
struct Bitmap {
@nogc:
    
    /**
        Width of the bitmap
    */
    uint width;
    
    /**
        Height of the bitmap
    */
    uint height;
    
    /**
        Amount of channels per pixel in the bitmap.
    */
    uint channels;
    
    /**
        Amount of bytes per channel in the bitmap.
    */
    uint bpc;
    
    /**
        The data of the bitmap.
    */
    void[] data;

    /**
        Frees the data of the bitmap.
    */
    void free() {
        if (this.data) {
            this.data = data.nu_resize(0);
            this.width = 0;
            this.height = 0;
        }
    }
}