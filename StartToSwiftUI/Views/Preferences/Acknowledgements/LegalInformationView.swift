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
        Form {
            Button("Terms of Use") {
                coordinator.push(.termsOfUse)
            }
            .customListRowStyle(
                iconName: "hand.raised",
                iconWidth: iconWidth
            )

            Button("Privacy Policy") {
                coordinator.push(.privacyPolicy)
            }
            .customListRowStyle(
                iconName: "lock",
                iconWidth: iconWidth
            )

            Button("Copyright/DMCA Policy") {
                coordinator.push(.copyrightPolicy)
            }
            .customListRowStyle(
                iconName: "c.circle",
                iconWidth: iconWidth
            )

            Button("Fair Use Notice") {
                coordinator.push(.fairUseNotice)
            }
            .customListRowStyle(
                iconName: "book",
                iconWidth: iconWidth
            )

        }
        .foregroundStyle(Color.mycolor.myAccent)
        .navigationTitle("Legal Information")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView() {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.popToRoot()
                } label: {
                    Image(systemName: "house")
                        .foregroundStyle(Color.mycolor.myAccent)
                }
            }
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
