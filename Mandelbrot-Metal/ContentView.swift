//
//  ContentView.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/16/24.
//

import SwiftUI
import MetalKit

struct MandelbrotView2: NSViewRepresentable {
    @Binding var rendererData: RendererData
    
    let mtkView: MandelbrotView = MandelbrotView()
    
    // plans:
    // - Move control of what region to draw to higher level code
    // - Learn how to correctly develop event handling
    // - Animation??
    // - Live color plotting changes
    
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<MandelbrotView2>) -> MandelbrotView {
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
    
    func updateNSView(_ nsView: MandelbrotView, context: NSViewRepresentableContext<MandelbrotView2>) {
        print("Update NSView")
        nsView.draw()
    }
}

struct ContentView: View {
    @State private var model = RendererData()
    
    var body: some View {
        VStack {
            Text("center: \(model.x),\(model.y) width: \(model.width)")
            MandelbrotView2(rendererData: $model)
                .environment(model)
                .onKeyPress(keys: ["="]) { press in
                    print("keypress")
                    model.reset()
                    return .handled
                }
        }
    }
}

#Preview {
    ContentView()
}
