//
//  LegalInformationView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI
import SwiftData

struct LegalInformationView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    let iconWidth: CGFloat = 18

    var body: some View {
        ViewWrapperWithCustomNavToolbar(
            title: "Legal Information",
            showHomeButton: true
        ) {
            Form {
                Button("Terms of Use") {
                    coordinator.pushModal(.termsOfUse)
                }
                .customListRowStyle(
                    iconName: "hand.raised",
                    iconWidth: iconWidth
                )

                Button("Privacy Policy") {
                    coordinator.pushModal(.privacyPolicy)
                }
                .customListRowStyle(
                    iconName: "lock",
                    iconWidth: iconWidth
                )

                Button("Copyright/DMCA Policy") {
                    coordinator.pushModal(.copyrightPolicy)
                }
                .customListRowStyle(
                    iconName: "c.circle",
                    iconWidth: iconWidth
                )

                Button("Fair Use Notice") {
                    coordinator.pushModal(.fairUseNotice)
                }
                .customListRowStyle(
                    iconName: "book",
                    iconWidth: iconWidth
                )

            }
            .foregroundStyle(Color.mycolor.myAccent)
        }
        .padding(.vertical)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack{
        LegalInformationView()
    }
    .environmentObject(vm)
    .environmentObject(NavigationCoordinator())
}
