import SwiftUI
import Charts

struct DiskHeaderView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        HStack(alignment: .top, spacing: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Espaço livre").font(.subheadline).foregroundStyle(.secondary)
                Text(ByteFormat.bytes(model.disk.free)).font(.system(size: 38, weight: .semibold, design: .rounded))
                ProgressView(value: model.disk.usedFraction).tint(color)
                Text("\(ByteFormat.bytes(model.disk.used)) usados de \(ByteFormat.bytes(model.disk.total)) · \(Int(model.disk.usedFraction * 100))%")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text("Uso ao longo do tempo").font(.subheadline).foregroundStyle(.secondary)
                if model.history.count > 1 {
                    Chart(model.history) {
                        LineMark(x: .value("Hora", $0.date), y: .value("GB", Double($0.used) / 1e9))
                            .interpolationMethod(.monotone)
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .frame(height: 80)
                } else {
                    Text("Coletando histórico…").foregroundStyle(.tertiary).frame(height: 80)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }

    private var color: Color {
        model.disk.usedFraction > 0.9 ? .red : model.disk.usedFraction > 0.75 ? .orange : .green
    }
}
