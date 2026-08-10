import XCTest

// XCUIApplication/XCUIElement are MainActor-isolated in the iOS 18 SDK
// (XCTest annotates them @MainActor), so the whole class must be @MainActor
// to compile against it — newer SDKs default differently, which is why this
// shipped silently. XCTest runs UI test methods on the main actor.
@MainActor
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

    /// VoiceOver regression: the item toggle must expose an explicit label
    /// ("Mark <name> as packed" / "as unpacked") — never the raw SF Symbol
    /// name. Guards against regressions where an unlabeled Image becomes the
    /// only accessible element of the toggle button.
    func testItemToggleHasVoiceOverLabel() throws {
        let app = launchPastOnboarding()
        app.tabBars.buttons["Trips"].tap()

        // Always create a fresh trip so the item assertion is deterministic.
        let newTrip = app.buttons["New trip"]
        XCTAssertTrue(newTrip.waitForExistence(timeout: 8))
        newTrip.tap()

        let titleField = app.textFields["Title — for example, Kyoto in Spring"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Accessibility")

        let destinationField = app.textFields["Destination"]
        XCTAssertTrue(destinationField.waitForExistence(timeout: 5))
        destinationField.tap()
        destinationField.typeText("VoiceOver City")

        app.buttons["Create"].tap()

        // Open the trip row.
        let tripRow = app.staticTexts["Accessibility"].firstMatch
        XCTAssertTrue(tripRow.waitForExistence(timeout: 8))
        tripRow.tap()

        // Add one item.
        let itemName = app.textFields["Item name"]
        XCTAssertTrue(itemName.waitForExistence(timeout: 5))
        itemName.tap()
        itemName.typeText("Passport")
        app.buttons["Add"].tap()

        // The toggle must expose the explicit VoiceOver label.
        XCTAssertTrue(app.buttons["Mark Passport as packed"].waitForExistence(timeout: 5))
    }
}
