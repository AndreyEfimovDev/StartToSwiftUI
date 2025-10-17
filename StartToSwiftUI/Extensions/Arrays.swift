//
//  Arrays.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.09.2025.
//

import Foundation



// MARK: CUSTOM FUNC MEGRING 2 ARRAYS WITH UNIQUE KEY - TITLE

extension Array {
    mutating func merge<U: Equatable>(
        with newElements: [Element],
        uniqueBy keyPath: KeyPath<Element, U>
    ) {
        for element in newElements {
            let value = element[keyPath: keyPath]
            if !self.contains(where: { $0[keyPath: keyPath] == value }) {
                self.append(element)
            }
        }
    }
}
