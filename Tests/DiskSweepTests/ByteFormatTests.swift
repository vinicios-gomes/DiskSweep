import XCTest
@testable import DiskSweep

final class ByteFormatTests: XCTestCase {
    func testUnknownSizeShowsDash() { XCTAssertEqual(ByteFormat.kb(-1), "—") }
    func testKilobytesAreFormatted() { XCTAssertFalse(ByteFormat.kb(2048).isEmpty) }
}
