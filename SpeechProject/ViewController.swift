//
//  ViewController.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import UIKit
import RxCocoa
import RxSwift
import AVFoundation

class ViewController: BaseViewController {
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var recordButton: UIButton!
    @IBOutlet private var playButton: UIButton!

    let viewModel: ViewModel?
    let disposeBag = DisposeBag()

    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "ViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpObservables()
        setUpActions()
    }

    func setUpView() {
        viewModel?.askPermission()
        recordButton.styleButton()
        playButton.styleButton()
        textView.style()
        AudioService.shared.synthesizer.delegate = self
    }

    func setUpActions() {
        recordButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.startRecording()
            self.viewModel?.toggleIsRecording()
        }).disposed(by: disposeBag)

        playButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.viewModel?.words.value.count ?? 0 < 1 {
                let action = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                self.showAlert("Not so fast", message: "There are no words to listen to", action: action)
            }
            self.viewModel?.play()
            self.viewModel?.toggleIsPlaying()
        }).disposed(by: disposeBag)
    }

    func setUpObservables() {
        viewModel?.isRecording.subscribe(onNext: { [weak self] isRecording in
            guard let self = self else { return }
            let recordButtonTitle = isRecording ? "Stop Recording" : "Record"
            self.recordButton.setTitle(recordButtonTitle, for: .normal)
        }).disposed(by: disposeBag)

        viewModel?.words.subscribe(onNext: { [weak self] words in
            guard let self = self else { return }
            self.textView.text = words
        }).disposed(by: disposeBag)

        viewModel?.isPlaying.subscribe(onNext: { [weak self] isPlaying in
            guard let self = self else { return }
            self.playButton.isEnabled = !isPlaying
            self.playButton.backgroundColor = self.playButton.isEnabled ? #colorLiteral(red: 0.2295188308, green: 0.3824364543, blue: 0.9958578944, alpha: 1) : #colorLiteral(red: 0.3820109963, green: 0.5057852864, blue: 0.9968019128, alpha: 1)
        }).disposed(by: disposeBag)

        viewModel?.generalError.subscribe(onNext: { [weak self] error in
            guard let self = self else { return }
            let action = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.dismiss(animated: true, completion: nil)
            }

            switch error {
            case .AudioEngineError(let message):
                self.showAlert("Audio engine error", message: message, action: action)
            case .SpeechSynthesizorError(let message):
                self.showAlert("Speech synthesizer error", message: message, action: action)
            case .none:
                return
            }
        }).disposed(by: disposeBag)

        viewModel?.permissionError.subscribe(onNext: { [weak self] error in
            guard let self = self else { return }
            if error.count > 0 {
                let action = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                self.showAlert("Permissions", message: error, action: action)
                self.recordButton.isEnabled = false
                self.playButton.isEnabled = false
            }
        }).disposed(by: disposeBag)
    }
}

extension ViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: characterRange)
        textView.attributedText = mutableAttributedString
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.viewModel?.isPlaying.accept(false)
    }
}
