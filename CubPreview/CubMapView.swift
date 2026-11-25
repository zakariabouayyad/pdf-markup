import SwiftUI

struct CubMapView: View {
    let map: CubMap

    var body: some View {
        Canvas { context, size in
            // Whole-point cell size and origin, so tile edges never fall between pixels.
            let cell = max(1, floor(min(size.width / CGFloat(map.width), size.height / CGFloat(map.height))))
            let originX = floor((size.width - cell * CGFloat(map.width)) / 2)
            let originY = floor((size.height - cell * CGFloat(map.height)) / 2)

            // One path per tile type: 4 fills instead of one per tile, and no seams.
            var walls = Path(), floors = Path(), doors = Path(), players = Path()
            for (y, row) in map.grid.enumerated() {
                for (x, tile) in row.enumerated() {
                    let rect = CGRect(x: originX + CGFloat(x) * cell,
                                      y: originY + CGFloat(y) * cell,
                                      width: cell, height: cell)
                    switch tile {
                    case .wall: walls.addRect(rect)
                    case .floor: floors.addRect(rect)
                    case .door: doors.addRect(rect)
                    case .player:
                        floors.addRect(rect)
                        players.addEllipse(in: rect.insetBy(dx: cell / 4, dy: cell / 4))
                    case .empty: break
                    }
                }
            }
            context.fill(walls, with: .color(.primary))
            context.fill(floors, with: .color(map.floor.color))
            context.fill(doors, with: .color(.orange))
            context.fill(players, with: .color(.red))
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
