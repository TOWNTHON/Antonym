//
//  InputSpeechViewController.swift
//  Antonym
//
//  Created by 広瀬緑 on 2016/10/29.
//  Copyright © 2016年 midori hirose. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import SwiftDate

final class InputSpeechViewController: UIViewController {

    // "ja-JP"を指定すると日本語になります。
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let talker = AVSpeechSynthesizer()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        speechRecognizer.delegate = self
        button.isEnabled = false
        
        let network = NetworkEngine()
        network.getAsync(text: "ノーブラ")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        requestRecognizerAuthorization()
    }
    
    @IBAction func tapStartButton(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            button.isEnabled = false
            button.setTitle("停止中", for: .disabled)
        } else {
            try! startRecording()
            button.setTitle("音声認識を中止", for: [])
        }
    }
    
    private func requestRecognizerAuthorization() {
        // 認証処理
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // メインスレッドで処理したい内容のため、OperationQueue.main.addOperationを使う
            OperationQueue.main.addOperation { [weak self] in
                guard let `self` = self else { return }
                
                switch authStatus {
                case .authorized:
                    self.button.isEnabled = true
                    
                case .denied:
                    self.button.isEnabled = false
                    self.button.setTitle("音声認識へのアクセスが拒否されています。", for: .disabled)
                    
                case .restricted:
                    self.button.isEnabled = false
                    self.button.setTitle("この端末で音声認識はできません。", for: .disabled)
                    
                case .notDetermined:
                    self.button.isEnabled = false
                    self.button.setTitle("音声認識はまだ許可されていません。", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording() throws {
        refreshTask()
        
        let audioSession = AVAudioSession.sharedInstance()
        // 録音用のカテゴリをセット
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // 録音が完了する前のリクエストを作るかどうかのフラグ。
        // trueだと現在-1回目のリクエスト結果が返ってくる模様。falseだとボタンをオフにしたときに音声認識の結果が返ってくる設定。
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let `self` = self else { return }
            var isFinal = false
            var inputText = ""
            
            if let result = result {
                inputText = result.bestTranscription.formattedString
                self.label.text = inputText
                isFinal = result.isFinal
            }

            // エラーがある、もしくは最後の認識結果だった場合の処理
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.button.isEnabled = true
                self.button.setTitle("音声認識スタート", for: [])
            }
        }
        
        // マイクから取得した音声バッファをリクエストに渡す
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        try startAudioEngine()
    }
    
    func changeView(sender:Timer) {
        print("５秒後だよ")
    }
    
    private func refreshTask() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    private func startAudioEngine() throws {
        // startの前にリソースを確保しておく。
        audioEngine.prepare()
        
        try audioEngine.start()
        
        label.text = "どうぞ喋ってください。"
    }
    
    private func speech(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        setOptionsForSpeech(utterance: utterance)
        self.talker.speak(utterance)
    }
    
    private func setOptionsForSpeech(utterance: AVSpeechUtterance) {
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.pitchMultiplier = 0.8
        utterance.rate = 0.1
    }
}

extension InputSpeechViewController: SFSpeechRecognizerDelegate {
    // 音声認識の可否が変更したときに呼ばれるdelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            button.isEnabled = true
            button.setTitle("音声認識スタート", for: [])
        } else {
            button.isEnabled = false
            button.setTitle("音声認識ストップ", for: .disabled)
        }
    }
}
