//
//  ContentView.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/16/24.
//

import SwiftUI
import MetalKit


struct ContentView: View {
    @State private var model = RendererData()
    
    var body: some View {
        VStack {
            Text("center: \(model.x),\(model.y) width: \(model.width)")
            MandelbrotView(rendererData: $model)
                .modifier(MandelbrotViewModifier(rendererData: $model))
        }
    }
}

#Preview {
    ContentView()
}
