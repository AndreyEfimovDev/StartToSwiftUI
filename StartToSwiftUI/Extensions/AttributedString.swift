//
//  AttributedString.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//

import Splash
import SwiftUI

extension AttributedString {
    static func splashHighlighted(_ code: String) -> AttributedString {
        let highlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: .wwdc17(withFont: .init(size: 13))))
        let attributed = highlighter.highlight(code)
        return AttributedString(attributed)
    }
}
