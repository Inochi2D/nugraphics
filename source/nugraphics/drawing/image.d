/**
    NuGraphics Image Base Class

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.drawing.image;
import nugraphics.drawing;
import nugraphics.math;

import nulib.collections.vector;
import numem;

/**
    An image is a collection of pixels.

    Images loaded are always converted to 32-bit RGBA internally,
    irrespective of the byte-size of the components.
*/
final
class Image : NuRefCounted {
private:
    void[] data_;
    uint iWidth;
    uint iHeight;
    PixelFormat iFormat;

public:
@nogc:

    ~this() {
        if (data_)
            this.data_ = this.data_.nu_resize(0);
    }

    /**
        Constructs a new image.
    */
    this(uint width, uint height, PixelFormat format) {
        this.iWidth = width;
        this.iHeight = height;
        this.iFormat = format;
        this.data_ = data_.nu_resize(
            width * height * iFormat.toAlignment()
        );
    }

    /**
        Width of the image in pixels
    */
    @property uint width() nothrow pure {
        return iWidth;
    }

    /**
        Height of the image in pixels
    */
    @property uint height() nothrow pure {
        return iHeight;
    }

    /**
        Number of channels per pixel.
    */
    @property uint channels() nothrow pure {
        return iFormat.toChannelCount;
    }

    /**
        The original format of the image data.

        The internal format may differ from the origin format,
        see $(D internalFormat) for the format used internally.
    */
    @property PixelFormat pixelFormat() nothrow pure {
        return iFormat;
    }

    /**
        Number of channels per pixel; The channels
        will always be aligned to 32 bits.
    */
    @property uint stride() nothrow pure {
        return width * channels;
    }

    /**
        Raw data of the layer.
    */
    @property void[] rawData() nothrow pure {
        return data_;
    }

    /**
        Clears the entire image with the given binary
        value.

        Params:
            clearValue = The value to write to the image buffer.
    */
    void clearAll(ubyte clearValue) {
        (cast(ubyte[])this.data_)[0..$] = clearValue;
    }

    /**
        Gets a pixel at the given coordinates.
    */
    Color getPixel(int x, int y) {
        if (x < 0 || y < 0 || x >= width || y >= height) 
            return Color.init;

        return this.scanline(y).fromLine(x, iFormat);
    }

    /**
        Gets a single read-write scanline of the image.

        Params:
            y = The scanline to fetch.
        
        Returns:
            A untyped slice of the scanline, or an 
            empty slice on failure.
    */
    void[] scanline(uint y) nothrow {
        size_t offset = y * stride;
        if (offset >= data_.length)
            return [];

        return this.data_[offset..offset+stride];
    }
}

/**
    A tile
*/
struct Tile {

    /**
        The pixel format of the tile.
    */
    PixelFormat format;

    /**
        4096 bytes of memory in the tile.
    */
    union {
        void[4096] memory;
        float[512][512] f32;
        __m128[16][16] rgba32;
    }
}
