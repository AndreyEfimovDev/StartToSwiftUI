//
//  CircleButtonView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI

struct ShareButton: View {
    
    private let fileManager = FileStorageManager.shared
    
    var body: some View {
        
        VStack(spacing: 20) {

            if let fileURL = fileManager.getFileURL(fileName: "posts.json") {
                ShareLink(item: fileURL) {
                    VStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                    .foregroundStyle(Color.mycolor.myAccent)

                                Text("Share")
                                    .font(.caption)
                                    .foregroundStyle(Color.mycolor.mySecondaryText)
                            }
                    .padding(8)
                    .padding(.horizontal, 14)
                    .background(Color.black.opacity(0.001))
                    .border(.blue)
                }
            }
            else {
                Text("File is no found")
                    .font(.headline)
                    .foregroundStyle(Color.mycolor.myRed)
                    .frame(width: 200, height: 100)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.mycolor.myAccent.opacity(0.1), lineWidth: 1)
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ZStack {
//        Color.black.ignoresSafeArea()
        ShareButton()
    }
}
