//
//  WhatsNew.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct WhatsNew: View {
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
//                                    .border(.red)
                                Text(news.newsText)
                                    .font(.callout)
                                    .foregroundStyle(Color.mycolor.myAccent)
//                                    .border(.yellow)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .border(.green)

//                            .border(.red)
                        } // ForEach 2nd
                    } // VStack
                    .padding(.vertical)
                    .background(.ultraThinMaterial)
//                                    .border(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.mycolor.myAccent.opacity(0.3), lineWidth: 1)
                    )
                } // ForEach 1st
                .padding(.horizontal)
            }
            .navigationTitle("What's New")
        }
    }
}

#Preview {
    NavigationStack {
        WhatsNew()
    }
}
