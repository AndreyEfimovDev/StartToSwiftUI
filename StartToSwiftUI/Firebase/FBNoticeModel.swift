//
//  Untitled.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.02.2026.
//


import Foundation

// MARK: - Firestore Notice Model
struct FBNoticeModel {
    let noticeId: String
    let title: String
    let message: String
    let noticeDate: Date
    
    init(
        noticeId: String,
        title: String,
        message: String,
        noticeDate: Date
    ) {
        self.noticeId = noticeId
        self.title = title
        self.message = message
        self.noticeDate = noticeDate
    }
}
