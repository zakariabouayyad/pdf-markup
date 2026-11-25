import XCTest
import PDFKit
@testable import PDFMarkup

final class CubParserTests: XCTestCase {
    let valid = """
    NO ./textures/north.xpm
    SO ./textures/south.xpm
    WE ./textures/west.xpm
    EA ./textures/east.xpm

    F 220,100,0
    C 225,30,0

    1111
    1N01
    1111
    """

    @MainActor
    func testParsesAValidMap() throws {
        let map = try CubParser.parse(valid)
        XCTAssertEqual(map.width, 4)
        XCTAssertEqual(map.height, 3)
        XCTAssertEqual(map.floor, RGB(r: 220, g: 100, b: 0))
        XCTAssertEqual(map.grid[1][1], .player("N"))
        XCTAssertEqual(map.textures["EA"], "./textures/east.xpm")
    }

    @MainActor
    func testRejectsAColorOutOfRange() {
        let bad = valid.replacingOccurrences(of: "F 220,100,0", with: "F 300,100,0")
        XCTAssertThrowsError(try CubParser.parse(bad)) { error in
            XCTAssertEqual(error as? CubParseError, .badColor("300,100,0"))
        }
    }

    @MainActor
    func testRejectsTwoPlayers() {
        let bad = valid.replacingOccurrences(of: "1N01", with: "1NS1")
        XCTAssertThrowsError(try CubParser.parse(bad)) { error in
            XCTAssertEqual(error as? CubParseError, .playerCount(2))
        }
    }

    @MainActor
    func testHandlesWindowsLineEndings() throws {
        let crlf = valid.replacingOccurrences(of: "\n", with: "\r\n")
        XCTAssertEqual(try CubParser.parse(crlf), try CubParser.parse(valid))
    }

    @MainActor
    func testAcceptsTabsAndDoors() throws {
        let tabbed = valid
            .replacingOccurrences(of: "EA ./textures", with: "EA\t./textures")
            .replacingOccurrences(of: "1111\n1N01", with: "1D11\n1N01")
        let map = try CubParser.parse(tabbed)
        XCTAssertEqual(map.textures["EA"], "./textures/east.xpm")
        XCTAssertEqual(map.grid[0][1], .door)
    }
}

final class AnnotatorTests: XCTestCase {
    private func sampleDocument() throws -> PDFDocument {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "sample", withExtension: "pdf"))
        return try XCTUnwrap(PDFDocument(url: url))
    }

    @MainActor
    func testHighlightAddsAnAnnotation() throws {
        let document = try sampleDocument()
        let selection = try XCTUnwrap(document.findString("Hello", withOptions: []).first)
        let page = try XCTUnwrap(selection.pages.first)
        let before = page.annotations.count

        Annotator.highlight(selection)

        XCTAssertEqual(page.annotations.count, before + 1)
        XCTAssertEqual(page.annotations.last?.type, "Highlight")
    }

    @MainActor
    func testNoteSurvivesSaveAndReload() throws {
        let document = try sampleDocument()
        let page = try XCTUnwrap(document.page(at: 0))
        Annotator.addNote("Check this", on: page, near: nil)

        let data = try XCTUnwrap(document.dataRepresentation())
        let reloaded = try XCTUnwrap(PDFDocument(data: data))
        let notes = reloaded.page(at: 0)?.annotations.filter { $0.type == "FreeText" } ?? []

        XCTAssertEqual(notes.first?.contents, "Check this")
    }
}
