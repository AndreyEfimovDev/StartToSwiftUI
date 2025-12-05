//
//  SearchBarView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.08.2025.
//

import SwiftUI
import Speech

struct SearchBarView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @StateObject private var speechRecogniser = SpeechRecogniser()
    
    @FocusState private var isFocusedOnSearchBar: Bool
    
    let offOpacity: Double = 0.5
    
    var body: some View {
        
        HStack (spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(
                        isFocusedOnSearchBar || speechRecogniser.isRecording ? Color.mycolor.myAccent : Color.mycolor.mySecondaryText
                    )

                TextField("Search here ...", text: $vm.searchText)
                    .foregroundStyle(Color.mycolor.myAccent)
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
                    .frame(height: isFocusedOnSearchBar ? 50 : 35)
                    .focused($isFocusedOnSearchBar)
                    .submitLabel(.search)
                    .onChange(of: speechRecogniser.recognisedText) { _, newSearchText in
                        if !vm.searchText.isEmpty {
                            vm.searchText.append(" " + newSearchText)
                        } else {
                            vm.searchText = newSearchText
                        }
                        vm.searchText = removeDoubleSpaces(vm.searchText)
                    }
                    .padding(.leading, isFocusedOnSearchBar ? 8 : 0)
                
                xmarkButton
            }
            .font(.body)
            .padding(.leading, 8)
            .padding(.trailing, isFocusedOnSearchBar ? 0 : 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .background(
                ZStack {
                    Capsule()
                        .stroke(
                            isFocusedOnSearchBar ? Color.mycolor.myBlue : Color.mycolor.mySecondaryText,
                            lineWidth: isFocusedOnSearchBar ? 5 : 1
                        )
                }
            )
            .padding(.leading, 16)
            .padding(.vertical, 8)
            
            micButton
        }
        .animation(.easeInOut, value: isFocusedOnSearchBar)
    }
    
    
    private var xmarkButton: some View {
        
        Image(systemName: "xmark")
            .imageScale(.large)
            .foregroundStyle(Color.mycolor.myRed)
            .padding(isFocusedOnSearchBar ? 15 : 0)
            .background(.black.opacity(0.001))
            .opacity(isFocusedOnSearchBar ? 1 : 0)
            .onTapGesture {
                if speechRecogniser.isRecording {
                    speechRecogniser.stopRecording()
                    speechRecogniser.errorMessage = nil
                } else {
                    isFocusedOnSearchBar = false
                    vm.searchText = ""
                    speechRecogniser.recognisedText = ""
                }
            }
    }
    
    private var micButton: some View {
        Button {
            
            if speechRecogniser.isRecording {
                speechRecogniser.stopRecording()
                if vm.searchText.isEmpty {
                    isFocusedOnSearchBar = false
                }
            } else {
                speechRecogniser.startRecording()
                isFocusedOnSearchBar = true
            }

        } label: {
            
            ZStack {
                
                Circle()
                    .fill(speechRecogniser.isRecording ? Color.mycolor.myRed : Color.clear)
                    .frame(width: 50, height: 50)
                    .scaleEffect(speechRecogniser.isRecording ? 1 : 0.0)
                    .opacity(speechRecogniser.isRecording ? 0 : 1)
                    .animation(
                        speechRecogniser.isRecording
                        ? .easeOut(duration: 1.0).repeatForever(autoreverses: false)
                        : .default,
                        value: speechRecogniser.isRecording
                    )

                Image(systemName: speechRecogniser.isRecording ? "stop.circle" : "mic")
                    .font(isFocusedOnSearchBar ? .title : .body)
                    .foregroundStyle(
                        speechRecogniser.isRecording ? Color.mycolor.myRed : Color.mycolor.mySecondaryText
                    )
                    .padding(8)
            }
        }
    }
    
    private func removeDoubleSpaces(_ string: String) -> String {
        return string.replacingOccurrences(of: "  ", with: " ")
    }
    
}

#Preview {
    ZStack {
        Color.pink.opacity(0.1)
            .ignoresSafeArea()
        SearchBarView()
            .environmentObject(PostsViewModel())
    }
    
}
