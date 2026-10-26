import Foundation

/// Porta para os cleaners (shell). A UI depende só deste contrato (DIP).
protocol CleanerGateway {
    func discover() async throws -> [Cleaner]
    func sizeKB(of cleaner: Cleaner) async -> Int
    func plan(for cleaner: Cleaner, in directory: String?) async throws -> [PlanItem]
    func apply(_ cleaner: Cleaner, paths: [String]) async -> CommandResult
}

protocol DiskInfoProviding {
    func status() -> DiskStatus
}

protocol HistoryStoring {
    func load() -> [DiskSample]
    func save(_ samples: [DiskSample])
}
