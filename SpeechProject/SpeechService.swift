//
//  SpeechService.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import Speech
import RxSwift

class SpeechService {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    static let shared = SpeechService()

    func setUpService() -> Observable<String> {
        var text = ""
        recognitionTask?.cancel()
        self.recognitionTask = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recogRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest?.shouldReportPartialResults = true
        return Observable.create { observer in
            self.recognitionTask = self.speechRecognizer.recognitionTask(with: recogRequest) { result, error in
                var isFinal = false

                if let result = result {
                    text = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                    observer.onNext(text)
                }

                if error != nil || isFinal {
                    AudioService.shared.stop()
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }

            AudioService.shared.record { (buffer, error) in
                if let buffer = buffer {
                    self.recognitionRequest?.append(buffer)
                }

                if let error = error {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func requestPermission() -> String {
        var errorString = ""
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .denied:
                    errorString =  "User denied access to speech recognition"

                case .restricted:
                    errorString = "Speech recognition restricted on this device"

                case .notDetermined:
                    errorString = "Speech recognition not yet authorized"

                default:
                    errorString = ""
                }
            }
        }
        return errorString
    }


    func stop() {
        if AudioService.shared.audioEngine.isRunning {
            AudioService.shared.audioEngine.stop()
            recognitionRequest?.endAudio()
        }
    }
}
