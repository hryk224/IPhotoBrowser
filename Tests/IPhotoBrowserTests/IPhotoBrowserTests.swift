import XCTest
@testable import IPhotoBrowser

class IPhotoBrowserTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(IPhotoBrowser().text, "Hello, World!")
    }


    static var allTests : [(String, (IPhotoBrowserTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
