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
                    Text(text)
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .onLineCountChanged(font: font, lineSpacing: lineSpacing) { count in
                            isTruncated = (count - 1) > linesLimit
                        }
                }
                .animation(.easeInOut(duration: 0.25), value: showFull)

            if isTruncated {
                HStack {
                    Spacer()
                    MoreLessTextButton(showText: $showFull)
                }
            }
        }
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
