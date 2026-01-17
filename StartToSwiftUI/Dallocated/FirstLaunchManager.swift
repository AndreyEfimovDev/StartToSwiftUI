////
////  FirstLaunchManager.swift
////  StartToSwiftUI
////
////  Created by Andrey Efimov on 18.12.2025.
////
//
//import Foundation
//import SwiftUI
//
//class FirstLaunchManager: ObservableObject {
//    
//    static let shared = FirstLaunchManager()
//    
//    @AppStorage("hasLaunchedBefore")
//    var hasLaunchedBefore = false {
//        didSet {
//            objectWillChange.send()
//        }
//    }
//    
//    @AppStorage("hasImportedStaticData")
//    var hasImportedStaticData = false {
//        didSet {
//            objectWillChange.send()
//        }
//    }
//    
//    var isFirstLaunch: Bool {
//        !hasLaunchedBefore
//    }
//    
//    var hasImportedData: Bool {
//        get { hasImportedStaticData }
//        set { hasImportedStaticData = newValue }
//    }
//    
//    func markAsLaunched() {
//        hasLaunchedBefore = true
//    }
//    
//    func importStaticData() {
//        hasImportedStaticData = true
//        hasLaunchedBefore = true
//    }
//    
//    func resetForTesting() {
//        hasLaunchedBefore = false
//        hasImportedStaticData = false
//    }
//}
