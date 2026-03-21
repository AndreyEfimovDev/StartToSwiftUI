//
//  A008_ExpandableSection.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.03.2026.
//

import SwiftUI

struct A008_ExpandableSectionDemo: View {
    
    private let demoText: String = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
        
        Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        
        Curabitur pretium tincidunt lacus. Nulla gravida orci a odio. Nullam varius, turpis et commodo pharetra, est eros bibendum elit, nec luctus magna felis sollicitudin mauris. Integer in mauris eu nibh euismod gravida.
        """
    
    var body: some View {
        VStack {
            A008_ExpandableSection(
                title: "De Finibus Bonorum et Malorum",
                text: demoText,
                font: .body,
                lineSpacing: 0,
                linesLimit: 3
            )
            .foregroundStyle(Color.mycolor.myAccent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 15)
            )
            .padding()
            
            Spacer()
        }
    }
}

#Preview {
    A008_ExpandableSectionDemo()
}

struct A008_ExpandableSection: View {
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
                .overlay(alignment: .topLeading) {
                    // Measure full height
                    Text(text)
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .a008_getSize { fullHeight = $0.height }
                    // Measure limited height
                    Text(text)
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .lineLimit(linesLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .a008_getSize { limitedHeight = $0.height }
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

// MARK: - getSize

extension View {
    func a008_getSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { onChange(geo.size) }
                    .onChange(of: geo.size) { _, newSize in onChange(newSize) }
            }
        )
    }
}

struct A008_MoreLessTextButton: View {
    
    @Binding var showText: Bool
    
    var body: some View {
        Button{
            withAnimation(.smooth(duration: 0.5)) {
                showText.toggle()
            }
        } label: {
            Text(showText ? "less..." : "...more")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.mycolor.myBlue)
                .frame(minWidth: 60, alignment: .leading)
        }
    }
}
