import Foundation

class BPMStorage {
    static let shared = BPMStorage()

    private let key = "savedBPMEntries"

    func save(_ entries: [BPMEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> [BPMEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([BPMEntry].self, from: data) else {
            return []
        }

        return entries
    }
}