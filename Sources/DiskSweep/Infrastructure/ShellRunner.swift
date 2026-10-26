import Foundation

/// Executa um programa e devolve status + saída. Única responsabilidade: processos.
struct ShellRunner {
    /// Apps de GUI herdam um PATH mínimo; completamos com os locais usuais de docker, brew, npm e nvm.
    static var environment: [String: String] {
        var env = ProcessInfo.processInfo.environment
        let home = NSHomeDirectory()
        var extra = ["/opt/homebrew/bin", "/usr/local/bin", "\(home)/.docker/bin",
                     "/Applications/Docker.app/Contents/Resources/bin"]
        let nvm = "\(home)/.nvm/versions/node"
        if let versions = try? FileManager.default.contentsOfDirectory(atPath: nvm).sorted() {
            extra += versions.reversed().map { "\(nvm)/\($0)/bin" }
        }
        env["PATH"] = (extra + ["/usr/bin", "/bin", "/usr/sbin", "/sbin"]).joined(separator: ":")
        return env
    }

    func run(_ executable: URL, _ arguments: [String]) async -> CommandResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let process = Process()
                let pipe = Pipe()
                process.executableURL = executable
                process.arguments = arguments
                process.environment = Self.environment
                process.standardOutput = pipe
                process.standardError = pipe
                process.standardInput = FileHandle.nullDevice
                do { try process.run() } catch {
                    continuation.resume(returning: CommandResult(status: -1, output: "\(error)"))
                    return
                }
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                let text = String(decoding: data, as: UTF8.self)
                    .replacingOccurrences(of: "\u{1B}\\[[0-9;]*m", with: "", options: .regularExpression)
                continuation.resume(returning: CommandResult(status: process.terminationStatus, output: text))
            }
        }
    }
}
