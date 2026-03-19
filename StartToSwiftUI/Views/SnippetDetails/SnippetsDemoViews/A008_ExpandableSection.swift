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
                        .a008_readSize { fullHeight = $0.height }
                    
                    // Measure limited height
                    Text(text)
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .lineLimit(linesLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .a008_readSize { limitedHeight = $0.height }
                }
                .onChange(of: fullHeight)    { isTruncated = fullHeight > limitedHeight }
                .onChange(of: limitedHeight) { isTruncated = fullHeight > limitedHeight }
                .animation(.easeInOut(duration: 0.5), value: showFull)
            
            if isTruncated {
                HStack {
                    Spacer()
                    A008_MoreLessTextButton(showText: $showFull)
                }
            }
        }
    }
}

// MARK: - readSize

extension View {
    func a008_readSize(onChange: @escaping (CGSize) -> Void) -> some View {
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
            showText.toggle()
        } label: {
            Text(showText ? "less..." : "...more")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.mycolor.myBlue)
                .frame(minWidth: 60, alignment: .leading)
        }
    }
}

//
//extension View {
//    func a008_onLineCountChanged(font: Font, lineSpacing: CGFloat = 0, perform: @escaping (Int) -> Void) -> some View {
//        self.modifier(A008_LineCountModifier(font: font, lineSpacing: lineSpacing, onChange: perform))
//    }
//}
//
//struct A008_LineCountModifier: ViewModifier {
//    let font: Font
//    let lineSpacing: CGFloat
//    let onChange: (Int) -> Void
//
//    func body(content: Content) -> some View {
//        content
//            .background(
//                GeometryReader { geo in
//                    Color.clear
//                        .onAppear {
//                            calculateLines(size: geo.size)
//                        }
//                        .onChange(of: geo.size) { oldSize, newSize in
//                            calculateLines(size: newSize)
//                        }
//                }
//            )
//    }
//
//    private func calculateLines(size: CGSize) {
//        let uiFont = UIFont.a008_from(font: font)
//        let lineHeight = uiFont.lineHeight + lineSpacing
//        let lineCount = Int(ceil(size.height / lineHeight))
//        onChange(lineCount)
//    }
//}
//
//extension UIFont {
//    static func a008_from(font: Font) -> UIFont {
//        switch font {
//        case .largeTitle: return UIFont.preferredFont(forTextStyle: .largeTitle)
//        case .title:      return UIFont.preferredFont(forTextStyle: .title1)
//        case .title2:     return UIFont.preferredFont(forTextStyle: .title2)
//        case .title3:     return UIFont.preferredFont(forTextStyle: .title3)
//        case .headline:   return UIFont.preferredFont(forTextStyle: .headline)
//        case .subheadline:return UIFont.preferredFont(forTextStyle: .subheadline)
//        case .callout:    return UIFont.preferredFont(forTextStyle: .callout)
//        case .caption:    return UIFont.preferredFont(forTextStyle: .caption1)
//        case .caption2:   return UIFont.preferredFont(forTextStyle: .caption2)
//        case .footnote:   return UIFont.preferredFont(forTextStyle: .footnote)
//        default:          return UIFont.systemFont(ofSize: UIFont.systemFontSize)
//        }
//    }
//}
