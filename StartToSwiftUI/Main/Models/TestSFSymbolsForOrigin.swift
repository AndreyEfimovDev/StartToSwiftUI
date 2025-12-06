//
//  TestSFSymbolsForOrigin.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.12.2025.
//

import SwiftUI

struct TestSFSymbolsForOrigin: View {
    var body: some View {
        VStack(spacing: 20){
            HStack(spacing: 10) {
                // tray cube  archivebox folder arrow.up.folder text.document
                Image(systemName: "tray")
                Image(systemName: "cube")
                Image(systemName: "archivebox")
                Image(systemName: "folder")
                Image(systemName: "arrow.up.folder")
                Image(systemName: "text.document")
            }
        }
    }
}

#Preview {
    TestSFSymbolsForOrigin()
}
