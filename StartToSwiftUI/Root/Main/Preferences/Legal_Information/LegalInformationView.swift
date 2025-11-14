//
//  LegalInformationView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct LegalInformationView: View {

//    @Environment(\.dismiss) private var dismiss
    let iconWidth: CGFloat = 18

    var body: some View {
        Form {
            NavigationLink("Terms of Use") {
                TermsOfUse() {}
            }
            .customPreferencesListRowStyle(
                iconName: "hand.raised",
                iconWidth: iconWidth
            )

            NavigationLink("Privacy Policy") {
                PrivacyPolicy()
            }
            .customPreferencesListRowStyle(
                iconName: "lock",
                iconWidth: iconWidth
            )

            NavigationLink("Copyright/DMCA Policy") {
                CopyrightPolicy()
            }
            .customPreferencesListRowStyle(
                iconName: "c.circle",
                iconWidth: iconWidth
            )

            NavigationLink("Fair Use Notice") {
                FairUseNotice()
            }
            .customPreferencesListRowStyle(
                iconName: "book",
                iconWidth: iconWidth
            )

        } // Form
        .foregroundStyle(Color.mycolor.myAccent)
        .navigationTitle("Legal Information")
    }
}

#Preview {
    NavigationStack{
        LegalInformationView()
    }
    .environmentObject(PostsViewModel())
}
