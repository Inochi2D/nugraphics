/**
    NuGraphics Mathematical Types and Functionality

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module nugraphics.math;

public import nugraphics.math.linalg;
public import nugraphics.math.color;
public import nulib.math;
public import inteli;

/**
    4 32-bit floats for SIMD operation.
*/
static if (is(float4))
    alias f32x4 = __m128;
else
    alias f32x4 = void;