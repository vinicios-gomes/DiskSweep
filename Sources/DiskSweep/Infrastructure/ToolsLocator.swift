import Foundation

/// Encontra a pasta `shell/` (que contém `cleaners/` e `lib/`).
/// Ordem: variável DISK_TOOLS_ROOT → cópia embutida no .app → ./shell (execução a partir da raiz do repositório).
enum ToolsLocator {
    static func root() -> URL? {
        var candidates: [URL] = []
        if let env = ProcessInfo.processInfo.environment["DISK_TOOLS_ROOT"] { candidates.append(URL(fileURLWithPath: env)) }
        if let res = Bundle.main.resourceURL { candidates.append(res.appendingPathComponent("shell")) }
        candidates.append(URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("shell"))
        return candidates.first { FileManager.default.fileExists(atPath: $0.appendingPathComponent("cleaners").path) }
    }
}
