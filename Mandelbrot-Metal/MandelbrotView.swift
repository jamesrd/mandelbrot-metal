//
//  MandelbrotView.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/18/24.
//

import MetalKit
import SwiftUICore
import SwiftUI

struct MandelbrotView: NSViewRepresentable {
    @Binding var rendererData: RendererData
    
    let mtkView: MandelbrotMTKView = MandelbrotMTKView()
    
    // plans:
    // - Move control of what region to draw to higher level code
    // - Learn how to correctly develop event handling
    // - Animation??
    // - Live color plotting changes
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<MandelbrotView>) -> MandelbrotMTKView {
        mtkView.rendererData = $rendererData
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MandelbrotMTKView, context: NSViewRepresentableContext<MandelbrotView>) {
        print("Update NSView")
        nsView.draw()
    }
}

class MandelbrotMTKView: MTKView {
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
    }
    
    override func scrollWheel(with event: NSEvent) {
        let dx = Float(event.scrollingDeltaX)
        let dy = Float(event.scrollingDeltaY)
        if abs(dy) > 0.1 || abs(dx) > 0.1 {
            let m_x = rendererData!.wrappedValue.width * -0.001
            let m_y = rendererData!.wrappedValue.width * rendererData!.wrappedValue.ratio * 0.001
            rendererData!.wrappedValue.x += dx * m_x
            rendererData!.wrappedValue.y += dy * m_y
        }
    }
}
