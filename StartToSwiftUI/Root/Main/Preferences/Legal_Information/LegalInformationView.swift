//
//  LegalInformationView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct LegalInformationView: View {

    @Environment(\.dismiss) private var dismiss
    
    let iconWidth: CGFloat = 18

    var body: some View {
        Form {
            NavigationLink("Terms of Use") {
                TermsOfUse() {}
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
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }

    }
}

#Preview {
    NavigationStack{
        LegalInformationView()
    }
    .environmentObject(PostsViewModel())
}
