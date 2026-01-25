//
//  ThankfullnessView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 18.11.2025.
//

import SwiftUI

struct Acknowledgements: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - Body
    
    var body: some View {
        FormCoordinatorToolbar(
            title: "Acknowledgements",
            showHomeButton: true
        ) {
            ScrollView {
                acknowledgementText
                    .multilineTextAlignment(.leading)
                    .textFormater()
                    .padding()
            }
        }
    }
    
    // MARK: - Content
    
    private var acknowledgementText: Text {
        Text("""
            **\(Links.seanAllen)** – thank you for giving me a head start in learning SwiftUI through the first lessons of your full courses: *\(Links.absoluteBeginner)*, *\(Links.beginnerFriendly)*, and *\(Links.basicTutorial)*, as well as for your invaluable advice in *\(Links.tips)*.
            
            **\(Links.paulHudson)** – thank you for creating and sharing the *\(Links.unwrap)* app, which provided a structured path for my initial learning of all the fundamental features, and for the comprehensive *\(Links.byExample)* collection.
            
            **\(Links.softwareAndersBlog)** – thank you for practical examples of using SwiftUI that provided a deeper understanding of SwiftUI in practice.
            
            **\(Links.nickSarno)** – a special thank you for creating such extensive, clear, and well-organised learning materials which were invaluable for bridging the gap between theory and practice. Personally, Nick's resources have advanced my skills the most. If I were to start my learning journey again, I would begin with his materials.
            
            Lastly, thank you to anyone I may have inadvertently missed, and to everyone who has accompanied me on this year-long journey.
            """)
    }
}

// MARK: - Links

private extension Acknowledgements {
    enum Links {
        static let seanAllen = link("Sean Allen", url: "https://www.youtube.com/c/SeanAllen")
        static let absoluteBeginner = link("Swift Programming Tutorial (Absolute Beginner)", url: "https://www.youtube.com/watch?v=CwA1VWP0Ldw")
        static let beginnerFriendly = link("SwiftUI Fundamentals (Beginner Friendly)", url: "https://www.youtube.com/watch?v=b1oC7sLIgpI")
        static let basicTutorial = link("SwiftUI Basic Tutorial", url: "https://www.youtube.com/watch?v=HXoVSbwWUIk")
        static let tips = link("37 Tips for Junior Software Developers", url: "https://www.youtube.com/watch?v=jZ_BzV0DA58")
        
        static let paulHudson = link("Paul Hudson", url: "https://www.hackingwithswift.com")
        static let unwrap = link("Unwrap", url: "https://apps.apple.com/ru/app/unwrap/id1440611372?l=en-GB")
        static let byExample = link("SwiftUI by Example", url: "https://www.hackingwithswift.com/quick-start/swiftui")
        
        static let softwareAndersBlog = link("SoftwareAnders blog", url: "https://softwareanders.com")
        
        static let nickSarno = link("Nick Sarno", url: "https://www.youtube.com/@SwiftfulThinking")
        
        private static func link(_ title: String, url: String) -> AttributedString {
            var attributedString = AttributedString(title)
            attributedString.link = URL(string: url)
            attributedString.foregroundColor = Color.mycolor.myBlue
            return attributedString
        }
    }
}
#Preview {
    NavigationStack {
        Acknowledgements()
            .environmentObject(AppCoordinator())
    }
}
