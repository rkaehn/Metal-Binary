import Foundation

enum SourceSpecialization {
    case none
    case header
    case body
}

@discardableResult
func shell(_ command: String) throws -> String {
    print("Executing: \"\(command)\"")
    
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c"] + [command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil
    
    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}

@main
struct metal_gen {
    static func main() {
        let inputPath = CommandLine.arguments[1]
        let inputBaseName = ((inputPath as NSString).lastPathComponent as NSString).deletingPathExtension
        let inputDir = (inputPath as NSString).deletingLastPathComponent
        
        var descriptors: [FunctionDescriptor] = []
        for recipe in PipelineStateRecipe.allCases {
            withPipelineStateDescriptor(recipe: recipe) {
                if $0.vertexFunction.name == inputBaseName {
                    descriptors.append($0.vertexFunction)
                }
                if $0.fragmentFunction.name == inputBaseName {
                    descriptors.append($0.fragmentFunction)
                }
            }
        }
        
        let source = try! String(contentsOfFile: inputPath, encoding: .utf8)
        
        var combinedSource = ""
        func appendSource(specialization: SourceSpecialization, replacements: [String: String] = [:]) {
            var result: String
            switch specialization {
            case .none:
                result = source
            case .header:
                let startIndex = source.firstRange(of: "// CODE_GEN_HEADER_BEGIN")!.upperBound
                let endIndex = source.firstRange(of: "// CODE_GEN_HEADER_END")!.lowerBound
                result = String(source[startIndex..<endIndex])
            case .body:
                let startIndex = source.firstRange(of: "// CODE_GEN_BODY_BEGIN")!.upperBound
                let endIndex = source.firstRange(of: "// CODE_GEN_BODY_END")!.lowerBound
                result = String(source[startIndex..<endIndex])
            }
            for replacement in replacements {
                result.replace(replacement.key, with: replacement.value)
            }
            combinedSource.append(result)
        }
        
        switch descriptors[0].kind {
        case .basic:
            appendSource(specialization: .none)
        case .specialized:
            appendSource(specialization: .header)
            for descriptor in descriptors {
                guard case let .specialized(specializedName, constants) = descriptor.kind else { fatalError() }
                var replacements = [
                    descriptor.name: specializedName
                ]
                for constant in constants {
                    let valueString: String
                    switch constant.payload {
                    case let .uchar(value):
                        valueString = value.description
                    }
                    replacements[constant.name] = valueString
                }
                appendSource(specialization: .body, replacements: replacements)
            }
        }
        
        let tempPath = "\(inputBaseName).metal"
        try! combinedSource.write(toFile: tempPath, atomically: false, encoding: .utf8)
        
        let metalArguments = CommandLine.arguments[2...].joined(separator: " ")
        try! shell("metal -I\"\(inputDir)\" -c \(tempPath) -o \(inputBaseName).air \(metalArguments)")
    }
}
