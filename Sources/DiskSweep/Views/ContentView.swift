import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 16) {
            DiskHeaderView()
            if let error = model.errorMessage {
                Text(error).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading)
            }
            List(model.sortedCleaners) { cleaner in
                CleanerRowView(cleaner: cleaner, maxKB: model.maxKB) { model.selectedCleaner = cleaner }
            }
            .listStyle(.inset)
        }
        .padding(20)
        .toolbar {
            ToolbarItem {
                Button { Task { model.refreshDisk(); await model.measureAll() } } label: {
                    Label("Recalcular", systemImage: "arrow.clockwise")
                }
            }
        }
        .sheet(item: $model.selectedCleaner) { cleaner in
            PlanSheetView(vm: PlanViewModel(cleaner: cleaner, gateway: model.gatewayForSheets) {
                await model.remeasure(cleaner.id)
            })
        }
    }
}
