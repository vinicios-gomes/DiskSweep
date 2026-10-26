import Foundation

struct FileSystemDiskInfo: DiskInfoProviding {
    var volume = FileManager.default.fileExists(atPath: "/System/Volumes/Data") ? "/System/Volumes/Data" : "/"

    func status() -> DiskStatus {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: volume),
              let total = (attrs[.systemSize] as? NSNumber)?.int64Value,
              let free = (attrs[.systemFreeSize] as? NSNumber)?.int64Value else { return DiskStatus() }
        return DiskStatus(total: total, used: total - free)
    }
}
