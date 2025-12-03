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
                        .font(.footnote)
                        .bold()
                        .padding(.top)
                        .padding(.leading)
                    VStack (spacing: 10) {
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
                .padding(.horizontal)
            }
            .navigationTitle("What's New")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButtonView() { dismiss() }
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
