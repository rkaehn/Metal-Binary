import Foundation
import Metal

public final class PipelineStateCache {
    private let device: MTLDevice
    private var library: MTLLibrary!
    private var binaryArchive: MTLBinaryArchive!
    
    public init(device: MTLDevice) {
        self.device = device
        
        let bundle = Bundle(identifier: "com.raffaelkaehn.metal-binary.shaders")!
        library = {
            let libURL = bundle.url(forResource: "main", withExtension: "metallib")!
            return try! device.makeLibrary(URL: libURL)
        }()
        binaryArchive = {
            let descriptor = MTLBinaryArchiveDescriptor()
            descriptor.url = bundle.url(forResource: "mainbin", withExtension: "metallib")
            return try! device.makeBinaryArchive(descriptor: descriptor)
        }()
    }
    
    private func makeFunctionWithDescriptor(_ functionDescriptor: FunctionDescriptor) -> MTLFunction {
        let descriptor = MTLFunctionDescriptor()
        descriptor.binaryArchives = [binaryArchive]
        switch functionDescriptor.kind {
        case .basic:
            descriptor.name = functionDescriptor.name
        case let .specialized(specializedName, _):
            descriptor.name = specializedName
        }
        return try! library.makeFunction(descriptor: descriptor)
    }
    
    public func makePipelineStateWithDescriptor(_ pipelineStateDescriptor: PipelineStateDescriptor) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.binaryArchives = [binaryArchive]
        descriptor.vertexFunction = makeFunctionWithDescriptor(pipelineStateDescriptor.vertexFunction)
        descriptor.fragmentFunction = makeFunctionWithDescriptor(pipelineStateDescriptor.fragmentFunction)
        return try! device.makeRenderPipelineState(descriptor: descriptor,
                                                   options: .failOnBinaryArchiveMiss,
                                                   reflection: nil)
    }
}
