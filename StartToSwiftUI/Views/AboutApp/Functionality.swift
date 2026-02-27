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
               
               **Home View Navigation**
               - Tap on a item to see its Details
               - Swipe right on an item to Add or Remove from Favourites
               - Swipe left on an item to Edit, Hide, or move to Deleted (restorable)
               - Press and hold on an item to Update your Study Progress
               - Double-tap on an item to Rate the material
               - Pull down to Refresh the list of materials
               
               **Create Own Study Content**
               - Title
               - Intro description
               - Author's name
               - Type (Lesson, Course, Article)
               - Study level (Beginner, Middle, Advanced)
               - Platform (Website, YouTube)
               - Date of publication (if known)
               - Link to the material
               - Personal notes
               
               **Add Widgets**
               - Touch and hold an empty area on your Home Screen until the apps jiggle
               - Tap the '+' button in the top-left corner
               - Search for "SwiftUI Study" in the widget gallery
               - Select your preferred widget size (Small, Medium, or Large)
               - Tap Add Widget, then tap Done

               **Icons**
               *Drafts*
                \(Image(systemName: "square.stack.3d.up")) - draft
               *Favourite choice*
                \(FavoriteChoice.yes.icon) - yes
                \(FavoriteChoice.no.icon) - no
               *Original source*
                \(PostOrigin.local.icon) - created locally
                \(PostOrigin.cloud.icon) - loaded from cloud (curated collection)
                \(PostOrigin.cloudNew.icon) - recently loaded from cloud
               *Study progress*
                \(StudyProgress.added.icon) - added
                \(StudyProgress.started.icon) - started 
                \(StudyProgress.studied.icon) - learnt
                \(StudyProgress.practiced.icon) - practiced
               *Rating*
                \(PostRating.good.icon) - good
                \(PostRating.great.icon) - great
                \(PostRating.excellent.icon) - excellent               
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
