//
//  ThankfullnessView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 18.11.2025.
//

import SwiftUI

struct Acknowledgements: View {
    //    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    let seanAllen: AttributedString = {
        var attributedString = AttributedString("Sean Allen")
        attributedString.link = URL(string: "https://www.youtube.com/c/SeanAllen")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    let absoluteBeginner: AttributedString = {
        var attributedString = AttributedString("Swift Programming Tutorial (Absolute Beginner)")
        attributedString.link = URL(string: "https://www.youtube.com/watch?v=CwA1VWP0Ldw")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    let beginnerFriendly: AttributedString = {
        var attributedString = AttributedString("SwiftUI Fundamentals (Beginner Friendly)")
        attributedString.link = URL(string: "https://www.youtube.com/watch?v=b1oC7sLIgpI")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    let basicTutorial: AttributedString = {
        var attributedString = AttributedString("SwiftUI Basic Tutorial")
        attributedString.link = URL(string: "https://www.youtube.com/watch?v=HXoVSbwWUIk")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    let tips: AttributedString = {
        var attributedString = AttributedString("37 Tips for Junior Software Developers")
        attributedString.link = URL(string: "https://www.youtube.com/watch?v=jZ_BzV0DA58")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    
    let paulHudson: AttributedString = {
        var attributedString = AttributedString("Paul Hudson")
        attributedString.link = URL(string: "https://www.hackingwithswift.com")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    let unwrap: AttributedString = {
        var attributedString = AttributedString("Unwrap")
        attributedString.link = URL(string: "https://apps.apple.com/ru/app/unwrap/id1440611372?l=en-GB")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    let byExample: AttributedString = {
        var attributedString = AttributedString("SwiftUI by Example")
        attributedString.link = URL(string: "https://www.hackingwithswift.com/quick-start/swiftui")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    
    let softwareAndersBlog: AttributedString = {
        var attributedString = AttributedString("SoftwareAnders blog")
        attributedString.link = URL(string: "https://softwareanders.com")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    
    let nickSarno: AttributedString = {
        var attributedString = AttributedString("Nick Sarno")
        attributedString.link = URL(string: "https://www.youtube.com/@SwiftfulThinking")
        attributedString.foregroundColor = Color.mycolor.myBlue
        return attributedString
    }()
    
    var body: some View {
        ViewWrapperWithCustomNavToolbar(
            title: "Acknowledgements",
            showHomeButton: true
        ) {
            ScrollView {
                Text("""
                    **\(seanAllen)** – thank you for giving me a head start in learning SwiftUI through the first lessons of your full courses: *\(absoluteBeginner)*, *\(beginnerFriendly)*, and *\(basicTutorial)*, as well as for your invaluable advice in *\(tips)*.
                    
                    **\(paulHudson)** – thank you for creating and sharing the *\(unwrap)* app, which provided a structured path for my initial learning of all the fundamental features, and for the comprehensive *\(byExample)* collection.
                    
                    **\(softwareAndersBlog)** – thank you for practical examples of using SwiftUI that provided a deeper understanding of SwiftUI in practice.
                    
                    **\(nickSarno)** – a special thank you for creating such extensive, clear, and well-organised learning materials which were invaluable for bridging the gap between theory and practice. Personally, Nick's resources have advanced my skills the most. If I were to start my learning journey again, I would begin with his materials.
                    
                    Lastly, thank you to anyone I may have inadvertently missed, and to everyone who has accompanied me on this year-long journey.
                    """)
                .multilineTextAlignment(.leading)
                .textFormater()
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        Acknowledgements()
            .environmentObject(NavigationCoordinator())
    }
}
