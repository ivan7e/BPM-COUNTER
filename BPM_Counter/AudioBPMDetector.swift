import Foundation
import AVFoundation
import Combine

final class AudioBPMDetector: ObservableObject {
    @Published private(set) var bpm: Double = 0
    @Published private(set) var isRunning: Bool = false

    private let engine = AVAudioEngine()
    private var cancellables = Set<AnyCancellable>()

    // Onset detection state
    private var lastOnsetTime: TimeInterval = 0
    private var onsetTimes: [TimeInterval] = []
    private let minOnsetInterval: TimeInterval = 0.25 // avoid double triggers
    private let windowHorizon: TimeInterval = 8.0      // seconds of history for BPM calc

    // Energy tracking (exponential moving average)
    private var emaEnergy: Double = 0
    private let emaAlpha: Double = 0.2

    // Output smoothing
    private var smoothedBPM: Double = 0
    private let bpmSmoothing: Double = 0.2

    func start() {
        guard !isRunning else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
        }

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        resetState()

        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            self?.process(buffer: buffer, time: time, sampleRate: format.sampleRate)
        }

        do {
            try engine.start()
            DispatchQueue.main.async { self.isRunning = true }
        } catch {
            print("Failed to start engine: \(error)")
        }
    }

    func stop() {
        guard isRunning else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        DispatchQueue.main.async {
            self.isRunning = false
            self.bpm = 0
            self.smoothedBPM = 0
        }
    }

    private func resetState() {
        lastOnsetTime = 0
        onsetTimes.removeAll(keepingCapacity: true)
        emaEnergy = 0
        smoothedBPM = 0
        bpm = 0
    }

    private func process(buffer: AVAudioPCMBuffer, time: AVAudioTime, sampleRate: Double) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)

        // Compute short-time energy (sum of squares)
        var energy: Double = 0
        vDSP_measqv(channelData, 1, &energy, vDSP_Length(frameCount))
        // Exponential moving average for adaptive threshold
        if emaEnergy == 0 { emaEnergy = energy }
        emaEnergy = emaAlpha * energy + (1 - emaAlpha) * emaEnergy

        // Onset when energy rises above adaptive threshold
        let threshold = emaEnergy * 1.6
        if energy > threshold {
            let hostTimeSec = time.hostTime == 0 ? CACurrentMediaTime() : AVAudioTime.seconds(forHostTime: time.hostTime)
            registerOnset(at: hostTimeSec)
        }

        // Update BPM from onsets
        computeBPM(now: CACurrentMediaTime())
    }

    private func registerOnset(at t: TimeInterval) {
        // Debounce rapid triggers
        if t - lastOnsetTime < minOnsetInterval { return }
        lastOnsetTime = t
        onsetTimes.append(t)
        // Keep only recent onsets
        let cutoff = t - windowHorizon
        onsetTimes.removeAll { $0 < cutoff }
    }

    private func computeBPM(now: TimeInterval) {
        // Need at least 2 onsets
        guard onsetTimes.count >= 2 else { return }
        let intervals = zip(onsetTimes.dropFirst(), onsetTimes).map(-)
        let avg = intervals.reduce(0, +) / Double(intervals.count)
        guard avg > 0 else { return }
        var bpmEstimate = 60.0 / avg

        // Normalize to a typical musical range (60..200)
        while bpmEstimate < 60 { bpmEstimate *= 2 }
        while bpmEstimate > 200 { bpmEstimate /= 2 }

        // Smooth updates
        if smoothedBPM == 0 { smoothedBPM = bpmEstimate }
        smoothedBPM = bpmSmoothing * bpmEstimate + (1 - bpmSmoothing) * smoothedBPM

        DispatchQueue.main.async {
            self.bpm = self.smoothedBPM
        }
    }
}
