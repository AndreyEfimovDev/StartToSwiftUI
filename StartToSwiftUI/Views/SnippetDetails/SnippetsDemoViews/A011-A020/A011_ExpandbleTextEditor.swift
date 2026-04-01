//
//  A011_ExpandbleTextEditor.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.03.2026.
//

import SwiftUI

struct A011_ExpandbleTextEditorDemo: View {
    
    @Binding var text: String
    var textFont: Font = .body //  default value → the parameter is optional
    @State private var height: CGFloat = 38
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text.isEmpty ? " " : text)
                .font(textFont)
                .padding(8)
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: A011_TextEditorViewHeightKey.self,
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
                .padding(.horizontal, 3)
        }
        .background(.ultraThinMaterial.opacity(0.5))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.mycolor.myBlue.opacity(0.5), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: 250)
        .onPreferenceChange(A011_TextEditorViewHeightKey.self) { height = $0 }
    }
}

struct A011_TextEditorViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = max(value, nextValue())
    }
}

/*
 
 ## How it works:
 ```
 ZStack
 ├── Text (hidden, but it is measured)
 │     └── GeometryReader
 │           └── .preference(key: ..., value: height)  ← publishes
 │
 └── TextEditor
       └── .frame(height: max(38, height))             ← uses

 .onPreferenceChange { height = $0 }                   ← catches on ZStack
 
 ## Application
 ```
 *** without explicit font — .body by default
 ExpandableTextEditor(text: $text)

 *** with an explicit font
 ExpandableTextEditor(text: $text, font: .callout)
 ExpandableTextEditor(text: $text, font: .system(.body, design: .monospaced))
 
 */

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        var body: some View {
            A011_ExpandbleTextEditorDemo(text: $text, textFont: .body)
                .padding()
        }
    }
    return PreviewWrapper()
}
