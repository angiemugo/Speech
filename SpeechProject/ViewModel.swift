//
//  ViewModel.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import Foundation
import RxCocoa
import RxSwift

class ViewModel: NSObject {
    let isRecording = BehaviorRelay(value: false)
    let isPlaying = BehaviorRelay(value: false)
    let words = BehaviorRelay(value: "")
    var permissionError = BehaviorRelay(value: "")
    let disposeBag = DisposeBag()
    let speechService = SpeechService()
    
    func toggleIsRecording() {
        isRecording.accept(!isRecording.value)
    }

    func toggleIsPlaying() {
        isPlaying.accept(!isPlaying.value)
    }
    
    func askPermission() {
        let error = SpeechService.shared.requestPermission()
        permissionError.accept(error)
    }
    
    func startRecording() {
        if isRecording.value {
            self.stopRecording()
        } else {
            AudioService.shared.record({ [weak self] buffer in
                guard let self = self else { return }
                self.speechService.setUpService(buffer).subscribe(onNext: { [weak self] (text) in
                    guard let self = self else { return }
                    self.words.accept(text)
                }, onError: { error in
                    self.permissionError.accept(error.localizedDescription)
                }).disposed(by: self.disposeBag)
            })
        }
    }

    func stopRecording() {
        SpeechService.shared.stop()
    }
    
    func play() {
        AudioService.shared.play()
    }
}
