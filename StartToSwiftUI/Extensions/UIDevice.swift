//
//  UIDevice.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 01.12.2025.
//

import Foundation
import UIKit

extension UIDevice {
    static var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isiPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
