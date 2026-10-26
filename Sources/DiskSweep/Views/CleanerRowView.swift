import SwiftUI

struct CleanerRowView: View {
    let cleaner: Cleaner
    let maxKB: Int
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 24).foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(cleaner.name)
                Text(cleaner.id).font(.caption).foregroundStyle(.tertiary)
            }
            Spacer()
            ProgressView(value: Double(max(0, cleaner.kb ?? 0)), total: Double(maxKB))
                .frame(width: 100).opacity(cleaner.isMeasuring ? 0.3 : 1)
            Group {
                if cleaner.isMeasuring { ProgressView().controlSize(.small) }
                else { Text(ByteFormat.kb(cleaner.kb ?? -1)).monospacedDigit() }
            }
            .frame(width: 80, alignment: .trailing)
            Button(cleaner.kind.isSelectable ? "Explorar…" : "Limpar…", action: action)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }

    private var icon: String {
        switch cleaner.kind {
        case .path: "trash"
        case .cmd: "terminal"
        case .explore: "folder.badge.gearshape"
        case .nm: "shippingbox"
        case .items: "list.bullet.rectangle"
        }
    }
}
