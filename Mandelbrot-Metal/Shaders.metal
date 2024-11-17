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
    float2 coords;
};

int calculate(float x0, float y0, int max_iter) {
    int i = 0;
    float zx = 0.0, zy = 0.0;
    while(i < max_iter && zx * zx + zy * zy < 4.0) {
        float xtemp = zx * zx - zy * zy + x0;
        zy = 2.0 * zx * zy + y0;
        zx = xtemp;
        i++;
    }
    return i;
}

vertex Fragment vertexShader(const device Vertex *vertexArray[[buffer(0)]], unsigned int vid [[vertex_id]]) {
    Vertex input = vertexArray[vid];
    
    Fragment output;
    output.position = float4(input.position.x, input.position.y, 0, 1);
    
    output.coords = float2(input.position.x - 0.6, input.position.y);
    
    return output;
}

float4 calculateColor(int iteration, int iter_step) {
    float r = 0, g = 0, b = 0;
    float sd = iter_step * 1.0;
    
    if(iteration < iter_step * 3) {
        int ri = iteration % iter_step;
        r = (ri / sd);
        int gi = (iteration - iter_step) % iter_step;
        g =  (gi / sd);
        int bi = (iteration - (iter_step * 2)) % iter_step;
        b = (bi / sd);
    }
    
    return float4(r,g,b,1);
}

fragment float4 fragmentShader(Fragment input [[stage_in]]) {
    int iter_step = 50;
    
    int iteration = calculate(input.coords.x, input.coords.y, iter_step * 3);
    return calculateColor(iteration, iter_step);
}
