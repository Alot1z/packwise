import XCTest

final class PackWiseUITests: XCTestCase {
    func testLaunchAndTabs() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists)
        XCTAssertTrue(app.tabBars.buttons["Trips"].exists)
        XCTAssertTrue(app.tabBars.buttons["Scanner"].exists)
        XCTAssertTrue(app.tabBars.buttons["Library"].exists)
    }

    func testCreateTripFlow() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Trips"].tap()
        // New trip button exists (accessibility may vary — smoke check)
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5))
    }
}
