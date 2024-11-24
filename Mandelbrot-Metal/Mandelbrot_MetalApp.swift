//
//  Mandelbrot_MetalApp.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/16/24.
//

import SwiftUI

@main
struct Mandelbrot_MetalApp: App {
    @State private var rendererData = RendererData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(rendererData)
        }
    }
}
