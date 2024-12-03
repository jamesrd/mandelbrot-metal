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
    // - Fix centering and drag selection
    // - Animation??
    // - Live color plotting changes
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<MandelbrotView>) -> MandelbrotMTKView {
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

struct MandelbrotViewModifier: ViewModifier {
    @Binding var rendererData: RendererData
    @State private var dragStart: NSPoint?

    func body(content: Content) -> some View {
        content
            .onKeyPress(keys: ["="]) { press in
                print("keypress")
                rendererData.reset()
                return .handled
            }
            .onTapGesture { e in
                print("Tapped \(e)")
            }
            .onLongPressGesture {
                print("Long press")
            }
            .onAppear(perform: { setupHandlers() })
    }
    
    func setupHandlers() {
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { event in
            dragStart = event.locationInWindow
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) { leftMouseUp(with: $0) }
        NSEvent.addLocalMonitorForEvents(matching: [.rightMouseUp])  { rightMouseUp(with: $0) }
        NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { scrollWheel(with: $0) }
    }
    
    func leftMouseUp(with event: NSEvent) -> NSEvent? {
        guard let windowSize = event.window?.frame.size else {
            dragStart = nil
            return event
        }
        
        print("Mouse up: \(windowSize) at \(event.locationInWindow)")
        
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
        rendererData.width *= z
        return event
    }
    
    private func recenter(cx: CGFloat, cy: CGFloat, windowSize: CGSize) {
        // need to map to coordinates in the mandelbrot space
        let dx = Float((cx - (windowSize.width / 2)) / windowSize.width)
        let dy = Float((cy - (windowSize.height / 2)) / windowSize.height)
        print("Center offset \(dx), \(dy)  from \(windowSize)")
        rendererData.x += dx * rendererData.width
        rendererData.y += dy * rendererData.width * rendererData.ratio
    }
    
    func rightMouseUp(with event: NSEvent) -> NSEvent? {
        rendererData.width *= 1.10
        return event
    }
    
    func scrollWheel(with event: NSEvent) -> NSEvent? {
        let dx = Float(event.scrollingDeltaX)
        let dy = Float(event.scrollingDeltaY)
        if abs(dy) > 0.1 || abs(dx) > 0.1 {
            let m_x = rendererData.width * -0.001
            let m_y = rendererData.width * rendererData.ratio * 0.001
            rendererData.x += dx * m_x
            rendererData.y += dy * m_y
        }
        return event
    }
}

class MandelbrotMTKView: MTKView {
    override var acceptsFirstResponder: Bool {
        return true;
    }
}
