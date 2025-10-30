
import Foundation

enum Difficulty: Int, Codable, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3
    case expert = 4
    case master = 5
    
    var xpMultiplier: Double {
        switch self {
        case .easy:
            return 1.0
        case .medium:
            return 1.5
        case .hard:
            return 2.0
        case .expert:
            return 2.5
        case .master:
            return 3.0
        }
    }
}

extension Difficulty: CustomStringConvertible {
    var description: String {
        switch self {
        case .easy:
            return "easy"
        case .medium:
            return "medium"
        case .hard:
            return "hard"
        case .expert:
            return "expert"
        case .master:
            return "master"
        }
    }
}
