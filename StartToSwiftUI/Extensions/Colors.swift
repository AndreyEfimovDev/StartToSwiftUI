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
    
    let myAccent = Color("_myAccent")
    let myBackground = Color("_myBackground")
    let myBlue = Color("_myBlue")
    let myGreen = Color("_myGreen")
    let myOrange = Color("_myOrange")
    let myPurple = Color("_myPurple")
    let myRed = Color("_myRed")
    let mySecondary = Color("_mySecondary")
    let myYellow = Color("_myYellow")
    
    let myButtonBGBlue = Color("ButtonBG_Blue")
    let myButtonBGGray = Color("ButtonBG_Gray")
    let myButtonBGGreen = Color("ButtonBG_Green")
    let myButtonBGRed = Color("ButtonBG_Red")
    
    let myButtonTextPrimary = Color("ButtonTextPrimary")
    let myButtonTextRed = Color("ButtonTextRed")
    let myButtonTextSecondary = Color("ButtonTextSecondary")

    let mySectionBackground = Color("SectionBackground")

}


struct LaunchColors {
    
    let accent = Color("LaunchAccentColor")
    let background = Color("LaunchBackgroundColor")
    
}


