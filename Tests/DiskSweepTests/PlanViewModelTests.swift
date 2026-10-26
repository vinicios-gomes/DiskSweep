import XCTest
@testable import DiskSweep

private struct FakeGateway: CleanerGateway {
    var items: [PlanItem]
    func discover() async throws -> [Cleaner] { [] }
    func sizeKB(of cleaner: Cleaner) async -> Int { 0 }
    func plan(for cleaner: Cleaner, in directory: String?) async throws -> [PlanItem] { items }
    func apply(_ cleaner: Cleaner, paths: [String]) async -> CommandResult { CommandResult(status: 0, output: paths.joined(separator: ",")) }
}

@MainActor
final class PlanViewModelTests: XCTestCase {
    private let cleaner = Cleaner(id: "33-simulators", name: "Sims", kind: .items)
    private func makeVM() -> PlanViewModel {
        let items = [PlanItem(kb: 10, path: "A", label: "iPhone", isDirectory: false),
                     PlanItem(kb: 30, path: "B", label: "iPad", isDirectory: false)]
        return PlanViewModel(cleaner: cleaner, gateway: FakeGateway(items: items)) {}
    }

    func testSelectionSumsSizes() async {
        let vm = makeVM(); await vm.load()
        vm.selection = ["A", "B"]
        XCTAssertEqual(vm.selectedKB, 40)
        XCTAssertTrue(vm.canApply)
    }

    func testApplyOnlySendsSelectedPaths() async {
        let vm = makeVM(); await vm.load()
        vm.selection = ["B"]; vm.requestApply(all: false)
        await vm.apply()
        XCTAssertEqual(vm.result?.output, "B")
    }

    func testCannotApplyWithoutSelection() async {
        let vm = makeVM(); await vm.load()
        XCTAssertFalse(vm.canApply)
    }
}
