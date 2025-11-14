//
//  Notification.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import Foundation


struct Notice: Codable {
    
    let id: String
    let noteDate: Date
    let noteMessage: String
    
    init(
        id: String = UUID().uuidString,
        noteDate: Date,
        noteMessage: String
    ) {
        self.id = id
        self.noteDate = noteDate
        self.noteMessage = noteMessage
    }
    
}
