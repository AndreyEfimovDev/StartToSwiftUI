//
//  CodableNotice.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 17.12.2025.
//

import Foundation

struct CodableNotice: Codable {
    let id: String
    let title: String
    let noticeDate: Date
    let noticeMessage: String
    var isRead: Bool
}
