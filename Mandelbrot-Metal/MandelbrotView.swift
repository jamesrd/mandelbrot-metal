//
//  MandelbrotView.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/18/24.
//

import MetalKit

class MandelbrotView: MTKView {
    
    var mandelbrot: Renderer?
    
    private var dragStart: NSPoint?
    
    override var acceptsFirstResponder: Bool {
        return true;
    }
    
    override func mouseDown(with event: NSEvent) {
        dragStart = event.locationInWindow
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let renderer = mandelbrot else {
            dragStart = nil
            return
        }
        guard let windowSize = event.window?.frame.size else {
            dragStart = nil
            return
        }
        
        var z: Float = 0.8
        let end = event.locationInWindow;
        var cx = end.x
        var cy = end.y
        
        if let start = dragStart {
            let dx = abs(end.x - start.x)
            let dy = abs(end.y - start.y)
            if dx > 10 && dy > 10 {
                cx = (start.x + end.x) / 2
                cy = (start.y + end.y) / 2
                z = Float(dx / windowSize.width)
            }
        }
        dragStart = nil
        
        print("New center \(cx), \(cy) zoom \(z)")
        recenter(cx: cx, cy: cy, windowSize: windowSize)
        renderer.offset.x_scale *= z
        renderer.offset.y_scale *= z
        self.draw()
    }
    
    private func recenter(cx: CGFloat, cy: CGFloat, windowSize: CGSize) {
        // need to map to coordinates in the mandelbrot space
        let dx = Float((cx - (windowSize.width / 2)) / windowSize.width)
        let dy = Float((cy - (windowSize.height / 2)) / windowSize.height)
        print("Center offset \(dx), \(dy)  from \(windowSize)")
        if let renderer = mandelbrot {
            let yt = renderer.offset.y_scale * 2
            let xt = renderer.offset.x_scale * 2
            renderer.offset.x += dx * xt
            renderer.offset.y += dy * yt
        }
    }
    
    override func rightMouseUp(with event: NSEvent) {
        guard let renderer = mandelbrot else {
            return
        }
        renderer.offset.x_scale *= 1.10
        renderer.offset.y_scale *= 1.10
        self.draw()
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard var offset = mandelbrot?.offset else {
            return
        }
        let m_x = offset.x_scale * -0.004
        let m_y = offset.y_scale * 0.004
        offset.x = offset.x + (Float(event.scrollingDeltaX) * m_x)
        offset.y = offset.y + (Float(event.scrollingDeltaY) * m_y)
        mandelbrot?.offset = offset
        self.draw()
    }
    
    override func keyUp(with event: NSEvent) {
        print(event.keyCode)
        if(event.keyCode == 24) {
            guard let renderer = mandelbrot else {
                return
            }
            renderer.resetOffset() // also need to reset the ratio
            self.draw()
        }
    }
    
}
