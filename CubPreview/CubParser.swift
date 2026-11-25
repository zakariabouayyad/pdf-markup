import Foundation

struct RGB: Equatable {
    let r: Int, g: Int, b: Int
}

enum Tile: Equatable {
    case wall, floor, empty, door
    case player(Character)   // N, S, E or W: the starting direction
}

struct CubMap: Equatable {
    var textures: [String: String]   // "NO" -> "./textures/north.xpm"
    var floor: RGB
    var ceiling: RGB
    var grid: [[Tile]]

    var width: Int { grid.map(\.count).max() ?? 0 }
    var height: Int { grid.count }
}

enum CubParseError: Error, Equatable {
    case missingColor(String)
    case badColor(String)
    case noMap
    case invalidCharacter(Character)
    case playerCount(Int)
}

enum CubParser {
    static func parse(_ text: String) throws -> CubMap {
        var textures: [String: String] = [:]
        var colors: [String: RGB] = [:]
        var mapLines: [String] = []

        // \.isNewline also splits Windows line endings (\r\n) correctly.
        for rawLine in text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline) {
            let line = String(rawLine)
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if mapLines.isEmpty {
                if trimmed.isEmpty { continue }
                let parts = trimmed.split(maxSplits: 1, whereSeparator: \.isWhitespace).map(String.init)
                let value = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : ""
                switch parts[0] {
                case "NO", "SO", "WE", "EA":
                    textures[parts[0]] = value
                case "F", "C":
                    colors[parts[0]] = try parseColor(value)
                default:
                    mapLines.append(line)   // first map line: keep its leading spaces
                }
            } else if trimmed.isEmpty {
                break                       // the map ends at the first blank line
            } else {
                mapLines.append(line)
            }
        }

        guard let floor = colors["F"] else { throw CubParseError.missingColor("F") }
        guard let ceiling = colors["C"] else { throw CubParseError.missingColor("C") }
        guard !mapLines.isEmpty else { throw CubParseError.noMap }

        let grid = try mapLines.map { line in try line.map { try tile($0) } }
        let players = grid.joined().filter {
            if case .player = $0 { return true } else { return false }
        }
        guard players.count == 1 else { throw CubParseError.playerCount(players.count) }

        return CubMap(textures: textures, floor: floor, ceiling: ceiling, grid: grid)
    }

    static func parseColor(_ text: String) throws -> RGB {
        let parts = text.split(separator: ",").map { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count == 3,
              let r = parts[0], let g = parts[1], let b = parts[2],
              [r, g, b].allSatisfy({ (0...255).contains($0) })
        else { throw CubParseError.badColor(text) }
        return RGB(r: r, g: g, b: b)
    }

    static func tile(_ c: Character) throws -> Tile {
        switch c {
        case "1": return .wall
        case "0": return .floor
        case " ": return .empty
        case "D": return .door        // doors from the bonus part
        case "N", "S", "E", "W": return .player(c)
        default: throw CubParseError.invalidCharacter(c)
        }
    }
}
