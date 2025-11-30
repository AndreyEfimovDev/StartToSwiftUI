//
//  MainView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.11.2025.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    @EnvironmentObject private var noticevm: NoticeViewModel

    var body: some View {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
//            // iPad - NavigationSplitView
            SidebarView()
        } else {
            // iPhone - NavigationStack (portrait only)
            HomeView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(PostsViewModel())
        .environmentObject(NoticeViewModel())

}
