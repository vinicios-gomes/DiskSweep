import Foundation

enum GatewayError: LocalizedError {
    case toolsNotFound
    case failed(String)
    var errorDescription: String? {
        switch self {
        case .toolsNotFound: return "Pasta dos cleaners não encontrada (defina DISK_TOOLS_ROOT ou use o app gerado por scripts/build-app.sh)."
        case .failed(let message): return message
        }
    }
}

/// Implementa CleanerGateway falando com os scripts via contrato (name|kind|kb|plan|apply).
struct ShellCleanerGateway: CleanerGateway {
    let root: URL?
    var runner = ShellRunner()

    private func script(_ id: String) throws -> URL {
        guard let root else { throw GatewayError.toolsNotFound }
        return root.appendingPathComponent("cleaners/\(id).sh")
    }

    func discover() async throws -> [Cleaner] {
        guard let root else { throw GatewayError.toolsNotFound }
        let dir = root.appendingPathComponent("cleaners")
        let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
            .filter { $0.hasSuffix(".sh") }.sorted()
        return await withTaskGroup(of: Cleaner?.self) { group in
            for file in files {
                let id = String(file.dropLast(3))
                group.addTask {
                    guard let url = try? script(id) else { return nil }
                    async let name = runner.run(url, ["name"])
                    async let kind = runner.run(url, ["kind"])
                    let (n, k) = await (name, kind)
                    guard n.succeeded, let kindValue = CleanerKind(rawValue: k.output.trimmingCharacters(in: .whitespacesAndNewlines))
                    else { return nil }
                    return Cleaner(id: id, name: n.output.trimmingCharacters(in: .whitespacesAndNewlines), kind: kindValue)
                }
            }
            var result: [Cleaner] = []
            for await cleaner in group { if let cleaner { result.append(cleaner) } }
            return result.sorted { $0.id < $1.id }
        }
    }

    func sizeKB(of cleaner: Cleaner) async -> Int {
        guard let url = try? script(cleaner.id) else { return -1 }
        let result = await runner.run(url, ["kb"])
        return Int(result.output.split(separator: "\n").last.map(String.init) ?? "") ?? -1
    }

    func plan(for cleaner: Cleaner, in directory: String?) async throws -> [PlanItem] {
        let url = try script(cleaner.id)
        let result = await runner.run(url, ["plan"] + (directory.map { [$0] } ?? []))
        guard result.succeeded else { throw GatewayError.failed(result.output.trimmingCharacters(in: .whitespacesAndNewlines)) }
        return result.output.split(separator: "\n").compactMap { line in
            let parts = line.split(separator: "\t", maxSplits: 2, omittingEmptySubsequences: false)
            guard parts.count >= 2, let kb = Int(parts[0]) else { return nil }
            let path = String(parts[1])
            let label = parts.count > 2 ? String(parts[2]) : nil
            var isDir: ObjCBool = false
            let isFileKind = cleaner.kind != .items && cleaner.kind != .cmd
            let exists = isFileKind && FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            return PlanItem(kb: kb, path: path, label: label, isDirectory: exists && isDir.boolValue)
        }
    }

    func apply(_ cleaner: Cleaner, paths: [String]) async -> CommandResult {
        guard let url = try? script(cleaner.id) else { return CommandResult(status: -1, output: GatewayError.toolsNotFound.localizedDescription) }
        return await runner.run(url, ["apply"] + paths)
    }
}
