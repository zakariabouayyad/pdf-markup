import Cocoa
import Quartz
import SwiftUI

class PreviewViewController: NSViewController, QLPreviewingController {

    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    func preparePreviewOfFile(at url: URL) async throws {
        let text = try String(contentsOf: url, encoding: .utf8)
        let map = try CubParser.parse(text)

        let hostingView = NSHostingView(rootView: CubMapView(map: map))
        hostingView.frame = view.bounds
        hostingView.autoresizingMask = [.width, .height]
        view.addSubview(hostingView)
        preferredContentSize = NSSize(width: 640, height: 480)
    }
}
