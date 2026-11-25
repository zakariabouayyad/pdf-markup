import XCTest

final class PDFMarkupUITests: XCTestCase {
    @MainActor
    func testAddingANoteUpdatesTheCounter() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        let counter = app.staticTexts["annotationCount"]
        XCTAssertTrue(counter.waitForExistence(timeout: 5))

        app.buttons["Add Note"].click()
        let field = app.textFields["noteField"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.click()
        field.typeText("Hello")
        app.buttons["Add"].click()

        let updated = expectation(for: NSPredicate(format: "value == %@", "Annotations: 1"),
                                  evaluatedWith: counter)
        wait(for: [updated], timeout: 3)
    }
}
