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
    @StateObject private var speechRecogniser = SpeechRecogniser()
    
//    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
//    @Environment(\.verticalSizeClass) private var verticalSizeClass


//    @State private var windowSize: CGSize = .zero
//    @State private var isFullScreen: Bool = false
    
    var body: some View {
        
        if UIDevice.isiPad {
            // iPad - NavigationSplitView
            SidebarView()
        } else {
            //    iPhone - NavigationStack (portrait only)
            NavigationStack{
                if let selectedCategory = vm.selectedCategory {
                    HomeView(selectedCategory: selectedCategory)
                }
                
            }
        }
//        else {
//            ContentUnavailableView(
//                "Can't detect the UIDevice",
//                image: "ipad.landscape.and.iphone.slash", // macbook.and.iphone
//                description: Text("Can't detect the UIDevice")
//            )
//        }
    }
}

#Preview {
    RootView()
        .environmentObject(PostsViewModel())
        .environmentObject(NoticeViewModel())
        .environmentObject(SpeechRecogniser())

}


//VStack {
//    HStack {
//        Text("Horizontal: \(horizontalSizeClass == .regular ? "Regular" : "Compact")")
//        Text("Vertical: \(verticalSizeClass == .regular ? "Regular" : "Compact")")
//    }
//    .font(.caption)
//    .foregroundColor(.red)
//    
//    // Проверка режима отображения
//    Text("Режим отображения:")
//        .font(.headline)
//    
//    Text(isFullScreen ? "✅ Полноэкранный" : "⚠️ Split View/Slide Over")
//        .foregroundColor(isFullScreen ? .green : .orange)
//        .bold()
//    
//    Text("Размер окна: \(windowSize.width, specifier: "%.0f")×\(windowSize.height, specifier: "%.0f")")
//    
//    Spacer()
//}
//        .onAppear {
//checkDisplayMode()
//}

//private func checkDisplayMode() {
//    DispatchQueue.main.async {
//        guard let window = UIApplication.shared.windows.first else { return }
//        self.windowSize = window.bounds.size
//        
//        // Проверяем, занимает ли окно весь экран
//        let screenSize = UIScreen.main.bounds.size
//        self.isFullScreen = windowSize.width == screenSize.width && windowSize.height == screenSize.height
//        
//        print("""
//        🪟 Window Size: \(windowSize)
//        📺 Screen Size: \(screenSize)
//        🎯 Is Full Screen: \(isFullScreen)
//        """)
//    }
//}





    
