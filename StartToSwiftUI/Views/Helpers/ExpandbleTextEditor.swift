//
//  ExpandbleTextEditor.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.03.2026.
//

import SwiftUI

struct ExpandbleTextEditor: View {
    
    @Binding var text: String
    var textFont: Font = .body
    @State private var height: CGFloat = 38
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text.isEmpty ? " " : text)
                .font(textFont)
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: TextEditorViewHeightKey.self,
                            value: $0.frame(in: .local).size.height
                        )
                    }
                )
                .hidden()
            
            TextEditor(text: $text)
                .font(textFont)
                .foregroundStyle(Color.mycolor.myAccent)
                .scrollContentBackground(.hidden)
                .frame(height: max(38, height))
        }
        .onPreferenceChange(TextEditorViewHeightKey.self) { height = $0 }
    }
}

struct TextEditorViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = max(value, nextValue())
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        var body: some View {
            ExpandbleTextEditor(text: $text, textFont: .body)
                .padding()
        }
    }
    return PreviewWrapper()
}
