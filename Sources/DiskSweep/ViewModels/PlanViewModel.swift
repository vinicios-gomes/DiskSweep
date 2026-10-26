import Foundation
import Combine

@MainActor
final class PlanViewModel: ObservableObject {
    let cleaner: Cleaner
    private let gateway: CleanerGateway
    private let onApplied: () async -> Void

    @Published private(set) var items: [PlanItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isApplying = false
    @Published private(set) var error: String?
    @Published private(set) var result: CommandResult?
    @Published private(set) var directoryStack: [String?] = []
    @Published private(set) var currentDirectory: String?
    @Published var selection = Set<String>()
    @Published var confirming = false
    private(set) var applyingAll = false

    init(cleaner: Cleaner, gateway: CleanerGateway, onApplied: @escaping () async -> Void) {
        self.cleaner = cleaner; self.gateway = gateway; self.onApplied = onApplied
    }

    var isSelectable: Bool { cleaner.kind.isSelectable }
    var canGoBack: Bool { !directoryStack.isEmpty }
    var selectedKB: Int { items.filter { selection.contains($0.path) }.reduce(0) { $0 + max(0, $1.kb) } }
    var canApply: Bool { !isApplying && result == nil && (isSelectable ? !selection.isEmpty : !items.isEmpty) }
    /// "Apagar tudo" só para itens de caminho, na raiz (sem ter entrado em subpastas).
    var canApplyAll: Bool { cleaner.kind == .path && currentDirectory == nil && !items.isEmpty && !isApplying && result == nil }

    func load(directory: String? = nil) async {
        isLoading = true; error = nil; selection = []
        defer { isLoading = false }
        do { items = try await gateway.plan(for: cleaner, in: directory); currentDirectory = directory }
        catch { items = []; self.error = error.localizedDescription }
    }

    func open(_ item: PlanItem) async { directoryStack.append(currentDirectory); await load(directory: item.path) }
    func back() async { guard let previous = directoryStack.popLast() else { return }; await load(directory: previous) }

    func requestApply(all: Bool) { applyingAll = all || !isSelectable; confirming = true }

    func continueBrowsing() async { result = nil; await load(directory: currentDirectory) }

    func apply() async {
        isApplying = true
        let paths = applyingAll ? [] : Array(selection)
        result = await gateway.apply(cleaner, paths: paths)
        isApplying = false
        await onApplied()
    }
}
