//
//  AudioService.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import AVFoundation
var audioFilePlayer = AVAudioPlayerNode()


class AudioService {
    let audioEngine = AVAudioEngine()
    let audioSession = AVAudioSession.sharedInstance()
    var buffer: AVAudioPCMBuffer?
    static let shared = AudioService()

    func record(_ completion: @escaping (AVAudioPCMBuffer) -> Void) {
        try! audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: recordingFormat) { (buffer, _) in
            self.buffer = buffer
            completion(buffer)
        }
        audioEngine.prepare()
        try! audioEngine.start()
    }

    func play() {
        do {
            let mainMixer = audioEngine.mainMixerNode
            audioEngine.attach(audioFilePlayer)
            audioEngine.connect(audioFilePlayer, to: mainMixer, format: buffer?.format)
            try audioEngine.start()
            audioFilePlayer.play()
            audioFilePlayer.scheduleBuffer(buffer!, completionHandler: nil)
        } catch let error {
            print(error)
        }
    }

    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }

    func stopPlaybackEngine() {
        audioEngine.outputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
