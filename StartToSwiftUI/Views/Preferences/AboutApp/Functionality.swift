//
//  Functionality.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 27.01.2026.
//

import SwiftUI

struct Functionality: View {
    
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: BODY

    var body: some View {
        FormCoordinatorToolbar(
            title: "Functionality",
            showHomeButton: true
        ) {
            descriptionText
        }
    }
    
    // MARK: Subviews
    
    private var descriptionText: some View {
        ScrollView {
            Text("""
               Here are some tips to help you easily navigate the app and explore its functionality.
               
               **Home View**
               In the app:
               - tap on the material -> material detrails
               - swip right -> mark/umark the material as favourite
               - swip left -> edit or delete the material
               - long-press -> update the study progress
               - double-tap -> rate the material
               
               **Widget**
               On iPhone/iPad device:
               - long-press on the Home Screen
               - click the +/Edit in the upper left corner
               - find 'SwiftUI Study'
               - select the size (Small / Medium / Large)
               - click Add Widget

               The rest should be self-explanatory.
               
               """)
            
            .multilineTextAlignment(.leading)
            .textFormater()
            .padding()
        }
    }


}

#Preview {
    NavigationStack {
        Functionality()
            .environmentObject(AppCoordinator())
    }
}
