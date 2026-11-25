import SwiftUI

struct ContentView: View {
    @State private var model = MarkupModel()
    @State private var showingNoteSheet = false
    @State private var noteText = ""

    var body: some View {
        VStack(spacing: 0) {
            PDFKitView(pdfView: model.pdfView)
            Divider()
            HStack {
                Text("Annotations: \(model.annotationCount)")
                    .accessibilityIdentifier("annotationCount")
                Spacer()
            }
            .padding(8)
        }
        .frame(minWidth: 640, minHeight: 480)
        .toolbar {
            Button { model.openPDF() } label: {
                Label("Open", systemImage: "folder")
            }
            .help("Open a PDF")

            Button { model.highlightSelection() } label: {
                Label("Highlight", systemImage: "highlighter")
            }
            .help("Highlight the selected text")
            .disabled(!model.hasDocument)

            Button { showingNoteSheet = true } label: {
                Label("Add Note", systemImage: "note.text.badge.plus")
            }
            .help("Add a text note to this page")
            .disabled(!model.hasDocument)

            Button { model.savePDF() } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .help("Save a copy with your annotations")
            .disabled(!model.hasDocument)
        }
        .sheet(isPresented: $showingNoteSheet) {
            VStack(alignment: .leading, spacing: 12) {
                Text("New note")
                    .font(.headline)
                TextField("Note", text: $noteText)
                    .accessibilityIdentifier("noteField")
                HStack {
                    Spacer()
                    Button("Cancel") { showingNoteSheet = false }
                        .keyboardShortcut(.cancelAction)
                    Button("Add") {
                        model.addNote(noteText)
                        noteText = ""
                        showingNoteSheet = false
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
            .frame(width: 320)
        }
        .onAppear {
            // The UI test launches the app with -uiTesting to load a known PDF.
            if CommandLine.arguments.contains("-uiTesting"),
               let url = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
                model.load(url)
            }
        }
    }
}
