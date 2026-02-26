////
////  SpeechRecogniser.swift
////  StartToSwiftUI
////
////  Created by Andrey Efimov on 22.11.2025.
////
//
//import SwiftUI
//import Speech
//import AVFoundation
//
//class SpeechRecogniser: NSObject, ObservableObject {
//    
//    @Published var recognisedText = ""
//    @Published var isRecording = false
//    @Published var errorMessage: String?
//    
//    private let audioEngine = AVAudioEngine()
//    private var speechRecogniser: SFSpeechRecognizer?
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private var silenceTimer: Timer?
//    
//    // Flag to track successful completion
//    private var hasRecognisedText = false
//    
//    override init() {
//        super.init()
//        self.speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
//        requestAuthorization()
//    }
//    
//    deinit {
//        
//        silenceTimer?.invalidate()
//        recognitionTask?.cancel()
//        
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            audioEngine.inputNode.removeTap(onBus: 0)
//        }
//        
//        log("SpeechRecogniser deinitialized", level: .info)
//
//    }
//    
//    
//    func requestAuthorization() {
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            DispatchQueue.main.async {
//                switch authStatus {
//                case .authorized:
//                    log("Speech recognition authorised", level: .info)
//                case .denied:
//                    self.errorMessage = "Speech recognition access denied"
//                case .restricted:
//                    self.errorMessage = "Speech recognition unavailable"
//                case .notDetermined:
//                    self.errorMessage = "Speech recognition not authorized"
//                @unknown default:
//                    self.errorMessage = "Unknown error"
//                }
//            }
//        }
//    }
//    
//    func startRecording() {
//        // Stop the previous recording
//        stopRecording()
//        
//        // Reset the flag and clear the error
//        hasRecognisedText = false
//        errorMessage = nil
//        recognisedText = ""
//        
//        // Check microphone availability
//        guard AVAudioSession.sharedInstance().availableInputs != nil else {
//            self.errorMessage = "Microphone unavailable"
//            return
//        }
//        
//        // Check microphone permissions
//        AVAudioApplication.requestRecordPermission { [weak self] allowed in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                if !allowed {
//                    self.errorMessage = "Microphone access denied"
//                    return
//                }
//                self.setupRecording()
//            }
//        }
//    }
//    
//    private func setupRecording() {
//        // Setting up an audio session
//        do {
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        } catch {
//            self.errorMessage = "Audio session error: \(error.localizedDescription)"
//            return
//        }
//        // Create a recognition request
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            self.errorMessage = "Cannot create recognition request"
//            return
//        }
//        
//        recognitionRequest.shouldReportPartialResults = true
//        
//        // Adding a timeout to detect silence
//        recognitionRequest.taskHint = .search
//        
//        // Checking the availability of the recognizer
//        guard let speechRecognizer = speechRecogniser, speechRecognizer.isAvailable else {
//            self.errorMessage = "Speech recognizer unavailable"
//            return
//        }
//        
//        // Setting up the audio input
//        let inputNode = audioEngine.inputNode
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        
//        guard recordingFormat.sampleRate > 0 else {
//            self.errorMessage = "Invalid audio format"
//            return
//        }
//        
//        // Set up Tap to capture audio
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, when in
//            self?.recognitionRequest?.append(buffer)
//        }
//        
//        // Launching the audio engine
//        audioEngine.prepare()
//        
//        do {
//            try audioEngine.start()
//            isRecording = true
//            errorMessage = nil
//            
//            // Set timer stopped after 15 seconds of silence
//            DispatchQueue.main.async { [weak self] in
//                self?.silenceTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
//                    self?.stopRecording()
//                    log("🛑 15-second timeout reached", level: .info)
//                }
//            }
//            
//        } catch {
//            self.errorMessage = "Cannot start audio engine: \(error.localizedDescription)"
//            return
//        }
//        
//        // Launch the recognition task
//        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            guard let self = self else { return }
//            
//            if let result = result {
//                let newText = result.bestTranscription.formattedString
//                DispatchQueue.main.async {
//                    if !newText.isEmpty {
//                        self.recognisedText = newText
//                    }
//                    self.errorMessage = nil
//                    
//                    // Set a flag upon successful recognition
//                    if !newText.isEmpty {
//                        self.hasRecognisedText = true
//                    }
//                    
//                    log("Recognized: \(newText)", level: .info)
//                }
//                
//                // Auto-stop after a pause in speech
//                if result.isFinal {
//                    self.stopRecording()
//                } else {
//                    // Restart the timer with each new word
//                    self.silenceTimer?.invalidate()
//                    self.silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
//                        self?.stopRecording()
//                    }
//                }
//            }
//            
//            if let error = error {
//                let nsError = error as NSError
//                // Error 301 - Check the flag
//                if nsError.code == 301 {
//                    if self.hasRecognisedText {
//                        log("Speech recognition completed successfully", level: .info)
//                        self.stopRecording()
//                    } else {
//                        DispatchQueue.main.async {
//                            self.errorMessage = "No speech detected. Please speak clearly."
//                            self.stopRecording()
//                        }
//                    }
//                    return
//                }
//                // Ignore 1110 and 216
//                if [1110, 216].contains(nsError.code) {
//                    self.stopRecording()
//                    return
//                }
//                
//                // Critical errors
//                DispatchQueue.main.async {
//                    self.errorMessage = "Error: \(error.localizedDescription)"
//                    self.stopRecording()
//                }
//            }
//        }
//    }
//    
//    func stopRecording() {
//        
//        // Stopp the timer silenceTimer in the main thread
//        DispatchQueue.main.async { [weak self] in
//            self?.silenceTimer?.invalidate()
//            self?.silenceTimer = nil
//            self?.isRecording = false
//        }
//                
//        recognitionTask?.cancel()
//        recognitionTask = nil
//        recognitionRequest?.endAudio()
//        recognitionRequest = nil
//        
//        if audioEngine.isRunning {
//            audioEngine.stop()
//            audioEngine.inputNode.removeTap(onBus: 0)
//        }
//        
//        do {
//            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//        } catch {
//            log("❌ Error deactivating audio session: \(error)", level: .error)
//        }
//    }
//    
//}
