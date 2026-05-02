import Foundation

enum BPMRange: String, CaseIterable, Identifiable {
    case slow = "40–80"
    case mid = "80–120"
    case fast = "120–160"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .slow: return "SLOW"
        case .mid: return "MID"
        case .fast: return "FAST"
        }
    }

    var min: Int {
        switch self {
        case .slow: return 40
        case .mid: return 80
        case .fast: return 120
        }
    }

    var max: Int {
        switch self {
        case .slow: return 80
        case .mid: return 120
        case .fast: return 160
        }
    }
}