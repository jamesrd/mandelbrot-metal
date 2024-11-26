//
//  RendererData.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/24/24.
//
import SwiftUI

@Observable class RendererData {
    var redraw: Bool = false
    var x: Float = 0.0
    var y: Float = 0.0
    var width: Float = 0.0
    var ratio: Float = 1.0
    var max_iter: Int32 = 768

    init() {
        self.reset()
    }
    
    func reset() {
        x = -0.8
        y = 0.0
        width = 3.6
        max_iter = 768
    }
}
