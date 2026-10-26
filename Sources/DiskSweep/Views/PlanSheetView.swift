import SwiftUI

struct PlanSheetView: View {
    @StateObject var vm: PlanViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(vm.cleaner.name).font(.title3.bold())
            Text(subtitle).font(.callout).foregroundStyle(.secondary).lineLimit(2)

            if vm.isLoading {
                ProgressView("Carregando…").frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = vm.error {
                Text(error).foregroundStyle(.red).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let result = vm.result {
                ScrollView { Text((result.succeeded ? "Concluído.\n" : "Terminou com erro.\n") + result.output)
                    .font(.system(.callout, design: .monospaced)).textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading) }
                    .padding(8).background(.background.secondary, in: RoundedRectangle(cornerRadius: 8))
            } else if vm.items.isEmpty {
                Text("Nada encontrado.").foregroundStyle(.secondary).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.items, selection: $vm.selection) { item in
                    HStack {
                        Image(systemName: icon(for: item)).foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.title).lineLimit(1).truncationMode(.middle)
                            if item.label != nil { Text(item.path).font(.caption2).foregroundStyle(.tertiary).lineLimit(1) }
                        }
                        Spacer()
                        Text(ByteFormat.kb(item.kb)).foregroundStyle(.secondary).monospacedDigit()
                        if item.isDirectory {
                            Button { Task { await vm.open(item) } } label: { Image(systemName: "chevron.right.circle") }
                                .buttonStyle(.borderless).help("Abrir pasta")
                        }
                    }
                    .tag(item.path)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) { if item.isDirectory { Task { await vm.open(item) } } }
                }
                .listStyle(.inset)
                .disabled(!vm.isSelectable)
            }

            HStack {
                if vm.canGoBack && vm.result == nil { Button("‹ Voltar") { Task { await vm.back() } } }
                if vm.isSelectable && !vm.selection.isEmpty {
                    Text("\(vm.selection.count) selecionado(s) · \(ByteFormat.kb(vm.selectedKB))").foregroundStyle(.secondary)
                }
                Spacer()
                Button(vm.result == nil ? "Cancelar" : "Fechar") { dismiss() }.keyboardShortcut(.cancelAction)
                if vm.result != nil {
                    if vm.isSelectable { Button("Continuar navegando") { Task { await vm.continueBrowsing() } } }
                } else if vm.isSelectable {
                    if vm.canApplyAll { Button("Apagar tudo", role: .destructive) { vm.requestApply(all: true) } }
                    Button("Apagar selecionados", role: .destructive) { vm.requestApply(all: false) }
                        .disabled(!vm.canApply)
                } else {
                    Button(actionTitle, role: .destructive) { vm.requestApply(all: true) }.disabled(!vm.canApply)
                }
            }
        }
        .padding(20)
        .frame(minWidth: 680, minHeight: 460)
        .disabled(vm.isApplying)
        .overlay { if vm.isApplying { applyingOverlay } }
        .task { await vm.load() }
        .confirmationDialog(confirmTitle, isPresented: $vm.confirming, titleVisibility: .visible) {
            Button(vm.applyingAll ? "Confirmar" : "Apagar", role: .destructive) { Task { await vm.apply() } }
            Button("Cancelar", role: .cancel) {}
        } message: { Text("Esta ação não pode ser desfeita.") }
    }

    private var applyingOverlay: some View {
        ZStack {
            Rectangle().fill(.regularMaterial)
            VStack(spacing: 12) {
                ProgressView().controlSize(.large)
                Text(vm.cleaner.kind == .cmd ? "Executando…" : "Apagando…").font(.headline)
                Text("Isso pode levar alguns minutos. Não feche o app.").font(.callout).foregroundStyle(.secondary)
            }
        }
    }

    private var subtitle: String {
        vm.isSelectable ? (vm.currentDirectory ?? "Selecione o que deseja apagar (duplo clique abre pastas). Nada é apagado sem confirmação.")
                        : "Será executado ao confirmar:"
    }
    private var actionTitle: String { vm.cleaner.kind == .cmd ? "Executar" : "Apagar" }
    private var confirmTitle: String {
        vm.applyingAll ? "\(actionTitle): \(vm.cleaner.name)?" : "Apagar \(vm.selection.count) item(ns)?"
    }
    private func icon(for item: PlanItem) -> String {
        vm.cleaner.kind == .items ? "cube" : (item.isDirectory ? "folder" : "doc")
    }
}
