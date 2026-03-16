//
//  ErrorManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.03.2026.
//

import Foundation

@MainActor
final class ErrorManager: ObservableObject {
    static let shared = ErrorManager()
    
    @Published var errorMessage: String?
    @Published var showAlert: Bool = false
    
    func handle(_ error: Error? = nil, message: String) {
        errorMessage = error?.localizedDescription ?? message
        showAlert = true
        if let error {
            log("❌ \(message): \(error.localizedDescription)", level: .error)
        } else {
            log("❌ \(message)", level: .error)
        }
    }
    
    func clear() {
        errorMessage = nil
        showAlert = false
    }
}
