//
//  GlobalFuncs.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.12.2025.
//

import SwiftUI

func log(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("\(level.icon) [\(fileName):\(line)] \(function) - \(message)")
    #endif
}
