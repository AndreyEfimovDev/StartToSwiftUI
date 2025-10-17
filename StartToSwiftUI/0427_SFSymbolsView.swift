//
//  0427_SFSymbolsView.swift
//  EasySelfStudyOfEnglish
//
//  Created by Andrey Efimov on 27.04.2025.
//

import SwiftUI

struct _427_SFSymbolsView: View {
    
    @State var valueToUse: Int = 0
    @State var isDeleted: Bool = false
    
        var body: some View {
            Image(systemName: "trash")
                .font(.system(size: 50, weight: .bold))
                .symbolEffect(.pulse, value: valueToUse)
            Divider()
            Image(systemName: "trash")
                .font(.system(size: 50, weight: .bold))
                .symbolEffect(.bounce, value: valueToUse)
            Divider()
            HStack {
                Image(systemName: "wifi")
                    .font(.system(size: 50, weight: .bold))
                    .symbolEffect(.variableColor, value: valueToUse)
                
                Image(systemName: "wifi")
                    .font(.system(size: 50, weight: .bold))
                    .symbolEffect(.variableColor.iterative, value: valueToUse)
                
                Image(systemName: "wifi")
                    .font(.system(size: 50, weight: .bold))
                    .symbolEffect(.variableColor.hideInactiveLayers, value: valueToUse)
                
        
            }
            
            Text ("\(valueToUse)")
            
            Button {
                valueToUse+=1
            }label: {
                Text("Make animation")
            }
            .buttonStyle(.borderedProminent)
            
            Image(systemName: isDeleted ? "trash.slash" : "trash")
                .font(.system(size: 50, weight: .bold))
                .contentTransition(.symbolEffect(.replace))
            
            
            Button {
                isDeleted.toggle()
            }label: {
                Text("Delete/Undelete")
            }
            .buttonStyle(.bordered)
        }
}

#Preview {
    _427_SFSymbolsView()
}
