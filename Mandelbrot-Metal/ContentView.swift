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
                .onKeyPress(keys: ["="]) { press in
                    print("keypress")
                    model.reset()
                    return .handled
                }
                .onAppear(perform: {
                    NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { event in
                            print ("mouse down")
                        
                       return event
                    }
                    NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) { event in
                        print ("mouse up")
                        
                        return event
                    }
                })
        }
    }
}

#Preview {
    ContentView()
}
