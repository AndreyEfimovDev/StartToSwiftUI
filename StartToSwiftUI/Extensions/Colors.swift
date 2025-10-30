//
//  MyColors.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.08.2025.
//

import Foundation
import SwiftUI


// MARK: CUSTOM COLORS

extension Color {
    static let mycolor = MyColors()
    static let launch = LaunchColors()

}

struct MyColors {
    
    let myAccent = Color("AppAccentColor")
    let myBackground = Color("AppBackgroundColor")
    let mySectionBackground = Color("AppSectionBackgroundColor")
    let myBlue = Color("AppBlueColor")
    let myGreen = Color("AppGreenColor")
    let myYellow = Color("AppYellowColor")
    let middle = Color("AppMiddle")
    let myOrange = Color("AppOrangeColor")
    let myRed = Color("AppRedColor")
    let mySecondaryText = Color("AppSecondaryTextColor")
    let myButtonTextPrimary = Color("AppButtonTextPrimary")
    let myButtonTextRed = Color("AppButtonTextRed")
    let myButtonTextSecondary = Color("AppButtonTextSecondary")

}


struct LaunchColors {
    
    let accent = Color("LaunchAccentColor")
    let background = Color("LaunchBackgroundColor")
    
}


