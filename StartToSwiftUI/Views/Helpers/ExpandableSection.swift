//
//  ExpandableSection.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 18.03.2026.
//

import SwiftUI

struct ExpandableSection: View {
    let title: String?
    let text: String
    let font: Font
    let lineSpacing: CGFloat
    let linesLimit: Int
    
    @State private var showFull = false
    @State private var isTruncated = false
    @State private var fullHeight: CGFloat = 0
    @State private var limitedHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            if let title {
                Text(title)
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text(text)
                .font(font)
                .lineSpacing(lineSpacing)
                .lineLimit(showFull ? nil : linesLimit)
                .frame(minHeight: 55, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topLeading) {
                    // Measure full height
                    Text(text)
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .readSize { fullHeight = $0.height }
                    
                    // Measure limited height
                    Text(text)
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .lineLimit(linesLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .readSize { limitedHeight = $0.height }
                }
                .onChange(of: fullHeight)    { isTruncated = fullHeight > limitedHeight }
                .onChange(of: limitedHeight) { isTruncated = fullHeight > limitedHeight }
            
            if isTruncated {
                HStack {
                    Spacer()
                    A008_MoreLessTextButton(showText: $showFull)
                }
            }
        }
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { onChange(geo.size) }
                    .onChange(of: geo.size) { _, newSize in onChange(newSize) }
            }
        )
    }
}


#Preview {
    ExpandableSection(
        title: "Intro",
        text:  PreviewData.samplePosts[0].intro,
        font: .subheadline,
        lineSpacing: 0,
        linesLimit: 10
    )
}
