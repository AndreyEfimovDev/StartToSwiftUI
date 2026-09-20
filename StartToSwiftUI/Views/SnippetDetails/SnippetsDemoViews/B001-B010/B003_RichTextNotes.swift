//
//  B003_RichTextNotes.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.09.2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct B003_RichTextNotesDemo: View {
    @State private var text = AttributedString(
        "Rich Text Notes\n\nSelect some text and tap Bold, Italic, or the size buttons below the keyboard."
    )
    @State private var selection = AttributedTextSelection()

    var body: some View {
        // TextEditor now takes an AttributedString binding directly — no more
        // wrapping UITextView in a UIViewRepresentable for rich text editing.
        TextEditor(text: $text, selection: $selection)
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        applyBold()
                    } label: {
                        Image(systemName: "bold")
                    }

                    Button {
                        applyItalic()
                    } label: {
                        Image(systemName: "italic")
                    }

                    Spacer()

                    Button {
                        applyFont(.body)
                    } label: {
                        Image(systemName: "textformat.size.smaller")
                    }

                    Button {
                        applyFont(.title2)
                    } label: {
                        Image(systemName: "textformat.size.larger")
                    }
                }
            }
    }

    // MARK: - Formatting

    // transformAttributes(in:) applies a change to just the selected range —
    // the AttributedTextSelection tracks the caret/selection through edits.
    private func applyBold() {
        text.transformAttributes(in: &selection) { container in
            container.font = .body.bold()
        }
    }

    private func applyItalic() {
        text.transformAttributes(in: &selection) { container in
            container.font = .body.italic()
        }
    }

    private func applyFont(_ font: Font) {
        text.transformAttributes(in: &selection) { container in
            container.font = font
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B003_RichTextNotesDemo()
    }
}
