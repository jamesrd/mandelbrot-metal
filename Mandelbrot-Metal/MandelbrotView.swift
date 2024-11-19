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
    
}
