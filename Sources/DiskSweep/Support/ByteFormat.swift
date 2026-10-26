import Foundation

enum ByteFormat {
    static func bytes(_ value: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: value, countStyle: .file)
    }
    static func kb(_ value: Int) -> String {
        value < 0 ? "—" : ByteCountFormatter.string(fromByteCount: Int64(value) * 1024, countStyle: .file)
    }
}
