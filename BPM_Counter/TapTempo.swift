import Foundation

final class TapTempo {
    private var taps: [TimeInterval] = []
    private let maxTaps = 8
    private let timeout: TimeInterval = 2.0

    func registerTap(at date: Date = Date()) -> Double? {
        let now = date.timeIntervalSinceReferenceDate
        // Remove stale taps
        taps = taps.filter { now - $0 <= timeout }
        // Append new tap
        taps.append(now)
        // Keep only last N
        if taps.count > maxTaps { taps.removeFirst(taps.count - maxTaps) }
        // Need at least 2 taps to compute BPM
        guard taps.count >= 2 else { return nil }
        // Compute intervals
        let intervals = zip(taps.dropFirst(), taps).map(-)
        let average = intervals.reduce(0, +) / Double(intervals.count)
        guard average > 0 else { return nil }
        return 60.0 / average
    }

    func reset() { taps.removeAll() }
}
