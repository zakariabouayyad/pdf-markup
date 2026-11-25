import AppKit
import PDFKit
import Observation
import UniformTypeIdentifiers

@MainActor
@Observable
final class MarkupModel {
    let pdfView: PDFView
    var annotationCount = 0
    var hasDocument = false

    init() {
        pdfView = PDFView()
        pdfView.autoScales = true
    }

    func load(_ url: URL) {
        guard let document = PDFDocument(url: url) else { return }
        pdfView.document = document
        hasDocument = true
        refreshCount()
    }

    func openPDF() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        if panel.runModal() == .OK, let url = panel.url {
            load(url)
        }
    }

    func highlightSelection() {
        guard let selection = pdfView.currentSelection else { return }
        Annotator.highlight(selection)
        pdfView.clearSelection()
        refreshCount()
    }

    func addNote(_ text: String) {
        guard let page = pdfView.currentPage, !text.isEmpty else { return }
        Annotator.addNote(text, on: page, near: pdfView.currentSelection)
        refreshCount()
    }

    func savePDF() {
        guard let document = pdfView.document else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "annotated.pdf"
        if panel.runModal() == .OK, let url = panel.url, !document.write(to: url) {
            NSSound.beep()   // write(to:) returns false when saving fails
        }
    }

    private func refreshCount() {
        guard let document = pdfView.document else { return }
        annotationCount = (0..<document.pageCount)
            .compactMap { document.page(at: $0) }
            .reduce(0) { $0 + $1.annotations.count }
    }
}
