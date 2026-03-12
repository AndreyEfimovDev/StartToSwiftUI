//
//  WhatsNew.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct WhatsNewView: View {
    
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: BODY

    var body: some View {
        FormCoordinatorToolbar(
            title: "What's New",
            showHomeButton: true
        ) {
            descriptionText
        }
    }
    
    // MARK: Subviews
    
    private var descriptionText: some View {
        ScrollView {
            VStack (alignment: .leading) {
                ForEach(WhatsNews.releases) { release in
                    
                    Text(release.release)
                        .font(.footnote)
                        .bold()
                        .padding(.top)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    VStack (spacing: 10) {
                        ForEach(release.news) { news in
                            VStack (alignment: .leading) {
                                Text(news.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.mycolor.myBlue)
                                    .padding(.bottom, 4)
                                Text(news.newsText)
                                    .font(.callout)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.mycolor.myAccent.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
            }
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}

#Preview {
    NavigationStack {
        WhatsNewView()
            .environmentObject(AppCoordinator())
    }
}
