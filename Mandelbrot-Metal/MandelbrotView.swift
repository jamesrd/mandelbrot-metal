//
//  MandelbrotView.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/18/24.
//

import MetalKit
import SwiftUICore

class MandelbrotView: MTKView {
    var rendererData: Binding<RendererData>?

    private var dragStart: NSPoint?
    
    override var acceptsFirstResponder: Bool {
        return true;
    }
    
    override func mouseDown(with event: NSEvent) {
        dragStart = event.locationInWindow
    }
    
    override func mouseUp(with event: NSEvent) {
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
        rendererData!.wrappedValue.width *= z
        self.draw()
    }
    
    private func recenter(cx: CGFloat, cy: CGFloat, windowSize: CGSize) {
        // need to map to coordinates in the mandelbrot space
        let dx = Float((cx - (windowSize.width / 2)) / windowSize.width)
        let dy = Float((cy - (windowSize.height / 2)) / windowSize.height)
        print("Center offset \(dx), \(dy)  from \(windowSize)")
        rendererData!.wrappedValue.x += dx * rendererData!.wrappedValue.width
        rendererData!.wrappedValue.y += dy * rendererData!.wrappedValue.width * rendererData!.wrappedValue.ratio
    }
    
    override func rightMouseUp(with event: NSEvent) {
        rendererData!.wrappedValue.width *= 1.10
        self.draw()
    }
    
    override func scrollWheel(with event: NSEvent) {
        let m_x = rendererData!.wrappedValue.width * -0.004
        let m_y = rendererData!.wrappedValue.width * rendererData!.wrappedValue.ratio * 0.004
        rendererData!.wrappedValue.x += (Float(event.scrollingDeltaX) * m_x)
        rendererData!.wrappedValue.y += (Float(event.scrollingDeltaY) * m_y)
        self.draw()
    }
    
//    override func keyUp(with event: NSEvent) {
//        if(event.keyCode == 24) {
//            rendererData!.reset()
//            self.draw()
//            print(event.keyCode)
//        }
//    }
    
}
