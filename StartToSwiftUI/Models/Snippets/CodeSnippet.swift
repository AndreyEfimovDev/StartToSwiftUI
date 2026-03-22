//
//  CodeSnippet.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.03.2026.
//

import Foundation

struct CodeSnippet: Identifiable, Hashable {
    let id: String
    let category: String
    let title: String
    let intro: String
    let thanks: String?
    let date: Date
    let codeSnippet: String
    var minOS: MinOS = .ios18
    
    enum MinOS: String {
        case ios18 = "iOS 18+"
        case ios26 = "iOS 26+"

        var isAvailable: Bool {
            if #available(iOS 26, *) { return true }
            return self == .ios18
        }
    }
    
}










