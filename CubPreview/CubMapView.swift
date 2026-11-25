import SwiftUI

struct CubMapView: View {
    let map: CubMap

    var body: some View {
        Canvas { context, size in
            let cell = min(size.width / CGFloat(map.width), size.height / CGFloat(map.height))
            let originX = (size.width - cell * CGFloat(map.width)) / 2
            let originY = (size.height - cell * CGFloat(map.height)) / 2

            for (y, row) in map.grid.enumerated() {
                for (x, tile) in row.enumerated() {
                    let rect = CGRect(x: originX + CGFloat(x) * cell,
                                      y: originY + CGFloat(y) * cell,
                                      width: cell, height: cell)
                    switch tile {
                    case .wall:
                        context.fill(Path(rect), with: .color(.primary))
                    case .floor:
                        context.fill(Path(rect), with: .color(map.floor.color))
                    case .player:
                        context.fill(Path(rect), with: .color(map.floor.color))
                        context.fill(Path(ellipseIn: rect.insetBy(dx: cell / 4, dy: cell / 4)),
                                     with: .color(.red))
                    case .door:
                        context.fill(Path(rect), with: .color(.orange))
                    case .empty:
                        break
                    }
                }
            }
        }
        .padding()
        .background(map.ceiling.color.opacity(0.15))
        .accessibilityElement()
        .accessibilityLabel("cub3D map, \(map.width) by \(map.height) tiles")
    }
}

extension RGB {
    var color: Color {
        Color(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

private let sampleMap = """
F 220,100,0
C 225,30,0
111111
1000N1
111111
"""

#Preview {
    CubMapView(map: try! CubParser.parse(sampleMap))
        .frame(width: 400, height: 200)
}
