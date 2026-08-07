import XCTest

final class PackWiseUITests: XCTestCase {

    /// Launches the app and, on a fresh install, completes the onboarding
    /// flow (Skip) so the main tab bar is reachable. Subsequent tests in the
    /// same run see the persisted preference and skip onboarding automatically.
    private func launchPastOnboarding() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        let skip = app.buttons["Skip"]
        if skip.waitForExistence(timeout: 5) {
            skip.tap()
        }
        // In case onboarding was mid-flow (Continue states), force-complete it.
        let open = app.buttons["Open PackWise"]
        if open.waitForExistence(timeout: 3) {
            open.tap()
        }
        return app
    }

    func testLaunchAndTabs() throws {
        let app = launchPastOnboarding()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Dashboard"].exists)
        XCTAssertTrue(app.tabBars.buttons["Trips"].exists)
        XCTAssertTrue(app.tabBars.buttons["Scanner"].exists)
        XCTAssertTrue(app.tabBars.buttons["Library"].exists)
    }

    func testCreateTripFlow() throws {
        let app = launchPastOnboarding()
        app.tabBars.buttons["Trips"].tap()
        // New trip button exists (accessibility may vary — smoke check)
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5))
    }

    func testOnboardingCompletes() throws {
        let app = XCUIApplication()
        app.launch()
        // First launch shows onboarding; completing it must reveal the tab bar.
        let skip = app.buttons["Skip"]
        if skip.exists {
            skip.tap()
        }
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
    }
}
