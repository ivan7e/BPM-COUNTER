import Foundation

struct BPMEntry: Identifiable, Codable {
    let id = UUID()
    let bpm: Int
    var note: String
    var date: Date
    var imageData: Data?
}