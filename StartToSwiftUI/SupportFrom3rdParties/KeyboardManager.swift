//
//  ExternalKeyboardDetector.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 01.12.2025.
//

import SwiftUI
import Combine

class KeyboardManager: ObservableObject {
    
    @Published var shouldShowHideButton = false
    @Published var isKeyboardVisible = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupKeyboardObservers()
    }
    
    private func setupKeyboardObservers() {
        // Клавиатура появляется
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardShow(notification)
            }
            .store(in: &cancellables)
        
        // Клавиатура скрывается
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.handleKeyboardHide()
            }
            .store(in: &cancellables)
    }
    
    private func handleKeyboardShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        print("Keyboard height: \(keyboardHeight)")
        
        // Magic Keyboard: ~0-55pt, On-screen keyboard: > 200pt
        let isPhysicalKeyboard = keyboardHeight < 100
        
        DispatchQueue.main.async {
            self.isKeyboardVisible = true
            self.shouldShowHideButton = !isPhysicalKeyboard
        }
    }
    
    private func handleKeyboardHide() {
        DispatchQueue.main.async {
            self.isKeyboardVisible = false
            self.shouldShowHideButton = false
        }
    }
}
