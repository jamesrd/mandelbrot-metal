//
//  Renderer.swift
//  Mandelbrot-Metal
//
//  Created by James Devries on 11/16/24.
//
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    let start_x: Float = -0.8
    let start_y: Float  = 0.0
    let start_width = 3.6
    
    
    var parent: ContentView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    let fragmentBuffer: MTLBuffer
    var offset: Offset
    
    func resetOffset() {
        offset.x = start_x
        offset.y = start_y
        offset.x_scale = 1.1
        offset.y_scale = 0.9
    }
    
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
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
        
        let top_left = Vertex(position: [-1.0, 1.0])
        let bottom_left = Vertex(position: [-1.0, -1.0])
        let top_right = Vertex(position: [1.0, 1.0])
        let bottom_right = Vertex(position: [1.0, -1.0])
        
        let vertices = [
            top_left, bottom_left, top_right,
            top_right, bottom_right, bottom_left
        ]
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        
        var fb = MandelbrotControl(max_iter: 768)
        fragmentBuffer = metalDevice.makeBuffer(bytes: &fb, length: MemoryLayout<MandelbrotControl>.stride, options: [])!
        
        offset = Offset(x: start_x, y: start_y, x_scale: 1.1, y_scale: 0.9)
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        offset.ratio = Float(size.width) / Float(size.height)
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
        
        let offsetBuffer = metalDevice.makeBuffer(bytes: &offset, length: MemoryLayout<Offset>.stride, options: [])!
        renderEncoder?.setVertexBuffer(offsetBuffer, offset: 0, index: 1)
        renderEncoder?.setFragmentBuffer(fragmentBuffer, offset: 0, index: 0)
        
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
