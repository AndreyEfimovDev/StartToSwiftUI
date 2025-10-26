//
//  SwipeListButton.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 26.10.2025.
//

import SwiftUI


struct SwipeListButton: View {
    
    let mainImageName: String
    let minorImageName: String
    let size: CGFloat
    let ratio: CGFloat
    let buttonColor: Color
    let isToChangeImage: Bool
    let action: () -> ()
    
    init(
        systemImageName: String,
        minorImageName: String = "apple.logo",
        size: CGFloat,
        ratio: CGFloat,
        buttonColor: Color,
        isToChangeImage: Bool = false,
        action: @escaping () -> Void
    ) {
        self.mainImageName = systemImageName
        self.minorImageName = minorImageName
        self.size = size
        self.ratio = ratio
        self.buttonColor = buttonColor
        self.isToChangeImage = isToChangeImage
        self.action = action
    }
    
    var body: some View {
        
        Button(action: {
            withAnimation {
                action()
            }
            print(mainImageName + " tapped")
            
        }) {
            ZStack {
                Color.mycolor.mySectionBackground
                    .ignoresSafeArea()

                VStack {
                    Image(systemName: isToChangeImage ? minorImageName : mainImageName)
                    //                    .foregroundColor(.white)
                        .padding(0.5)
                    
                    Text("Name")
                        .font(.caption)
                }
            }
            .foregroundColor(Color.mycolor.myAccent)
            .frame(width: size/ratio, height: size)
            .background(.black.opacity(0.001))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.clear)
                    .stroke(buttonColor, lineWidth: 1)
            )
        }
        .padding(1)
    }
}



#Preview {
    SwipeListButton(
        systemImageName: "star.fill",
        size: 100,
        ratio: 1.5,
        buttonColor: Color.mycolor.myYellow) {}
}
