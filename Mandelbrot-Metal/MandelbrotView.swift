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
        self.draw()
    }
    
    override func rightMouseDown(with event: NSEvent) {
        guard let renderer = mandelbrot else {
            return
        }
        renderer.offset.scale = renderer.offset.scale * 1.10
        self.draw()
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard var offset = mandelbrot?.offset else {
            return
        }
        let m = offset.scale * 0.004
        offset.x = offset.x + (Float(event.scrollingDeltaX) * m * -1)
        offset.y = offset.y + (Float(event.scrollingDeltaY) * m)
        mandelbrot?.offset = offset
        self.draw()
    }
    
}
