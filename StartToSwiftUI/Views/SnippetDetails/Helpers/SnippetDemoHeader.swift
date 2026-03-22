//
//  SnippetDemoHeader.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.03.2026.
//

import SwiftUI

struct SnippetDemoHeader: View {
    
    let snippet: CodeSnippet
    
    @State private var showFullIntro: Bool = false
    @State private var isTruncated = false
    
    private let introFont: Font = .subheadline
    private let introLineSpacing: CGFloat = 0
    private let introLinesLimit: Int = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(snippet.title)
                .font(.title2)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.75)
                .lineLimit(showFullIntro ? nil : 1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ExpandableSection(
                title: nil,
                text: snippet.intro,
                font: .subheadline,
                lineSpacing: 0,
                linesLimit: 3
            )
        }
        .cardBackground()
    }
}


#Preview {
    SnippetDemoHeader(snippet: SnippetsRepository.a001)
}
