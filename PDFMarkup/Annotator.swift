import AppKit
import PDFKit

enum Annotator {
    /// Adds one highlight per line of the selection, so it hugs the text.
    static func highlight(_ selection: PDFSelection, color: NSColor = .systemYellow) {
        for line in selection.selectionsByLine() {
            for page in line.pages {
                let highlight = PDFAnnotation(bounds: line.bounds(for: page),
                                              forType: .highlight,
                                              withProperties: nil)
                highlight.color = color.withAlphaComponent(0.5)
                page.addAnnotation(highlight)
            }
        }
    }

    /// Adds a text box just above the selection, or mid-page when nothing is selected.
    static func addNote(_ text: String, on page: PDFPage, near selection: PDFSelection?) {
        // Page space is in points, with the origin at the bottom-left corner.
        let pageBox = page.bounds(for: .mediaBox)
        var origin = CGPoint(x: pageBox.midX - 100, y: pageBox.midY)
        if let selection, selection.pages.contains(page) {
            let selected = selection.bounds(for: page)
            origin = CGPoint(x: selected.minX, y: selected.maxY + 4)
        }
        let note = PDFAnnotation(bounds: CGRect(origin: origin, size: CGSize(width: 200, height: 40)),
                                 forType: .freeText,
                                 withProperties: nil)
        note.contents = text
        note.font = .systemFont(ofSize: 14)
        note.fontColor = .black
        note.color = NSColor.systemYellow.withAlphaComponent(0.3)
        page.addAnnotation(note)
    }
}
