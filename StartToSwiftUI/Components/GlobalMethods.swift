//
//  GlobalFuncs.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.12.2025.
//

import SwiftUI

//func postNotSelectedEmptyView(text: String) -> some View {
//    
//    ZStack {
//        VStack {
//            Image("A_1024x1024_PhosphateInline_tr")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 300)
//                .opacity(0.15)
//            Text(text)
//                .font(.largeTitle)
//                .bold()
//                .padding()
//        }
//        .foregroundStyle(Color.mycolor.myAccent)
//    }
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
//}

func log(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("\(level.icon) [\(fileName):\(line)] \(function) - \(message)")
    #endif
}
