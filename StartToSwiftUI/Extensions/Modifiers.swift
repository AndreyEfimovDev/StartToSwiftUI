//
//  Modifiers.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 19.09.2025.
//

import SwiftUI


struct TapAndDoubleTapModifier: ViewModifier {
    let singleTap: () -> Void
    let doubleTap: () -> Void
    
    @State private var tapCount = 0
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                tapCount += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if tapCount == 1 {
                        singleTap()
                    } else if tapCount == 2 {
                        doubleTap()
                    }
                    tapCount = 0
                }
            }
    }
}


//struct Modifiers: View {
//    var body: some View {
//        VStack {
//            
//            Image(systemName: "square.and.arrow.up")
//               .shareLink("https://www.apple.com")
//            
//            Text("Share")
//                .font(.caption2)
//        }
//    }
//}
//
//#Preview {
//    Modifiers()
//}
//
//
//struct ActivityView: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    let applicationActivities: [UIActivity]?
//    
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(
//            activityItems: activityItems,
//            applicationActivities: applicationActivities
//        )
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // Ничего не нужно обновлять
//    }
//}
//
//
//struct ShareLinkModifier: ViewModifier {
//    let urlString: String
//    @State private var showingShareSheet = false
//    
//    func body(content: Content) -> some View {
//        content
//            .onTapGesture {
//                if URL(string: urlString) != nil {
//                    showingShareSheet = true
//                    
//                    // Haptic feedback
//                    let generator = UIImpactFeedbackGenerator(style: .medium)
//                    generator.impactOccurred()
//                }
//            }
//            .sheet(isPresented: $showingShareSheet) {
//                if let url = URL(string: urlString) {
//                    ActivityView(activityItems: [url], applicationActivities: nil)
//                }
//            }
//    }
//}
//
//
//extension View {
//    func shareLink(_ urlString: String) -> some View {
//        self.modifier(ShareLinkModifier(urlString: urlString))
//    }
//}
//
//// Использование
//// Image(systemName: "square.and.arrow.up")
////    .shareLink("https://www.apple.com")
//
