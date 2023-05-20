import Foundation

enum PipelineScript {
    struct Path: Codable {
        let label: String
        let path: String
    }
    struct Libraries: Codable {
        let paths: [Path]
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
struct mtlp_json_gen {
    static func main() {
        var renderPipelines: [PipelineScript.RenderPipeline] = []
        
        let handleFunction: ((FunctionDescriptor) -> String) = { function in
            let functionName: String
            switch function.kind {
            case .basic:
                functionName = function.name
            case let .specialized(specializedName, _):
                functionName = specializedName
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
                    PipelineScript.Path(label: "main", path: "main.metallib")
                ]),
            pipelines: PipelineScript.Pipelines(renderPipelines: renderPipelines))
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let outputData = try! encoder.encode(script)
        
        let outputURL = URL(fileURLWithPath: "main.mtlp-json")
        try! outputData.write(to: outputURL)
        
        let output = String(data: outputData, encoding: .utf8)!
        print(output)
    }
}
