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
    @EnvironmentObject private var speechRecogniser: SpeechRecogniser
    
    @FocusState private var isFocusedOnSearchBar: Bool
    
    let offOpacity: Double = 0.5
    
    var body: some View {
        
        HStack (spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(
                        isFocusedOnSearchBar ? Color.mycolor.myAccent : Color.mycolor.mySecondaryText
                    )

                TextField("Search here ...", text: $vm.searchText)
                    .foregroundStyle(Color.mycolor.myAccent)
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
                    .frame(height: isFocusedOnSearchBar ? 50 : 35)
                    .focused($isFocusedOnSearchBar)
                    .submitLabel(.search)
                    .onChange(of: speechRecogniser.recognisedText) { _, newValue in
                        vm.searchText = newValue
                    }
                    .padding(.leading, isFocusedOnSearchBar ? 8 : 0)
                
                xmarkButton
            }
            .font(.body)
            .padding(.leading, 8)
            .padding(.trailing, isFocusedOnSearchBar ? 0 : 8)
            .background(
                ZStack {
                    Capsule()
                        .stroke(
                            isFocusedOnSearchBar ? Color.mycolor.myBlue : Color.mycolor.mySecondaryText,
                            lineWidth: !isFocusedOnSearchBar ? 1 : 3
                        )
                }
            )
            
            micButton
        }
        .padding(8)
        .background(.ultraThinMaterial)
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
                    speechRecogniser.stopRecording()
                    isFocusedOnSearchBar = false
                    vm.searchText = ""
                    speechRecogniser.recognisedText = ""
                    speechRecogniser.errorMessage = nil
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
//                vm.searchText = ""
                speechRecogniser.startRecording()
                isFocusedOnSearchBar = true
            }

        } label: {
            Image(systemName: speechRecogniser.isRecording ? "stop.circle" : "mic")
                .font(isFocusedOnSearchBar ? .title : .body)
                .foregroundStyle(speechRecogniser.isRecording ? Color.mycolor.myRed : Color.mycolor.myAccent.opacity(offOpacity))
                .padding(8)
                .background(Color.black.opacity(0.001))
        }

    }
    
}

#Preview {
    ZStack {
        Color.pink.opacity(0.1)
            .ignoresSafeArea()
        SearchBarView()
            .environmentObject(PostsViewModel())
            .environmentObject(SpeechRecogniser())
    }
    
}
