//
//  LegalInformationView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct LegalInformationView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            NavigationLink("Terms of Use") {
                TermsOfUse() {}
            }
            NavigationLink("Privacy Policy") {
                PrivacyPolicy()
            }
            
            NavigationLink("Copyright/DMCA Policy") {
                CopyrightPolicy()
            }
            
            NavigationLink("Fair Use Notice") {
                FairUseNotice()
            }
            
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
