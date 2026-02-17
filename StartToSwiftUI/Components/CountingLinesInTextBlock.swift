//
//  CountingLinesInTextBlock.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import SwiftUI

struct CountingLinesInTextBlock: View {
    
    @State private var lineCount: Int = 0
        
        var body: some View {
            Text("""
            SwiftUI lets measure
            how many lines a Text
            will actually use.
            """)
            .border(.red, width: 1)
            .font(.body)
            .lineSpacing(1)
            .frame(width: 200) // constrain width for wrapping
            .onLineCountChanged(font: .body, lineSpacing: 4) { count in
                lineCount = count
            }
            
            Text("Line count: \(lineCount)")
                .foregroundColor(.blue)
                .padding(.top)
                .opacity(lineCount > 3 ? 0.5 : 1)
        }
}

struct LineCountModifier: ViewModifier {
    let font: Font
    let lineSpacing: CGFloat
    let onChange: (Int) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            calculateLines(size: geo.size)
                        }
                        .onChange(of: geo.size) { oldSize, newSize in
                            calculateLines(size: newSize)
                        }
                }
            )
    }
    
    private func calculateLines(size: CGSize) {
        let uiFont = UIFont.from(font: font)
        let lineHeight = uiFont.lineHeight + lineSpacing
        let lineCount = Int(ceil(size.height / lineHeight))
        onChange(lineCount) // !!!!!
    }
}

extension UIFont {
    static func from(font: Font) -> UIFont {
        switch font {
        case .largeTitle: return UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title:      return UIFont.preferredFont(forTextStyle: .title1)
        case .title2:     return UIFont.preferredFont(forTextStyle: .title2)
        case .title3:     return UIFont.preferredFont(forTextStyle: .title3)
        case .headline:   return UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:return UIFont.preferredFont(forTextStyle: .subheadline)
        case .callout:    return UIFont.preferredFont(forTextStyle: .callout)
        case .caption:    return UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2:   return UIFont.preferredFont(forTextStyle: .caption2)
        case .footnote:   return UIFont.preferredFont(forTextStyle: .footnote)
        default:          return UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
    }
}

extension View {
    func onLineCountChanged(font: Font, lineSpacing: CGFloat = 0, perform: @escaping (Int) -> Void) -> some View {
        self.modifier(LineCountModifier(font: font, lineSpacing: lineSpacing, onChange: perform))
    }
}


#Preview {
    CountingLinesInTextBlock()
}

