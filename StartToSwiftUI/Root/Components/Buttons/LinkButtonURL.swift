//
//  ButtonURL.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 18.11.2025.
//

import SwiftUI

struct LinkButtonURL: View {
    
    let buttonTitle: String
    let urlString: String
    
    var body: some View {
        
        if let url = URL(string: urlString) {
            Link(destination: url){
                Text(buttonTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mycolor.mySectionBackground)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.mycolor.myRed)
//                    .clipShape(Capsule())
                    .background(
                        Color.mycolor.myRed,
                        in: .capsule
                    )
//                    .padding(.horizontal, 40)
            }
        }
    }

}

#Preview {
    ZStack {
        Color.blue.opacity(0.1)
            .ignoresSafeArea()
        LinkButtonURL(buttonTitle: "Watch the Source", urlString: "https://developer.apple.com")
    }
}
