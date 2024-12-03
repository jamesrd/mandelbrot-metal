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

vertex Fragment vertexShader(const device Vertex *vertexArray[[buffer(0)]], const device Offset &offset[[buffer(1)]], unsigned int vid [[vertex_id]]) {
    Vertex input = vertexArray[vid];
    
    Fragment output;
    output.position = float4(input.position.x, input.position.y, 0, 1);
    
    output.coords = float2(input.position.x * offset.x_scale + offset.x, input.position.y * offset.y_scale + offset.y);
    
    return output;
}

float4 hsvToRgb(float h, float s, float v) {
    float r = 0, g = 0, b = 0;
    float c = v * s;
    float hp = h/60;
    float x = c * (1 - abs(fmod(hp, 2.0) - 1));
    float m = v - c;
    if(0 <= hp && hp < 1) {
        r = c;
        g = x;
        b = 0;
    } else if(hp < 2) {
        r = x;
        g = c;
        b = 0;
    } else if(hp < 3) {
        r = 0;
        g = c;
        b = x;
    } else if(hp < 4) {
        r = 0;
        g = x;
        b = c;
    } else if(hp < 5) {
        r = x;
        g = 0;
        b = c;
    } else if(hp < 6) {
        r = c;
        g = 0;
        b = x;
    }
    
    return float4(r+m, g+m, b+m, 1);
}

float4 calculateColorGrayscale(int iteration, int max_iter) {
    float r = 0, g = 0, b = 0;
    float sd = max_iter * 1.0;
    
    if(iteration < max_iter) {
        float v = iteration / sd;
        r = v;
        g = v;
        b = v;
    }
    
    return float4(r,g,b,1);
}

float4 calculateColor(int iteration, int max_iter) {
    if(iteration >= max_iter) {
        return float4(0,0,0,1);
    }
    float mif = max_iter * 1.0;
    float h = fmod(pow(iteration/mif * 360, 1.5), 360.0);
    float s = 1.0;
    float v = (iteration/mif) * 1.0;
    
    return hsvToRgb(h, s, v);
}

float4 calculateColor_old(int iteration, int max_iter) {
    float r = 0, g = 0, b = 0;
    int iter_step = max_iter / 3;
    float sd = iter_step * 1.0;
    
    if(iteration < max_iter) {
        int ri = iteration % iter_step;
        r = (ri / sd);
        int gi = (iteration - iter_step) % iter_step;
        g =  (gi / sd);
        int bi = (iteration - (iter_step * 2)) % iter_step;
        b = (bi / sd);
    }
    
    return float4(r,g,b,1);
}

fragment float4 fragmentShader(Fragment input [[stage_in]], const device MandelbrotControl &mc[[buffer(0)]]) {
    int iteration = calculate(input.coords.x, input.coords.y, mc.max_iter);
    return calculateColor(iteration, mc.max_iter);
}
