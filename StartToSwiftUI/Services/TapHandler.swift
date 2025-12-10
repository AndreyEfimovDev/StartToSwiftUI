//
//  TapHandler.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 07.12.2025.
//

import SwiftUI

class TapHandler {
    var singleTapAction: () -> Void
    var doubleTapAction: () -> Void
    
    init(
        singleTapAction: @escaping () -> Void = {},
        doubleTapAction: @escaping () -> Void = {}
    ) {
        self.singleTapAction = singleTapAction
        self.doubleTapAction = doubleTapAction
    }
    
    private var tapCount = 0
    private var timer: Timer?
    
    func handleTap() {
        tapCount += 1
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            if self.tapCount == 1 {
                self.singleTapAction()
            } else if self.tapCount == 2 {
                self.doubleTapAction()
            }
            
            self.tapCount = 0
        }
    }
}
