# PDFMarkup

A macOS app for marking up PDFs, plus a Quick Look extension that previews my cub3D map files in Finder.

## Features

- **PDF markup:** open a PDF, highlight selected text and add text notes.
- **Real annotations:** saving writes them into the PDF, so they show up in Preview and other PDF readers.
- **Quick Look preview:** select a `.cub` map in Finder and press Space to see it drawn: walls, floor, doors and the player's start.

## How it's built

- **SwiftUI and AppKit:** the window and toolbar are SwiftUI. PDFKit's `PDFView` is an AppKit view, wrapped with `NSViewRepresentable`.
- **PDFKit:** a highlight is one `.highlight` annotation per line of the selection, so it follows the text. A note is a `.freeText` annotation placed just above the selection (PDF page coordinates start at the bottom-left).
- **Quick Look:** `CubPreview` is a preview extension built on `QLPreviewingController`. The app declares a `com.zakariabouayyad.cub-map` type for `.cub` files; the extension registers for that type, parses the file and draws the map with a SwiftUI `Canvas` inside an `NSHostingView`.
- **Parser:** reads the textures, the floor and ceiling colors and the map grid, and throws a specific error for a bad color, a missing color, an unknown character or a wrong number of players.

## Tests

- **7 unit tests (XCTest):** the parser (valid map, color out of range, two players, Windows line endings, tabs and doors) and the annotations (a highlight is added, a note survives saving and reloading).
- **1 UI test (XCUITest):** launches the app with a sample PDF, adds a note through the interface and checks the annotation counter.

Run them in Xcode with Cmd+U.

## Run it

1. Open `PDFMarkup.xcodeproj` in Xcode and press Cmd+R.
2. Select a `.cub` file in Finder and press Space. Sample maps are in my [cub3D repo](https://github.com/zakariabouayyad/cube3d/tree/main/bonus/maps). If no preview appears, run `qlmanage -r` in Terminal and try again.

Requires macOS 14 or later. Built with Xcode 27.
