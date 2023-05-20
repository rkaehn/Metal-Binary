import Foundation

func shell(_ command: String) throws {
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

    print(output)
}

@main
struct metal_gen {
    static func main() {
        let inputPath = CommandLine.arguments[1]
        let inputBaseName = ((inputPath as NSString).lastPathComponent as NSString).deletingPathExtension
        
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
        
        let commonArguments = CommandLine.arguments[2...].joined(separator: " ")

        for descriptor in descriptors {
            let outputName: String
            var arguments = commonArguments
            switch descriptor.kind {
            case .basic:
                outputName = descriptor.name
            case let .specialized(specializedName, constants):
                outputName = specializedName
                arguments += " -D\"\(descriptor.name)=\(specializedName)\""
                for constant in constants {
                    let valueString: String
                    switch constant.payload {
                    case let .uchar(value):
                        valueString = value.description
                    }
                    arguments += " -D\"\(constant.name)=\(valueString)\""
                }
            }
            try! shell("metal -c \(inputPath) \(arguments) -o \(outputName).air")
        }
        
        let placeholderPath = "\(inputBaseName).air-placeholder"
        try! "".write(toFile: placeholderPath, atomically: false, encoding: .utf8)
    }
}
