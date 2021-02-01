//
//  AudioService.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import AVFoundation

class AudioService {
    let audioEngine = AVAudioEngine()
    public let synthesizer = AVSpeechSynthesizer()
    static let shared = AudioService()

    func record(_ completion: @escaping (AVAudioPCMBuffer?, SpeechError?) -> Void) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)

            inputNode.installTap(onBus: 0,
                                 bufferSize: 1024,
                                 format: recordingFormat) { (buffer, _) in
                completion(buffer, nil)
            }
            audioEngine.prepare()
            try audioEngine.start()
        } catch let error {
            let speechError = SpeechError.AudioEngineError(message: error.localizedDescription)
            completion(nil, speechError)
        }
    }

    func play(_ text: String) {
        let speech = AVSpeechUtterance(string: text)
        synthesizer.speak(speech)
    }


    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
