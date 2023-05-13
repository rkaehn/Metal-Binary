import Foundation

enum PipelineScript {
    struct Path: Codable {
        let label: String
        let path: String
    }
    struct Payload: Codable {
        let data: Int
    }
    struct ConstantValue: Codable {
        var idType: String = "FunctionConstantIndex"
        let id: Payload
        var valueType: String = "ConstantUChar"
        let value: Payload
    }
    struct SpecializedFunction: Codable {
        let label: String
        let function: String
        let specializedName: String
        let constantValues: [ConstantValue]
    }
    struct Libraries: Codable {
        let paths: [Path]
        let specializedFunctions: [SpecializedFunction]
    }
    struct RenderPipeline: Codable {
        let vertexFunction: String
        let fragmentFunction: String
    }
    struct Pipelines: Codable {
        let renderPipelines: [RenderPipeline]
    }
    struct Script: Codable {
        let libraries: Libraries
        let pipelines: Pipelines
    }
}

@main
struct Main {
    static func main() {
        let envDerivedFileDir = ProcessInfo.processInfo.environment["DERIVED_FILE_DIR"]!
        
        var specializedFunctions: [PipelineScript.SpecializedFunction] = []
        var renderPipelines: [PipelineScript.RenderPipeline] = []
        
        let handleFunction: ((FunctionDescriptor) -> String) = { function in
            let functionName: String
            switch function.kind {
            case .basic:
                functionName = function.name
            case let .specialized(specializedName, functionConstants):
                let libName = "lib_\(specializedFunctions.count)"
                functionName = "alias:\(libName)#\(specializedName)"
                
                var constantValues: [PipelineScript.ConstantValue] = []
                for functionConstant in functionConstants {
                    let idPayload = PipelineScript.Payload(data: functionConstant.index)
                    let valuePayload: PipelineScript.Payload
                    switch functionConstant.payload {
                    case let .uchar(value):
                        valuePayload = .init(data: Int(value))
                    }
                    constantValues.append(.init(id: idPayload, value: valuePayload))
                }
                let specializedFunction = PipelineScript.SpecializedFunction(
                    label: libName,
                    function: function.name,
                    specializedName: specializedName,
                    constantValues: constantValues)
                specializedFunctions.append(specializedFunction)
            }
            return functionName
        }
        
        for recipe in PipelineStateRecipe.allCases {
            withPipelineStateDescriptor(recipe: recipe) { pipelineStateDescriptor in
                let renderPipeline = PipelineScript.RenderPipeline(
                    vertexFunction: handleFunction(pipelineStateDescriptor.vertexFunction),
                    fragmentFunction: handleFunction(pipelineStateDescriptor.fragmentFunction))
                renderPipelines.append(renderPipeline)
            }
        }
        
        let script = PipelineScript.Script(
            libraries: PipelineScript.Libraries(
                paths: [
                    PipelineScript.Path(label: "main", path: envDerivedFileDir + "/main.metallib")
                ],
                specializedFunctions: specializedFunctions),
            pipelines: PipelineScript.Pipelines(renderPipelines: renderPipelines))
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let outputData = try! encoder.encode(script)
        
        let outputURL = URL(fileURLWithPath: envDerivedFileDir + "/main.mtlp-json")
        try! outputData.write(to: outputURL)
        
        let output = String(data: outputData, encoding: .utf8)!
        print(output)
    }
}
