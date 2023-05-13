import Foundation
import Metal
import shaders

struct Main {
    static func main() {
        let device = MTLCopyAllDevices()[0]
        let commandQueue = device.makeCommandQueue()!
        
        let mainBuffer = device.makeBuffer(length: 4, options: .storageModeShared)!
        
        let cache = PipelineStateCache(device: device)
        var rps: MTLRenderPipelineState!
        withPipelineStateDescriptor(recipe: .main) {
            rps = cache.makePipelineStateWithDescriptor($0)
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.renderTargetWidth = 1
        passDescriptor.renderTargetHeight = 1
        passDescriptor.defaultRasterSampleCount = 1
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)!
        commandEncoder.setFragmentBuffer(mainBuffer, offset: 0, index: 0)
        commandEncoder.setRenderPipelineState(rps)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let value = mainBuffer.contents().load(as: UInt32.self)
        print(value)
    }
}

Main.main()
