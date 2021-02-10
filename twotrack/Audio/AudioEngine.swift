import Foundation
import AVFoundation
import Combine

protocol AudioEngine {
    func play()
    func setTrackAVolume(value: Float)
    func setTrackBVolume(value: Float)
    var peakLevelPublisher: CurrentValueSubject<Float, Never> { get }
    var powerLevelPublisher: CurrentValueSubject<Float, Never> { get }
}

class MainAudioEngine: AudioEngine {
    var peakLevelPublisher = CurrentValueSubject<Float, Never>(-160)
    var powerLevelPublisher = CurrentValueSubject<Float, Never>(-160)
    
    private let engine = AVAudioEngine()
    private let trackAPlayer = AVAudioPlayerNode()
    private let trackBPlayer = AVAudioPlayerNode()
    private let mixer = AVAudioMixerNode()
    
    init() {
        engine.attach(trackAPlayer)
        engine.attach(trackBPlayer)
        engine.attach(mixer)
        
        engine.connect(trackAPlayer, to: mixer, format: trackAPlayer.outputFormat(forBus: 0))
        engine.connect(trackBPlayer, to: mixer, format: trackBPlayer.outputFormat(forBus: 0))
        engine.connect(mixer, to: engine.outputNode, format: mixer.outputFormat(forBus: 0))
        
        mixer.installTap(onBus: 0, bufferSize: 2048, format: mixer.outputFormat(forBus: 0))
        { [weak self] buffer, time in
            guard let channelDataPointer = buffer.floatChannelData else { return }
            
            let channelData = stride(
                from: 0,
                to: Int(buffer.frameLength),
                by: buffer.stride
            ).map { channelDataPointer.pointee[$0] }
            
            let peak = channelData.map { abs($0) }.max() ?? -.infinity
            let peakLevel = 20 * log10(peak)
            self?.peakLevelPublisher.send(peakLevel)
            
            let rmsPower = sqrtf(channelData.map { powf($0, 2) }.reduce(0, +) / Float(buffer.frameLength))
            let averagePower = 20 * log10(rmsPower)
            self?.powerLevelPublisher.send(averagePower)
        }
        
        do {
          try engine.start()
        } catch let error {
          fatalError(error.localizedDescription)
        }
    }
    
    func play() {
        guard let audioFileAURL = Bundle.main.url(forResource: "a", withExtension: "mp3"),
              let audioFileA = try? AVAudioFile(forReading: audioFileAURL) else { return }
        trackAPlayer.scheduleFile(audioFileA, at: nil, completionHandler: nil)
        trackAPlayer.play()
        
        guard let audioFileBURL = Bundle.main.url(forResource: "b", withExtension: "mp3"),
              let audioFileB = try? AVAudioFile(forReading: audioFileBURL) else { return }
        trackBPlayer.scheduleFile(audioFileB, at: nil, completionHandler: nil)
        trackBPlayer.play()
    }
    
    func setTrackAVolume(value: Float) {
        trackAPlayer.volume = value
    }
    
    func setTrackBVolume(value: Float) {
        trackBPlayer.volume = value
    }
}
