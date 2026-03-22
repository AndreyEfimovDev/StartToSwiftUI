//
//  SnippetUnavailableView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.03.2026.
//

import SwiftUI

struct SnippetUnavailableView: View {
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                SnippetDemoHeader(snippet: snippet)
                    .padding()
            }
            .fixedSize(horizontal: false, vertical: true)
            
            ContentUnavailableView(
                "Requires iOS 26",
                systemImage: "iphone.slash",
                description: Text("Live preview is available on iOS 26 and later.")
            )
            .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    SnippetUnavailableView(snippet: SnippetsRepository.a001)
}
