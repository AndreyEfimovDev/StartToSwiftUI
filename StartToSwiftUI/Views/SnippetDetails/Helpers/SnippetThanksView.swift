//
//  SnippetThanksView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.03.2026.
//

import SwiftUI

struct SnippetThanksView: View {
    
    let thanks: String
    
    var body: some View {
        Text("Source: @\(thanks)")
            .font(.caption)
            .foregroundStyle(Color.mycolor.myAccent.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 4)
    }
}

#Preview {
    SnippetThanksView(thanks: "Thanks String")
}
