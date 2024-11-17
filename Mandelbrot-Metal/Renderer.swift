//
//  Renderer.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/16/24.
//
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    var parent: ContentView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    
    init(_ parent: ContentView) {
        
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
        
        let left_x: Float = -2.4
        let top_y: Float = 1.4
        let right_x: Float = 1.2
        let bottom_y: Float = -1.4
        
        let vertices = [
            Vertex(position: [left_x, top_y]),
            Vertex(position: [left_x, bottom_y]),
            Vertex(position: [right_x, top_y]),
            
            Vertex(position: [right_x, top_y]),
            Vertex(position: [right_x, bottom_y]),
            Vertex(position: [left_x, bottom_y])
        ]
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
//        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 3, vertexCount: 3)

        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
