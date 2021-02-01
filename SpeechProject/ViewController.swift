//
//  ViewController.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import UIKit
import RxCocoa
import RxSwift

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
    }
    
    func showErrorAlert(_ title: String?, message: String?, actionTitle: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
    }
    
    func setUpActions() {
        recordButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.startRecording()
            self.viewModel?.toggleIsRecording()
        }).disposed(by: disposeBag)
        
        playButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.play()
            self.viewModel!.toggleIsPlaying()
        }).disposed(by: disposeBag)
    }
    
    func setUpObservables() {
        viewModel?.isRecording.subscribe(onNext: { [weak self] isRecording in
            guard let self = self else { return }
            let recordButtonTitle = isRecording ? "Stop Recording" : "Record"
            self.recordButton.setTitle(recordButtonTitle, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel?.isPlaying.subscribe(onNext: { [weak self] isPlaying in
            guard let self = self else { return }
            self.playButton.isEnabled = !isPlaying
            self.playButton.backgroundColor = !isPlaying ? #colorLiteral(red: 0.2295188308, green: 0.3824364543, blue: 0.9958578944, alpha: 1) : #colorLiteral(red: 0.3820109963, green: 0.5057852864, blue: 0.9968019128, alpha: 1)
        }).disposed(by: disposeBag)
        
        viewModel?.permissionError.subscribe(onNext: { [weak self] error in
            guard let self = self else { return }
            if error.count > 0 {
                self.showErrorAlert("Permissions", message: error, actionTitle: "dismiss")
                self.recordButton.isEnabled = false
            }
        }).disposed(by: disposeBag)
        
        viewModel?.words.subscribe(onNext: { [weak self] words in
            self?.textView.text = words
        }).disposed(by: disposeBag)
    }
}
