//
//  MandelbrotView.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/18/24.
//

import MetalKit

class MandelbrotView: MTKView {
    
    var mandelbrot: Renderer?
    
    override func mouseDown(with event: NSEvent) {
        guard let renderer = mandelbrot else {
            return
        }
        renderer.offset.scale = renderer.offset.scale * 0.90
        print(renderer.offset.scale)
        self.draw()
    }
    
    override func rightMouseDown(with event: NSEvent) {
        guard let renderer = mandelbrot else {
            return
        }
        renderer.offset.scale = renderer.offset.scale * 1.10
        print(renderer.offset.scale)
        self.draw()
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard var offset = mandelbrot?.offset else {
            return
        }
        let m = offset.scale * 0.01
        offset.x = offset.x + (Float(event.scrollingDeltaX) * m * -1)
        offset.y = offset.y + (Float(event.scrollingDeltaY) * m)
        print(offset.x)
        print(offset.y)
        mandelbrot?.offset = offset
        self.draw()
    }
    
}
