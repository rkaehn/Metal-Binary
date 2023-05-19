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
struct air_gen {
    static func main() {
        let envDerivedFileDir = ProcessInfo.processInfo.environment["DERIVED_FILE_DIR"]!
        
        let inputPath = CommandLine.arguments[1]
        let inputBaseName = ((inputPath as NSString).lastPathComponent as NSString).deletingPathExtension
        
        try! shell("metal -c \(inputPath) -D\"main_fragment=main_fragment_0\" -D\"testConstant=16\" -o \(envDerivedFileDir)/\(inputBaseName).air \(CommandLine.arguments[2...].joined(separator: " "))")
    }
}
