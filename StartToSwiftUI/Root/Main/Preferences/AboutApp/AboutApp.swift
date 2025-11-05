//
//  AboutApp.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct AboutApp: View {
    
    let frameHeight: CGFloat = 30
    
    var body: some View {
//        ScrollView {
            VStack(spacing: 0) {
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 0)
                
                HStack {
                    Text("Name")
                    Spacer()
                    Text("StartToSwiftUI")
                }
                .padding(.horizontal)
                .frame(height: frameHeight)
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 0)
                
                HStack {
                    Text("Version")
                    Spacer()
                    Text("01.01.01")
                }
                .padding(.horizontal)
                .frame(height: frameHeight)
                .frame(maxWidth: .infinity)
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 0)
                
                HStack {
                    Text("Developed by")
                    Spacer()
                    Text("Andrey Efimov")
                }
                .padding(.horizontal)
                .frame(height: frameHeight)
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 0)
                    .padding(.bottom, 0)
                
            }
            .padding(.horizontal)
            
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
            .navigationTitle("About App")
//        }
    }
}


#Preview {
    AboutApp()
}
