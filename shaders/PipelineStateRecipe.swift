import Foundation

public struct FunctionConstant {
    public enum Payload {
        case uchar(UInt8)
    }
    let payload: Payload
    let index: Int
    
    public init(payload: Payload, index: Int) {
        self.payload = payload
        self.index = index
    }
}

public struct FunctionDescriptor {
    public enum FunctionKind {
        case basic
        case specialized(String, [FunctionConstant])
    }
    let name: String
    let kind: FunctionKind
    
    public init(name: String, kind: FunctionKind = .basic) {
        self.name = name
        self.kind = kind
    }
}

public struct PipelineStateDescriptor {
    public let vertexFunction: FunctionDescriptor
    public let fragmentFunction: FunctionDescriptor
    
    public init(vertexFunction: FunctionDescriptor, fragmentFunction: FunctionDescriptor) {
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
    }
}

public enum PipelineStateRecipe: CaseIterable {
    public typealias Handler = (PipelineStateDescriptor) -> ()
    
    case main
    
    func execute(_ handler: Handler) {
        switch self {
        case .main:
#if DEBUG
            return Self.mainDebugExecute(handler)
#else
            return Self.mainReleaseExecute(handler)
#endif
        }
    }
    
    private static func mainDebugExecute(_ handler: Handler) {
        let descriptor = PipelineStateDescriptor(
            vertexFunction: FunctionDescriptor(
                name: "main_vertex"),
            fragmentFunction: FunctionDescriptor(
                name: "main_fragment"))
        handler(descriptor)
    }
    
    private static func mainReleaseExecute(_ handler: Handler) {
        let constant = FunctionConstant(payload: .uchar(16), index: 0)
        let descriptor = PipelineStateDescriptor(
            vertexFunction: FunctionDescriptor(
                name: "main_vertex"),
            fragmentFunction: FunctionDescriptor(
                name: "main_fragment",
                kind: .specialized("main_fragment_0", [constant])))
        handler(descriptor)
    }
}

public func withPipelineStateDescriptor(
    recipe: PipelineStateRecipe,
    _ handler: PipelineStateRecipe.Handler) {
        recipe.execute(handler)
    }
