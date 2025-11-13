//
//  textMoreLessButton.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.08.2025.
//

import SwiftUI

struct MoreLessTextButton: View {
    
    @Binding var showText: Bool
    
    var body: some View {
        Button{
            withAnimation(.smooth) {
                showText.toggle()
            }
        } label: {
            Text(showText ? "less... \(Image(systemName: "arrow.up.to.line.compact"))" : "...more \(Image(systemName: "arrow.down.to.line.compact"))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.mycolor.myBlue)
                .frame(minWidth: 60, alignment: .leading)
                .padding(8)
        } // label
    }
}

#Preview {
    VStack{
        MoreLessTextButton(showText: .constant(true))
        MoreLessTextButton(showText: .constant(false))
    }
}
