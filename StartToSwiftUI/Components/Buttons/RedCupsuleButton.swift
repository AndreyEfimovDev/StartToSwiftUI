//
//  RedCupsuleButton.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.08.2025.
//

import SwiftUI

struct RedCupsuleButton: View {
    
    let title: String
    
    var body: some View {
        
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.mycolor.myRed)
            .foregroundColor(Color.mycolor.myBackground)
            .cornerRadius(30)
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.1)
            .ignoresSafeArea()
        RedCupsuleButton(title: "Watch the Source")
    }
}
