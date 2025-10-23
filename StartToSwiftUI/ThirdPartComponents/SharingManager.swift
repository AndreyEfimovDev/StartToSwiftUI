//
//  SharingManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.10.2025.
//

import Foundation
import UIKit

class SharingManager: ObservableObject {
    
    @Published var isSharing = false
    @Published var shareResult: ActivityResult?
    @Published var showShareResult = false
    
    func share(items: [Any], completion: ((ActivityResult) -> Void)? = nil) {
        isSharing = true
        
        // Эмулируем асинхронную операцию для демонстрации
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            activityVC.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
                let result = ActivityResult(
                    activityType: activityType,
                    completed: completed,
                    returnedItems: returnedItems,
                    error: error
                )
                
                DispatchQueue.main.async {
                    self?.isSharing = false
                    self?.shareResult = result
                    self?.showShareResult = true
                    completion?(result)
                }
            }
            
            // Показываем UIActivityViewController
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        }
    }
}
