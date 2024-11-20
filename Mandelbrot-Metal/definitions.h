//
//  definitions.h
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/16/24.
//

#ifndef definitions_h
#define definitions_h


#include <simd/simd.h>

struct Vertex {
    vector_float2 position;
};

struct Offset {
    float x;
    float y;
    float scale;
    float ratio;
};

struct MandelbrotControl {
    int max_iter;
};

#endif
