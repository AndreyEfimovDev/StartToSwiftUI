//
//  WhatsNew.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct WhatsNewView: View {
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                ForEach(WhatsNews.releases) { release in
                    
                    Text(release.release)
                        .bold()
                    VStack (spacing: 20) {
                        ForEach(release.news) { news in
                            VStack (alignment: .leading) {
                                Text(news.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.mycolor.myBlue)
                                    .padding(.bottom, 4)
                                Text(news.newsText)
                                    .font(.callout)
                                    .foregroundStyle(Color.mycolor.myAccent)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } // ForEach 2nd
                    } // VStack
                    .padding(.vertical)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.mycolor.myAccent.opacity(0.3), lineWidth: 1)
                    )
                } // ForEach 1st
                .padding()
            }
            .navigationTitle("What's New")
            .navigationBarBackButtonHidden(true)
//            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WhatsNewView()
    }
}
