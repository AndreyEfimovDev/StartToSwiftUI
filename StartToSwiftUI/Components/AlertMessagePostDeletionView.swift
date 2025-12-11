//
//  AlertMessageView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.12.2025.
//

import SwiftUI

struct AlertMessagePostDeletionView: View {
    
    let message1: String = "Are you sure you want to delete the material?"
    let message2: String = "It will be impossible to undo the deletion."
    let component: String
    let limit: Int = 20
    
    private var shortenPostTitle: String {
           if component.count > limit {
               return String(component.prefix(limit - 3)) + "..."
           }
           return component
       }
        var body: some View {
            Text("""
             Are you sure you want to delete the material?
             
             "\(component)"
             
             This cannot be undone.
             """)
//            VStack(spacing: 4) {
//                        Text("Are you sure you want to delete the material?")
//                            .fontWeight(.medium)
//                            .multilineTextAlignment(.center)
//                        
//                        Text("\"\(component)\"")
//                            .font(.subheadline)
//                            .foregroundColor(.blue)
//                            .multilineTextAlignment(.center)
//                            .padding(.top, 4)
//                        
//                        Text("It will be impossible to undo the deletion.")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                            .padding(.top, 8)
//                    }
//            Text(message)
//                .multilineTextAlignment(.center)
        }
}

#Preview {
    AlertMessagePostDeletionView(component: "Material Title")
}
