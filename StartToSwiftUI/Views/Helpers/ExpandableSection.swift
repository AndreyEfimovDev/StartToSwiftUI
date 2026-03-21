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
                    .animation(nil, value: showFull)
            }
            
            Text(text)
                .font(font)
                .lineSpacing(lineSpacing)
                .lineLimit(nil) // always render the full text
                .frame(
                    height: showFull
                    ? max(fullHeight, 55)
                    : max(limitedHeight, 55),
                    alignment: .topLeading
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .mask { // smooth text fading from the bottom
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black, location: showFull ? 1.0 : 0.75), //Adjust the starting point of attenuation - here is 0.75
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .animation(.smooth(duration: 0.5), value: showFull) // slow height change
                .overlay(alignment: .topLeading) {
                    // Measure full height
                    Text(text)
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .getSize { fullHeight = $0.height }
                    // Measure limited height
                    Text(text)
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .lineLimit(linesLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .getSize { limitedHeight = $0.height }
                }
                .onChange(of: fullHeight)    { isTruncated = fullHeight > limitedHeight }
                .onChange(of: limitedHeight) { isTruncated = fullHeight > limitedHeight }
            
            if isTruncated {
                HStack {
                    Spacer()
                    MoreLessTextButton(showText: $showFull)
                }
            }
        }
    }
}

extension View {
    func getSize(onChange: @escaping (CGSize) -> Void) -> some View {
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
    VStack {
        ExpandableSection(
            title: "Intro",
            text:  PreviewData.samplePosts[0].intro,
            font: .subheadline,
            lineSpacing: 0,
            linesLimit: 5
        )
        Spacer()
    }
}
