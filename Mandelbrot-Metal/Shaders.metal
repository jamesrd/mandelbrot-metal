//
//  Shaders.metal
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/16/24.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

struct Fragment {
    float4 position [[position]];
    float4 color;
};

vertex Fragment vertexShader(const device Vertex *vertexArray[[buffer(0)]], unsigned int vid [[vertex_id]]) {
    Vertex input = vertexArray[vid];
    
    Fragment output;
    output.position = float4(input.position.x, input.position.y, 0, 1);
    float r = input.position.x < 0 ? 1 : 0;
    float g = input.position.y < 0 ? 1 : 0;
    float b = input.position.x > 0 ? 1 : 0;
    output.color = float4(r,g,b,1);
    
    return output;
}

fragment float4 fragmentShader(Fragment input [[stage_in]]) {
    return input.color;
}

