//
//  UIDevice.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 01.12.2025.
//

import SwiftUI
import UIKit

extension UIDevice {
    
    //MARK: Devices
    
    static var idiom: UIUserInterfaceIdiom {
            UIDevice.current.userInterfaceIdiom
        }
    
    static var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isiPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    //MARK: Device sizes

    static var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    static var screenWidth: CGFloat {
        screenSize.width
    }
    
    static var screenHeigt: CGFloat {
        screenSize.height
    }
    
    //MARK: Check for specific models/sizes
    
    static var isSmalliPhone: Bool {
        isiPhone && screenWidth <= 375
    }
    
    static var isLargeiPad: Bool {
        isiPad && screenWidth >= 1024
    }

    //MARK: Check for specific models/sizes
    
    @Environment(\.horizontalSizeClass) static var horizontalSizeClass
    
    static var isLandscape: Bool {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return false
        }
        return scene.interfaceOrientation.isLandscape
    }
}
