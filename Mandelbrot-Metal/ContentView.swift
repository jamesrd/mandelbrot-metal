//
//  ContentView.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/16/24.
//

import SwiftUI
import MetalKit

struct ContentView: NSViewRepresentable {
    @Environment(RendererData.self) var rendererData
    // plans:
    // - Move control of what region to draw to higher level code
    // - Learn how to correctly develop event handling
    // - Animation??
    // - Live color plotting changes
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<ContentView>) -> MandelbrotView {
        let mtkView = MandelbrotView()
        let coordinator = context.coordinator
        mtkView.rendererData = rendererData
        mtkView.delegate = coordinator
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
    
    func updateNSView(_ nsView: MandelbrotView, context: NSViewRepresentableContext<ContentView>) {
        print("updateNSView")
    }
}

#Preview {
    ContentView()
        .environment(RendererData())
}
