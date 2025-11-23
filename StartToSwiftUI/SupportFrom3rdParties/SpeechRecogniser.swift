//
//  SpeechRecogniser.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.11.2025.
//

import SwiftUI
import Speech
import AVFoundation

//
//private enum SpeechError: Int {
//    case noSpeech = 301
//    case serviceBusy = 1110
//    case cancelled = 216
//    case retry = 1107
//    
//    var shouldIgnore: Bool {
//        switch self {
//        case .serviceBusy, .cancelled:
//            return true
//        default:
//            return false
//        }
//    }
//}
//

class SpeechRecogniser: NSObject, ObservableObject {
    
    @Published var recognisedText = ""
    @Published var isRecording = false
    @Published var errorMessage: String?
    
    private let audioEngine = AVAudioEngine()
    private var speechRecogniser: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?
    
    // Flag to track successful completion
    private var hasRecognisedText = false

    
    override init() {
        super.init()
        self.speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
        requestAuthorization()
        warmUp()
    }
    
    
    deinit {
        stopRecording()
    }

    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorised")
                case .denied:
                    self.errorMessage = "Speech recognition access denied"
                case .restricted:
                    self.errorMessage = "Speech recognition unavailable"
                case .notDetermined:
                    self.errorMessage = "Speech recognition not authorized"
                @unknown default:
                    self.errorMessage = "Unknown error"
                }
            }
        }
    }
    
    func startRecording() {
        // Stop the previous recording
        stopRecording()
        
        
        // Reset the flag and clear the error
        hasRecognisedText = false
        errorMessage = nil
        recognisedText = ""

        
        // Checking microphone permissions
        guard AVAudioSession.sharedInstance().availableInputs != nil else {
            self.errorMessage = "Microphone unavailable"
            return
        }
        
        // Проверяем разрешение на микрофон
        AVAudioApplication.requestRecordPermission { [weak self] allowed in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if !allowed {
                    self.errorMessage = "Microphone access denied"
                    return
                }
                
                self.setupRecording()
            }
        }
    }
    
    private func setupRecording() {
        // Setting up an audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.errorMessage = "Audio session error: \(error.localizedDescription)"
            return
        }
        
        // Create a recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            self.errorMessage = "Cannot create recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Adding a timeout to detect silence
        recognitionRequest.taskHint = .search
        
        // Checking the availability of the recognizer
        guard let speechRecognizer = speechRecogniser, speechRecognizer.isAvailable else {
            self.errorMessage = "Speech recognizer unavailable"
            return
        }
        
        // Setting up the audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        guard recordingFormat.sampleRate > 0 else {
            self.errorMessage = "Invalid audio format"
            return
        }
        
        // Set up Tap to capture audio
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, when in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Launching the audio engine
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
            errorMessage = nil
            
            // ✅ Auto-stop timer after 15 seconds
            silenceTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
                self?.stopRecording()
            }
            
        } catch {
            self.errorMessage = "Cannot start audio engine: \(error.localizedDescription)"
            return
        }
        
        // Launching the recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let newText = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    if !newText.isEmpty {
                        self.recognisedText = newText
                    }
                    self.errorMessage = nil
                    
                    // ✅ Set a flag upon successful recognition
                    if !newText.isEmpty {
                        self.hasRecognisedText = true
                    }

                    print("Recognized: \(newText)")
                }
                
                // ✅ Auto-stop after a pause in speech
                if result.isFinal {
                    self.stopRecording()
                } else {
                    // Перезапускаем таймер при каждом новом слове
                    self.silenceTimer?.invalidate()
                    self.silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                        self?.stopRecording()
                    }
                }
            }
            
            if let error = error {
                let nsError = error as NSError
                
                // Error 301 - Check the flag
                if nsError.code == 301 {
                    if self.hasRecognisedText {
                        print("Speech recognition completed successfully")
                        self.stopRecording()
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "No speech detected. Please speak clearly."
                            self.stopRecording()
                        }
                    }
                    return
                }

                // Ignore 1110 and 216
                if [1110, 216].contains(nsError.code) {
                    self.stopRecording()
                    return
                }
                
                // Critical errors
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    self.stopRecording()
                }
            }
        }
    }
    
    func stopRecording() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    
    // ✅ Метод для полного прогрева
        func warmUp() {
            // 1. Запрашиваем авторизацию
            SFSpeechRecognizer.requestAuthorization { _ in }
            AVAudioApplication.requestRecordPermission { _ in }
            
            // 2. Инициализируем Audio Session
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try audioSession.setActive(true)
                    
                    // 3. Прогреваем Audio Engine
                    let audioEngine = AVAudioEngine()
                    let inputNode = audioEngine.inputNode
                    let recordingFormat = inputNode.outputFormat(forBus: 0)
                    
                    // Устанавливаем и сразу убираем tap
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { _, _ in }
                    
                    audioEngine.prepare()
                    try audioEngine.start()
                    
                    // Останавливаем через 0.1 сек
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        try? audioSession.setActive(false)
                        print("✅ Speech recognizer fully warmed up")
                    }
                    
                } catch {
                    print("⚠️ Warm up error: \(error)")
                }
            }
        }
    
    
}
