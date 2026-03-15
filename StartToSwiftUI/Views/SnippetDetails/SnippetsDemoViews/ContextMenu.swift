//
//  ContextMenu.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 15.03.2026.
//

import SwiftUI

struct ContextMenu: View {
    
    var body: some View {
        VStack {
            Text("Turtle Rock")
                .foregroundColor(.blue)
                .padding()
                .contextMenu {
                    Button {
                        // Add this item to a list of favorites.
                    } label: {
                        Label("Add to Favorites", systemImage: "heart")
                    }
                    Button {
                        // Open Maps and center it on this item.
                    } label: {
                        Label("Show in Maps", systemImage: "mappin")
                    }
                }
        }
        
    }
}

#Preview {
    ContextMenu()
}
