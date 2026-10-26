import Foundation

enum CleanerKind: String {
    case path, cmd, explore, nm, items

    /// Tudo que lista sub-itens para o usuário marcar; só `cmd` (um comando único) não tem itens.
    var isSelectable: Bool { self != .cmd }
}

struct Cleaner: Identifiable, Hashable {
    let id: String
    let name: String
    let kind: CleanerKind
    var kb: Int?            // nil = medindo; -1 = desconhecido
    var isMeasuring = true
}

struct PlanItem: Identifiable, Hashable {
    var id: String { path }
    let kb: Int
    let path: String            // caminho ou identificador (kind items)
    let label: String?          // nome amigável, quando existir
    let isDirectory: Bool

    var title: String { label ?? path }
}

struct CommandResult {
    let status: Int32
    let output: String
    var succeeded: Bool { status == 0 }
}

struct DiskStatus {
    var total: Int64 = 0
    var used: Int64 = 0
    var free: Int64 { total - used }
    var usedFraction: Double { total > 0 ? Double(used) / Double(total) : 0 }
}

struct DiskSample: Codable, Identifiable {
    var id: Date { date }
    let date: Date
    let used: Int64
}
