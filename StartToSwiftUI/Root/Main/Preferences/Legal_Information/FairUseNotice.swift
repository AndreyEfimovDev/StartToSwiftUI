//
//  FairUseNotice.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 05.11.2025.
//

import SwiftUI

struct FairUseNotice: View {
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            Text("""
                    **StartToSwiftUI** operates in accordance with fair use principles for educational purposes. Our application is designed to be a legal and respectful tool for learners.
                    
                    **Why the Application is Legitimate:**
                    
                    **Educational Purpose**: The app serves exclusively for non-commercial educational use, helping users organise learning materials.
                    
                    **Links, Not Content**: We store only references to materials through links, never copying, hosting, or distributing the actual content.
                    
                    **Author Attribution**: Complete authorship information is preserved and displayed for each resource (author name, source, publication date).
                    
                    **Direct Source Access**: All links lead directly to original sources, ensuring content creators receive proper traffic and recognition.
                    
                    The application acts as an organisational tool that respects intellectual property rights while supporting the educational community. We encourage users to always access materials through the original sources and respect creators' rights.
                    """)
            .multilineTextAlignment(.leading)
            .managingPostsTextFormater()
            .padding(.horizontal)
        }
        .navigationTitle("Fair Use Notice")
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
    FairUseNotice()
}
