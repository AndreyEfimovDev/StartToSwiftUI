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
    
    let myAccent = Color("_Accent")
    let myBackground = Color("_Background")
    let myBlue = Color("_Blue")
    let myGreen = Color("_Green")
    let myOrange = Color("_Orange")
    let myPurple = Color("_Purple")
    let myRed = Color("_Red")
    let mySecondary = Color("_Secondary")
    let myYellow = Color("_Yellow")
    
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


