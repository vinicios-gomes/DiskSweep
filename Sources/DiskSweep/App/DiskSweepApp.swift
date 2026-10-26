import SwiftUI

@main
struct DiskSweepApp: App {
    @StateObject private var model: AppModel

    init() {
        let model = AppModel.live()
        _model = StateObject(wrappedValue: model)
        model.start()
    }

    var body: some Scene {
        Window("DiskSweep", id: "main") {
            ContentView().environmentObject(model).frame(minWidth: 760, minHeight: 600)
        }
        MenuBarExtra {
            MenuBarContent().environmentObject(model)
        } label: {
            Label(model.menuBarTitle, systemImage: "internaldrive")
        }
    }
}

struct MenuBarContent: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text("Livre: \(ByteFormat.bytes(model.disk.free)) de \(ByteFormat.bytes(model.disk.total))")
        Text("Uso: \(Int(model.disk.usedFraction * 100))%")
        Divider()
        Button("Abrir DiskSweep…") { openWindow(id: "main"); NSApp.activate(ignoringOtherApps: true) }
        Divider()
        Button("Sair") { NSApp.terminate(nil) }.keyboardShortcut("q")
    }
}
