//
//  SpeechService.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import Speech
import RxSwift

enum SpeechError: Error {
    case SFSpeechError
}

class SpeechService {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    static let shared = SpeechService()

    func setUpService(_ buffer: AVAudioPCMBuffer) -> Observable<String> {
        return Observable.create { observer in
            var text = ""
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recogRequest = self.recognitionRequest else {
                observer.onError(SpeechError.SFSpeechError)
                return Disposables.create()
            }
            recogRequest.shouldReportPartialResults = true
            self.recognitionTask = self.speechRecognizer.recognitionTask(with: recogRequest) { result, error in
                var isFinal = false

                if let result = result {
                    text = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                    observer.onNext(text)
                }

                if let error = error {
                    AudioService.shared.stop()
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    observer.onError(error)
                }

                if error != nil || isFinal {
                    AudioService.shared.stop()
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }

            recogRequest.append(buffer)
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
