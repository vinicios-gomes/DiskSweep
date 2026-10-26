import Foundation
import Combine

@MainActor
final class AppModel: ObservableObject {
    private let gateway: CleanerGateway
    private let diskInfo: DiskInfoProviding
    private let store: HistoryStoring

    @Published private(set) var disk = DiskStatus()
    @Published private(set) var history: [DiskSample] = []
    @Published private(set) var cleaners: [Cleaner] = []
    @Published private(set) var errorMessage: String?
    @Published var selectedCleaner: Cleaner?
    private var started = false

    init(gateway: CleanerGateway, diskInfo: DiskInfoProviding, store: HistoryStoring) {
        self.gateway = gateway; self.diskInfo = diskInfo; self.store = store
    }

    static func live() -> AppModel {
        AppModel(gateway: ShellCleanerGateway(root: ToolsLocator.root()),
                 diskInfo: FileSystemDiskInfo(), store: JSONHistoryStore())
    }

    var gatewayForSheets: CleanerGateway { gateway }
    var menuBarTitle: String { ByteFormat.bytes(disk.free) }
    var sortedCleaners: [Cleaner] { cleaners.sorted { ($0.kb ?? 0) > ($1.kb ?? 0) } }
    var maxKB: Int { max(1, cleaners.compactMap { $0.kb }.max() ?? 1) }

    func start() {
        guard !started else { return }
        started = true
        history = store.load()
        refreshDisk()
        Task { await reload() }
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                refreshDisk()
            }
        }
    }

    func refreshDisk() {
        disk = diskInfo.status()
        let now = Date()
        if history.last.map({ now.timeIntervalSince($0.date) >= 55 }) ?? true {
            history.append(DiskSample(date: now, used: disk.used))
            history = Array(history.suffix(2880))   // 48h
            store.save(history)
        }
    }

    func reload() async {
        do {
            cleaners = try await gateway.discover()
            errorMessage = nil
            await measureAll()
        } catch { errorMessage = error.localizedDescription }
    }

    func measureAll() async {
        for i in cleaners.indices { cleaners[i].isMeasuring = true }
        let snapshot = cleaners
        await withTaskGroup(of: (String, Int).self) { group in
            var iterator = snapshot.makeIterator()
            func next() { if let c = iterator.next() { group.addTask { (c.id, await self.gateway.sizeKB(of: c)) } } }
            for _ in 0..<4 { next() }                       // no máximo 4 medições simultâneas
            for await (id, kb) in group {
                if let i = cleaners.firstIndex(where: { $0.id == id }) { cleaners[i].kb = kb; cleaners[i].isMeasuring = false }
                next()
            }
        }
    }

    func remeasure(_ id: String) async {
        guard let c = cleaners.first(where: { $0.id == id }) else { return }
        let kb = await gateway.sizeKB(of: c)
        if let i = cleaners.firstIndex(where: { $0.id == id }) { cleaners[i].kb = kb; cleaners[i].isMeasuring = false }
        refreshDisk()
    }
}
