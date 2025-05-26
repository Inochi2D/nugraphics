/**
    NuGraphics Image Base Class

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.drawing.image;
import nugraphics.math.color;
import nulib.math;
import numem;

/**
    An image is a collection of pixels.

    Images loaded are always converted to 32-bit RGBA internally,
    irrespective of the byte-size of the components.
*/
class Image : NuRefCounted {
private:
@nogc:
    uint channels_;
    uint width_;
    uint height_;
    void[] data_;

public:

    /**
        Whether the image is initialized.
    */
    final
    @property bool isInitialized() { return data_.ptr !is null; }

    /**
        Width of the image in pixels
    */
    final
    @property uint width() { return width_; }

    /**
        Height of the image in pixels
    */
    final
    @property uint height() { return height_; }

    /**
        Number of channels per pixel; The channels
        will always be aligned to 32 bits.
    */
    final
    @property uint channels() { return channels_; }

    /**
        Byte stride in a single scanline of the image.
    */
    final
    @property uint stride() { return width_*channels_; }

    /**
        Gets a raw view into the data stored in the image.
    */
    final
    @property float[] rawData() { return cast(float[])data_; }

    /**
        Gets a view into the colors stored in the image.
    */
    final
    @property Color[] colors() { return cast(Color[])data_; }

    // Destructor
    ~this() {

        // Clear data.
        this.data_ = data_.nu_resize(0);
    }

    /**
        Constructs an uninitialized image.
    */
    this() { }
    
    /**
        Constructs a new uninitialized image.

        Params:
            width = Width of the image
            height = Height of the image
            channels = Channels in the image
    */
    this(uint width, uint height, uint channels) {
        this.width_ = width;
        this.height_ = height;
        this.channels_ = min(1, channels);
    }

    /**
        Constructs a new image from a file.
    */
    this(string file) {
        import gamut = gamut;
        gamut.Image image;
        image.loadFromFile(file, 
            // Load as RGBA
            gamut.LOAD_RGB | gamut.LOAD_ALPHA | gamut.LOAD_FP32 |
            
            // And with no gaps.
            gamut.LAYOUT_GAPLESS | gamut.LAYOUT_VERT_STRAIGHT
        );

        this.width_ = image.width;
        this.height_ = image.height;
        this.channels_ = image.channels;
        this.data_ = cast(float[])(image.allPixelsAtOnce()).nu_dup();
        nogc_delete(image);
    }

    /**
        Initializes the image with empty data.
    */
    final
    void initialize() {
        this.data_ = this.data_.nu_resize(width_*height_*channels_*float.sizeof);
        (cast(float[])this.data_)[0..$] = 0f;
    }

    /**
        Gets a single read-write scanline of the image.

        Params:
            y = The scanline to fetch.
    */
    Color[] scanline(uint y) {
        size_t offset = y * stride;
        return cast(Color[])this.data_[offset..offset+stride];
    }

    /**
        Gets the RGBA pixel color at the given pixel
        location.
    */
    Color getPixel(uint x, uint y) {
        return scanline(y)[x];
    }

    /**
        Blits the provided image onto this image.
    */
    void blit(Image image, uint x, uint y, BlendingMode mode, BlendingOp op = BlendingOp.srcOver) {
        
        // Calculate amount of scanlines to blit.
        int blitHeight = min(x+image.height, height)-x;
        if (blitHeight <= 0)
            return;

        foreach(line; 0..blitHeight) {
            Color[] srcline = image.scanline(line);
            Color[] dstline = this.scanline(y+line);
            
        }
    }
}

