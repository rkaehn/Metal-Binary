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
        descriptor.name = functionDescriptor.name
        switch functionDescriptor.kind {
        case .basic:
            break
        case let .specialized(specializedName, functionConstants):
            let constantValues = MTLFunctionConstantValues()
            for functionConstant in functionConstants {
                switch functionConstant.payload {
                case var .uchar(value):
                    constantValues.setConstantValue(&value, type: .uchar, index: functionConstant.index)
                }
            }
            descriptor.constantValues = constantValues
            descriptor.specializedName = specializedName
        }
        return try! library.makeFunction(descriptor: descriptor)
    }
    
    public func makePipelineStateWithDescriptor(_ pipelineStateDescriptor: PipelineStateDescriptor) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.binaryArchives = [binaryArchive]
        descriptor.vertexFunction = makeFunctionWithDescriptor(pipelineStateDescriptor.vertexFunction)
        descriptor.fragmentFunction = makeFunctionWithDescriptor(pipelineStateDescriptor.fragmentFunction)
        return try! device.makeRenderPipelineState(descriptor: descriptor, options: .failOnBinaryArchiveMiss).0
    }
}
