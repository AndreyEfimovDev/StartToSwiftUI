//
//  VoiceSearchView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.11.2025.
//

import SwiftUI

struct VoiceSearchView: View {
    
    @EnvironmentObject private var speechRecogniser: SpeechRecogniser
    
    @State private var searchText = ""
    @State private var isPulsing: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Search with voice...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: speechRecogniser.recognisedText) { _, newValue in
                        searchText = newValue
                    }
                
                // xmark button
                if !searchText.isEmpty && !speechRecogniser.isRecording {
                    Button {
                        withAnimation {
                            searchText = ""
                            speechRecogniser.recognisedText = ""
                            speechRecogniser.errorMessage = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
//                    .transition(.scale.combined(with: .opacity))
                }
                
                // Voice recording button
                Button {
                    if speechRecogniser.isRecording {
//                        isPulsing = false
                        speechRecogniser.stopRecording()
                    } else {
                        searchText = ""
//                        isPulsing = true
                        speechRecogniser.startRecording()
                    }
                } label: {
                    ZStack {
                        // Outer circle (pulsation)
                        Circle()
                            .fill(speechRecogniser.isRecording ? Color.red.opacity(0.3) : Color.clear)
                            .frame(width: 50, height: 50)
                            .scaleEffect(speechRecogniser.isRecording ? 1.3 : 1.0)
                            .opacity(speechRecogniser.isRecording ? 0 : 1)
                            .animation(
                                speechRecogniser.isRecording
                                ? .easeOut(duration: 1.0).repeatForever(autoreverses: false)
                                : .default,
                                value: speechRecogniser.isRecording
                            )
                        
                        Image(systemName: speechRecogniser.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title)
                            .foregroundColor(speechRecogniser.isRecording ? .red : .blue)
                            .symbolEffect(.pulse, isActive: speechRecogniser.isRecording)
                    }
                }
                .buttonStyle(.plain)
            }
            
            if let error = speechRecogniser.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
    }    
}

#Preview {
    VoiceSearchView()
        .environmentObject(SpeechRecogniser())
    
}
