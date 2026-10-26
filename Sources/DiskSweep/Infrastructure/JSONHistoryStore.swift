import Foundation

struct JSONHistoryStore: HistoryStoring {
    private var url: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("DiskSweep", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("history.json")
    }

    func load() -> [DiskSample] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([DiskSample].self, from: data)) ?? []
    }

    func save(_ samples: [DiskSample]) {
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        try? encoder.encode(samples).write(to: url, options: .atomic)
    }
}
