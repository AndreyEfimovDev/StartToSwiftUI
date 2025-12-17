//
//  LegalInformationView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI
import SwiftData

struct LegalInformationView: View {

    @Environment(\.dismiss) private var dismiss
    
    let iconWidth: CGFloat = 18

    var body: some View {
        Form {
            NavigationLink("Terms of Use") {
                TermsOfUse(isTermsOfUseAccepted: .constant(true))
            }
            .customListRowStyle(
                iconName: "hand.raised",
                iconWidth: iconWidth
            )

            NavigationLink("Privacy Policy") {
                PrivacyPolicy()
            }
            .customListRowStyle(
                iconName: "lock",
                iconWidth: iconWidth
            )

            NavigationLink("Copyright/DMCA Policy") {
                CopyrightPolicy()
            }
            .customListRowStyle(
                iconName: "c.circle",
                iconWidth: iconWidth
            )

            NavigationLink("Fair Use Notice") {
                FairUseNotice()
            }
            .customListRowStyle(
                iconName: "book",
                iconWidth: iconWidth
            )

        } // Form
        .foregroundStyle(Color.mycolor.myAccent)
        .navigationTitle("Legal Information")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView() { dismiss() }
            }
        }
        .padding(.vertical)

    }
}

#Preview {
    let container = try! ModelContainer(for: Post.self, Notice.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    
    let vm = PostsViewModel(modelContext: context)
    
    NavigationStack{
        LegalInformationView()
    }
    .environmentObject(vm)
}
