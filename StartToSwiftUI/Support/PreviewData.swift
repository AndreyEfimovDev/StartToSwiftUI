//
//  PreviewData.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.08.2025.
//

import Foundation
import SwiftUI


struct DevPreview {
    
    //    static let shared = PreviewPosts()
    
    static let samplePost1 = Post(
        title: "Property Wrappers",
        intro: "В этом видео я расскажу вам обо всех оболочках, которые нам предлагает SwiftUI для хранения временных данных. Так же вы поймете, в чем отличие между такими оболочки как @State, @StateObject, @ObservedObject, @EnvironmentObject. Эти оболочки очень похожи друг на друга и знание того, когда и какую лучше использовать, имеет решающее значение.",
        author: "Evgenia Bruyko",
        postLanguage: .russian,
        urlString: "https://youtu.be/ExwwrvOT8mI?si=SU__YwU8UlR461Zb",
        postPlatform: .youtube,
        postDate: Date.from(year: 2021, month: 3, day: 26),
        studyLevel: .beginner,
        favoriteChoice: .yes,
        additionalText: "",
        date: .now
    )
    
    static let samplePost2 = Post(
        title: "SwiftUI Advanced Learning",
        intro: """
            Learn how to build custom views, animations, and transitions. Get familiar with coding techniques such as Dependency Injection and Protocol-Oriented Programming. Write your first unit tests and connect to CloudKit.
            """,
        author: "Swiftful Thinking",
        postType: .playlist,
        urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphc1LLLjCaEd87BEg07M97y",
        postDate: Date.from(year: 2021, month: 8, day: 30),
        studyLevel: .advanced
    )
    
    static let samplePost3 = Post(
        title: "How we can stylize text for our Text views in SwiftUI",
        intro: """
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        """,
        author: "Stewart Lynch",
        postLanguage: .english,
        urlString: "https://www.youtube.com/watch?v=rbtIcKKxQ38", //
        postPlatform: .website,
        postDate: Date.from(year: 2022, month: 8, day: 11),
        studyLevel: .middle,
        favoriteChoice: .no,
        additionalText: """
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        
        In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
        We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
        We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
        And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
        """,
        date: .now
    )
    
    static let samplePosts = [
        Post(
            title: "Property Wrappers",
            intro: "В этом видео я расскажу вам обо всех оболочках, которые нам предлагает SwiftUI для хранения временных данных. Так же вы поймете, в чем отличие между такими оболочки как @State, @StateObject, @ObservedObject, @EnvironmentObject. Эти оболочки очень похожи друг на друга и знание того, когда и какую лучше использовать, имеет решающее значение.",
            author: "Evgenia Bruyko",
            postLanguage: .russian,
            urlString: "https://youtu.be/ExwwrvOT8mI?si=SU__YwU8UlR461Zb",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 3, day: 26),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now
        ),
        Post(
            title: "Styling SwiftUI Text Views",
            intro: """
            In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
            We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
            We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
            And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
            """,
            author: "Stewart Lynch",
            postLanguage: .english,
            urlString: "https://www.youtube.com/watch?v=rbtIcKKxQ38",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 5, day: 7),
            studyLevel: .middle,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Customizing the appearance of symbol images in SwiftUI",
            intro: "Symbol images are vector-based icons from Apple's SF Symbols library, designed for use across Apple platforms. These scalable images adapt to different sizes and weights, ensuring consistent, high-quality icons throughout our apps. Using symbol images in SwiftUI is straightforward with the Image view and the system name of the desired symbol.",
            author: "Natalia Panferova",
            postLanguage: .english,
            urlString: "https://nilcoalescing.com/blog/CustomizingTheAppearanceOfSymbolImagesInSwiftUI/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 9, day: 22),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "ViewBuilder: Organize your views",
            intro: "ViewBuilders in SwiftUI are an excellent way to keep your code clean and organized. They make your code easier to read and maintain by allowing you to structure your views more clearly. This simplifies the process of building complex user interfaces, ensuring that your code remains elegant and efficient. Embracing ViewBuilders enhances both the readability and manageability of your SwiftUI projects.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-viewbuilder-organize-your-views/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 27),
            studyLevel: .advanced,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "ClipShape: Shape Your Application",
            intro: """
            clipShape is a SwiftUI modifier that allows developers to define a shape that clips a view to shape it. This means that the view will be confined to the defined shape. You can create anything from circles to rectangles, it’s up to you.
                            
            In this post you will learn about ClipShape in SwiftUI. You will learn how to implement them and we will also cover the different shapes available.
            """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-clipshape-shape-your-application/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 13),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Long Press Gesture: Complete How-To Guide",
            intro: "The Long Press gesture in SwiftUI is a powerful interaction that triggers when a user presses and holds a view for a specific duration. This essential gesture recognizer is frequently implemented in modern iOS apps for context menus, drag and drop functionality, or revealing additional information to enhance user experience.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-long-press-how-to-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 7),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        
        Post(
            title: "Toggle: Turn On And Off",
            intro: """
            SwiftUI Toggle is a UI control that enables users to switch between two states, typically represented as on and off. If you are building a view where you can enable a feature, then the Toggle view is the way to go.

            With very little code you can implement a simple and effective way of getting user input. In this blog post we will cover how to implement a Toggle switch, change the color, hide the label and execute a function when turned on.
            """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-toggle-turn-on-and-off/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 2),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Animate SF Symbols",
            intro: """
                SF Symbols is a great solution for making visual tasks with developing an iOS application. Not only are they great, but there are so many different ones to choose from. If you want to make your SF Symbols stand out a bit more or create some kind of visual effect, then animating your SF Symbols is the way to go.

                In the following examples, we will discover different variations of animations, so you are ready to animate your SF Symbols.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-animate-sf-symbols/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 24),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
       
        
        
        Post(
            title: "Shadow: Create depth and dimension",
            intro: """
                Shadows can add depth, dimension, and a touch of realism to your application.

                In this blog post, we will discover how to use the shadow() modifier in effect on any view in SwiftUI and we will also cover how you can customize the shadow effect.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-shadow-create-depth-and-dimension/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 3),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        
        Post(
            title: "ShareLink: Share with ease",
            intro: """
                No matter what kind of app you are building, if your application has the feature to share data, do yourself a favor and implement ShareLink. Not only is it really easy to implement it also increases useability.

                In this blog post, we’re going to dive into SwiftUI’s ShareLink and how you can share a URL or Image with ease.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-sharelink-share-with-ease/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 28),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Launch screen: First Impressions Matters",
            intro: "In this blog post, we cover how to create a launch screen in SwiftUI, exploring why they’re not just a good idea, but a crucial element in crafting an exceptional user experience.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-launch-screen-first-impressions-matters/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 21),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
     
        Post(
            title: "Swift check network connection",
            intro: """
                Most applications nowadays use the internet. Whether you’re developing an application for the sole purpose of checking the network connection or simply trying to optimize user experience, knowing how to check network connectivity in your Swift application can be a game-changer.

                In this guide, we will check the network connection inside a SwiftUI application using NWPathMonitor, which was introduced in iOS 12.

                NB: Before diving into this guide, it’s a good idea to test on an iPhone and not the simulator.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swift-check-network-connection/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 28),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Request review: Complete guide",
            intro: """
                This article provides insights into the SwiftUI implementation of review requests, offering practical guidance on code usage and adherence to Apple’s best practices for soliciting feedback effectively.

                In this blog post we will cover how to request a review in SwitUI, we will also cover best practices on when to ask for a review and Apple’s guidelines.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-request-review-complete-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 2, day: 22),
            studyLevel: .middle,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Segmented control: Easy to follow guide",
            intro: """
                SwiftUI Segmented Control is a great and user-friendly way that allows users to choose between multiple options within a segmented, tap-friendly control.

                In this blog post, we’ll learn how to create a Segmented Control in SwiftUI and explore how to change the selected color and background color.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-segmented-control/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 2, day: 21),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Email: A Complete Guide",
            intro: """
                In today’s digital landscape, email remains a cornerstone of communication, seamlessly connecting users worldwide. This guide caters to developers of all skill levels, offering a concise walkthrough from project setup to email composition and dispatch within your SwiftUI app.

                In this blog post, we’ll explore how to send emails using SwiftUI, both with and without an attachment.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-email-a-complete-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 12),
            studyLevel: .middle,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Material: How to use material",
            intro: """
                When you want to create a blurred background, you should differently use SwiftUI material. Material was launched in SwiftUI 3 and is a great way of making a blurred background or see through view, Apple has provided an easy way of making a blur effect as a background.

                In this blog post, you will learn what Material is and how you use it and we will create an example with a view where we use material.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-material-how-to-use-material/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 1, day: 14),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
// 3 page
        Post(
            title: "Blur: A short guide",
            intro: """
                The blur effect is a visual enhancement technique used in graphic design and user interface development to create a sense of depth, focus, or aesthetic appeal.

                In SwiftUI, the blur effect is achieved using the blur modifier. This modifier allows developers to apply a blur to any SwiftUI view.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-blur-a-short-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 1, day: 11),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Pull to refresh: Easy guide",
            intro: """
                SwiftUI Pull-to-Refresh is an essential feature in most apps, people just expect to be able to pull to refresh on lists of data. Pull to refresh allows users to update content effortlessly by pulling down on a view. 

                In this blog post, we will explore the implementation of SwiftUI Pull to Refresh, its benefits, and the steps to integrate this feature into your application.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-pull-to-refresh-easy-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 12, day: 29),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Link: How to guide",
            intro: "Link is a great and hassle-free way of opening a website from your application. In this article, we will cover how you use SwiftUI Link and how you can customize it to fit inside your application.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-link-how-to-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 12, day: 28),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Divider: A powerful line",
            intro: """
                SwiftUI divider is a simple yet powerful element that plays a crucial role in crafting visually appealing and well-structured interfaces. 

                In this blog post, we’ll explore the SwiftUI Divider and how it can elevate your app’s design and how to customize it to fit in your application.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-divider-a-powerful-line/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 12, day: 20),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Swift convert strings into different data types: Easy guide",
            intro: """
                As a software developer, you often encounter scenarios where you need to convert data from one type to another, and string conversion is a fundamental skill to master. 

                In this blog post, we’ll explore the art of converting strings into different data types like int, date, double and you will also learn how to convert your strings and prevent your app from crashing if it’s a wrong data type.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/converting-strings-into-different-data-types-easy-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 12, day: 8),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "ColorPicker: A complete guide to Color Selection",
            intro: """
                SwiftUI ColorPicker enhances the user experience by providing an interactive and visually pleasing way to select colors. 

                In this blog post dive into the SwiftUI ColorPicker, exploring its functionality and how it simplifies the process of color selection within your SwiftUI applications.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-colorpicker-a-complete-guide-to-color-selection/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 28),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Swipe Actions: Complete guide with examples",
            intro: "One awesome and helpful feature in SwiftUI that enhances user interaction is swipe actions. In this blog post, we’ll explore the world of SwiftUI swipe actions, we will learn how to implement them and customize them to fit into your application, so you can provide even more value for your users.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-swipe-actions-complete-guide-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 27),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "SF Symbols: A easy guide",
            intro: """
                SwiftUI SF Symbols stand out as a powerful tool for enhancing the visual appeal of your apps. These symbols, introduced by Apple, provide a vast collection of scalable, customizable icons that can breathe life into your user interface. 

                In this blog post, we’ll explore how to implement SwiftUI SF Symbols and dive into how they can be customized to fit your needs.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-sf-symbols-a-easy-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 23),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "DatePicker: Integrating dates in your app",
            intro: """
                SwiftUI DatePicker is a powerful tool that simplifies date and time selection in your iOS apps. The SwiftUI DatePicker provides a seamless way for users to choose dates and times within your app, eliminating the need for complex input forms or manual date entry. With a sleek and customizable interface, this component enhances the user experience and streamlines the development process.

                In this blog post, you will learn how to use the DatePicker in SwiftUI and how to customize it so it fits right into the style of your application.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-datepicker-integrating-dates-in-your-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 21),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
// 4 page

        Post(
            title: "TextEditor character limit",
            intro: """
                SwfitUI TextEditor is a great tool for letting your users edit large text elements, but sometimes you want to limit the character count — your backend API might have a limit. For example, Twitter (now X) has a character limit of 280.

                In this blog post, you will learn how to create a TextEditor with a limit of 280 characters. We’ll create the TextEditor in its own view so you can easily use it in different places inside your application. We will also create the character limit as a custom modifier — that way you can have different text editors with different limits.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-texteditor-character-limit/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 9),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "TextEditor: A user friendly guide",
            intro: """
                SwiftUI TextEditor is a great component that empowers developers to work with large text input and editing in SwiftUI applications. TextEditor is a dynamic, rich, and customisable solution that offers a world of possibilities for crafting engaging user interfaces.

                In this blog post, we’re going to take a deep dive into SwiftUI TextEditor, exploring its features, capabilities, and how you can use it in your application. I hope that whether you’re new to SwiftUI or a seasoned developer, this guide will provide you with insights and practical examples to unlock the full potential of TextEditor in your projects.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 7),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Line chart: Complete guide with examples",
            intro: """
                SwiftUI Line chart is a great tool to use. A line chart, also known as a line graph or a time series chart, is a type of data visualization that displays information as a series of data points connected by straight lines. It is commonly used to represent data that changes continuously over a period of time, making it an effective tool for visualising trends, patterns, and relationships in data.

                In SwiftUI it’s easy to make a line chart and in this blog post you will learn everything you need to know about line charts in SwiftUI.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-line-chart-complete-guide-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 10, day: 11),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "TabView: All you need to know",
            intro: """
                One of the fundamental components for organizing and navigating through content in a mobile application is by using a tabbar at the bottom of the screen. In this blog post, we’ll explore how we can easily create a tabbar in SwiftUI by using the native tabview. 

                In this blog post I will provide you with practical examples to help you master the native tabview.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-tabview-all-you-need-to-know/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 10, day: 10),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Menu: A complete Guide",
            intro: """
                SwiftUI menu provide a seamless and organized way to present actions and options to users and allowing developers to create powerful and interactive interfaces.

                In this post, we will explore various aspects of SwiftUI Menu. We will cover a basic example, add a image to the menu, add a checkmark and more.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-menu-a-complete-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 31),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Toolbar: A complete Guide with examples",
            intro: "Toolbar is a powerful tool for designing elegant and functional user interfaces. In this blog post, we’ll be working with the native SwiftUI Toolbar and exploring its capabilities, providing examples, and showing you how to customize things like its background color to match your app’s design.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-toolbar-a-complete-guide-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 24),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Search: Enhance User Experience with SwiftUI Searchable",
            intro: """
                To create applications that users will love, developers must embrace intuitive design and create a great user experience. When thinking user experience one important note is efficient data presentation. One way of achieving that is by implementing search in SwiftUI. SwiftUI offers a powerful tool for achieving this: the Searchable modifier.

                In this blog post, we’ll dive into SwiftUI Searchable modifier, explore its capabilities, and learn how to search simple strings and complex objects. We will also use search suggestions and search scopes.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-search-enhance-user-experience-with-swiftui-searchable/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 22),
            studyLevel: .middle,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Swift UserDefaults: All you need to know",
            intro: "Swift UserDefaults is a lightweight and convenient data persistence store provided by Apple’s Foundation framework. It allows you to store small pieces of data, such as user preferences, settings, and simple configuration values. These values are automatically saved to the device’s file system, making them accessible even after the app is closed or the device is rebooted.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swift-userdefaults-all-you-need-to-know/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 15),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "PhotoPicker: A Hands-On Guide with Examples",
            intro: """
                SwiftUI PhotoPicker is a powerful package for seamlessly integrating photo and media selection capabilities into your applications. 

                In this blog post, we’ll dive into how you can implement PhotoPicker and how you let the user pick a single image or select multiple images and of course how you can filter what kind of images they can select.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-photopicker-a-hands-on-guide-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 10),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
// 5 page
        
        Post(
            title: "ConfirmationDialog — with examples",
            intro: """
                It is important to ensure a smooth and delightful user experience thougth out your app. In iOS 15 Apple have introduced SwiftUI confirmationDialog that can help us with just that. SwiftUI confirmationDialog is a easy way for you as a developer to show a dialog with multiple choices, provide a title and a hint message to make sure your users know what to do. 

                In this blog post we will explore what SwiftUI confirmationDialiog is, how it works and give examples on how to use it in your own app.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-confirmationdialog-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 8, day: 8),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        
        Post(
            title: "TextField clear button",
            intro: """
                Creating a clear button for a TextField in SwiftUI can greatly enhance the user experience and make your app more user-friendly. This simple feature allows users to easily clear the text within the TextField, eliminating the need to manually delete characters. 

                A clear button allows users to quickly erase the content of a TextField with a single tap. It eliminates the need to manually delete characters, making it more efficient for users to correct their input or start over.

                In this blog post, I will walk you through the steps of implementing a clear button for a TextField in SwiftUI. You will learn how to quickly add a clear button to one TextField and you will also learn how to create a ViewModifier so you can reuse the solution throughout your app.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-textfield-clear-button/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 8, day: 4),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        
        Post(
            title: "TextField Placeholder: Best Practices and Tips",
            intro: "A well-crafted placeholder can greatly impact the overall user experience. In this blog post, we will explore the importance of TextField placeholders, learn how to change the color of the placeholder, use a image in placeholder and change the font. We will end the blog post with some great tips make better placeholders.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-textfield-placeholder-best-practices-and-tips/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 8, day: 3),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        
        Post(
            title: "Swift EventKit: Calendar management",
            intro: """
                With Swift EventKit framework it provides powerful capabilities for working with calendars, allowing developers to seamlessly create, edit, fetch and delete calendar events within their applications. 

                In this blog post, we will explore a full example of eventkit to create, edit, and delete calendar events, helping users stay organized and on top of their schedules. 
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swift-eventkit-calendar-management/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 7, day: 28),
            studyLevel: .middle,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Password: Show and Hide",
            intro: "When creating an app security is very important but so is convenience therefore the ability to show and hide passwords has become a crucial feature for mobile applications. In this blog post, we will explore how to create a secure text field that hides the password but also learn how to create the ability to show/hide the password.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-password-show-and-hide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 7, day: 26),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "TextField Background Color",
            intro: """
                In SwiftUI, the TextField is a versatile user interface element that allows users to input text seamlessly. One way to enhance the visual appeal and user experience of TextFields is by customizing their background colors. In this blog post, we’ll delve into different techniques for setting background colors for SwiftUI TextFields and explore creative use cases.

                In this guide about background color for textfield in SwiftUI we will cover the basics but also learn how to set a gradient background and how to change the background based on user input.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-textfield-background-color/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 7, day: 25),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "TextField: A User-Friendly Guide",
            intro: "SwiftUI’s TextField is a powerful user interface element that enables developers to effortlessly capture user input and create interactive experiences in their applications. Whether you’re a seasoned SwiftUI developer or just starting your journey, this blog post will walk you through the ins and outs of SwiftUI TextFields, providing valuable insights, use cases, and code examples along the way. Let’s dive in!",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-textfield-a-user-friendly-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 7, day: 24),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "AsyncImage: Asynchronous Image Loading",
            intro: """
                In the world of mobile app development, displaying images is a common task. However, when dealing with images, it can quickly become tough to display them fast enough while not blocking the UI thread. Luckily Apple have thought of this when creating SwiftUI and they have created a powerful solution called AsyncImage. 

                In this blog post, we’ll explore how AsyncImage simplifies the process of loading remote images in SwiftUI, making it easier and more efficient for developers — the easier it is, the happier the developer.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-asyncimage/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 28),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Alert: Best Practices and Examples",
            intro: "When creating a mobile app it’s important to notify the users when something happens like an API request went OK or failed. With SwiftUI Alerts, you can quickly inform users, gather input, and prompt them to take specific actions. In this article, we’ll explore the power of SwiftUI Alerts and learn how to leverage them to enhance user interaction in your apps.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-alert/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 29),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Navigation Bar: A Complete Guide",
            intro: """
                Learn how to create and customize a Navigation Bar in SwiftUI — the essential component for effortless app navigation. Discover the power of SwiftUI’s declarative syntax to build modern and visually stunning apps that provide a seamless user experience.

                SwiftUI navigation bar is a UI element that allows users to navigate between different views in an app. It is typically used to provide a hierarchical navigation experience, where users can move from a parent view to a child view, and then back to the parent view.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-navigation-bar-a-complete-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 15),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
// 6 page
                
        Post(
            title: "Mastering Buttons: A Comprehensive Guide",
            intro: """
                In the world of iOS app development, SwiftUI has emerged as a powerful framework for building user interfaces. One of its fundamental components is the button. Buttons enable users to interact with your app, triggering actions and providing a seamless user experience. In this blog post, we’ll dive into SwiftUI buttons, exploring their versatility, customization options, and best practices.

                By the end, you’ll be equipped with the knowledge to create beautiful and interactive buttons that elevate your app’s user interface.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-buttons/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 13),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "ScrollView: Building Dynamic and Interactive Interfaces",
            intro: """
                SwiftUI ScrollView is a powerful container view provided by Apple’s SwiftUI framework for creating scrollable user interfaces in iOS, macOS, watchOS, and tvOS applications. It allows users to scroll through views that exceed the screen’s boundaries, providing a seamless and interactive scrolling experience.

                The ScrollView automatically adjusts its content size based on the views it contains, enabling the user to scroll vertically or horizontally through the content. It handles various complexities, such as dynamic content heights, nested scroll views, and lazy loading, making it a versatile tool for building dynamic and interactive user interfaces.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-scrollview-building-dynamic-and-interactive-interfaces/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 6),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Mastering Picker: A Powerful Tool for User Input",
            intro: "The Picker is a powerful and versatile user interface component in SwiftUI that allows users to select an option from a predefined list. In this blog post, we will explore the capabilities of the SwiftUI Picker and how you can leverage its features to enhance your app’s user experience.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-picker/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 2),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Rotation Animation: Bringing Your App to Life",
            intro: "is a powerful framework for building user interfaces in iOS apps. One of the many features it offers is the ability to create animations easily, including rotation animations. In this post, we will explore how to use SwiftUI rotation animation, as well as some use cases and examples.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-rotation-animation/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 5, day: 16),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Mastering Redacted: Hide data and show loading",
            intro: "In this article, we’ll explore the power of SwiftUI’s redacted views, including their use cases and examples. You will be able to implement redated in no time",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-redacted/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 5, day: 8),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "ProgressView: An Overview",
            intro: "As developers, we strive to create applications that are easy to use and visually appealing. Part of achieving this goal is incorporating a user interface that provides clear feedback to the user about the state of the application. One way to achieve this is through the use of progress indicators. In SwiftUI, we have the ProgressView, a view that displays the progress of a task or process. In this post, we’ll explore what ProgressView is, how to use it, and why it’s a good idea.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-progressview/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 4, day: 12),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Sheet – with examples",
            intro: """
                SwiftUI Sheet is a type of modal presentation style in Apple’s SwiftUI framework for building user interfaces on Apple platforms like iOS, iPadOS, and macOS. 

                Sheets present new content as a slide-over card that covers part of the screen and is used to initiate a task or to present a small amount of content. You can interact with the content on the main screen while the sheet is open. 

                You can dismiss the sheet by tapping on the background, dragging it down, or using a specific action. To create a sheet in SwiftUI, use the sheet modifier on a view.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-sheet/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 4, day: 1),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Swift guard statement — need to know with examples",
            intro: "In Swift the guard statement is a control flow statement that is used to check for certain conditions, and if those conditions are not met, it will exit the current scope early, returning from the current function, method, or closure.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swift-guard-statement-need-to-know-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 4, day: 1),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Stepper: A Powerful Tool for User Input — with examples",
            intro: """
                User input is an essential part of any application. Without it, apps would be static and unresponsive. To enable user input, developers rely on various tools and widgets to make it as easy and intuitive as possible. One such tool is the SwiftUI Stepper, which allows users to input numerical values in a simple and elegant way.

                In this blog post, we will explore the SwiftUI Stepper, how to use it, and why it’s a good idea to use it in your apps. We’ll also look at some use cases where the Stepper can be useful.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-stepper-a-powerful-tool-for-user-input-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 28),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Forms",
            intro: "One of the most commonly used views in SwiftUI is the Form view, which is a container for grouping related controls and data entry fields in a structured way. In this post, we’ll explore the basics of SwiftUI Form, along with some examples and use cases.",
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swiftui-form/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 27),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
// 7 page
        Post(
            title: "List — the basics with examples",
            intro: """
                In this tutorial, you will learn how to use List in SwiftUI. I have included the most basic usages of List that includes list with strings, objects, sections, styles, delete, selection and of course pull to refresh.

                A List in SwiftUI is a container view that presents rows of data arranged in a single column. It can be used to display a vertically scrolling list of items, where each item is a separate row. A List is a fundamental building block of a SwiftUI app, and it provides several features out-of-the-box, such as automatic scrolling, dynamic row heights, and support for sectioned lists.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 18),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "MVVM in SwiftUI — a easy guide",
            intro: """
                MVVM is widely used when developing mobile applications or applications for Windows or Mac. MVVM in swiftUI provides an easy way to separate UI and business logic.

                In this tutorial, you will learn what MVVM is and you will get an example of how to implement it in your SwiftUI app easily.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/mvvm-in-swiftui-a-easy-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 16),
            studyLevel: .beginner,
            favoriteChoice: .no,
            additionalText: "",
            date: .now),
        Post(
            title: "Swift error handling — with examples",
            intro: """
                Error handling in Swift is a mechanism for dealing with errors or exceptional situations that may occur in your code. It allows you to identify and respond to potential problems in a controlled and predictable manner, rather than allowing them to cause your program to crash.

                In Swift, errors are represented by values of types that conform to the Error protocol. When a function encounters an error, it can throw an error using the throw statement. The error can then be caught and handled by a surrounding do-catch statement.
                """,
            author: "softwareanders.com",
            postLanguage: .english,
            urlString: "https://softwareanders.com/swift-error-handling-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 13)),
        
// Stewart Lynch
        Post(
            title: "Mastering iOS 26 Toolbars & Modal Sheets in SwiftUI – New Glass Buttons, Transitions & More",
            intro: """
                iOS 26 brings a fresh take on SwiftUI toolbars and modal presentations, and in this tutorial, I’ll guide you through everything you need to know. We’ll explore semantic and positional toolbar item placements, new glass button styles, toolbar spacers, and subtitle options—including some quirks to be aware of. You’ll also learn how to use the new matchGeometry transition with modal sheets for a polished, modern experience.

                By the end of the video, you’ll be equipped to take full advantage of toolbars and sheet presentation enhancements in iOS 26.
                """,
            author: "Stewart Lynch",
            postLanguage: .english,
            urlString: "https://www.youtube.com/watch?v=IiLDbrtBsn0",
            postPlatform: .youtube,
            postDate: Date.from(year: 2025, month: 9, day: 14)),
        
        Post(
            title: "Mastering Liquid Glass in SwiftUI – Buttons, Containers & Transitions",
            intro: """
                SwiftUI’s Liquid Glass effect in OS 26 is more than just eye candy—it’s a whole new design system. In this tutorial, I’ll guide you through the new button styles, applying glass effects to various views, and using GlassEffectContainer to create seamless, fluid layouts.

                We’ll also explore namespace-powered unions, matched geometry transitions, and clever control interactions that elevate your app’s UI. This is hands-on, practical, and comprehensive.

                Whether you’re building for iOS, macOS, or visionOS, Liquid Glass is a game-changer—and I’ll help you get the most out of it.
                """,
            author: "Stewart Lynch",
            postLanguage: .english,
            urlString: "https://www.youtube.com/watch?v=E2nQsw0El8M",
            postPlatform: .youtube,
            postDate: Date.from(year: 2025, month: 8, day: 31)),
// 2025-10-25
        Post(
            title: "Swift Basics",
            intro: """
                Get started with the Swift programming language. Write your first line of code and learn the fundamentals.
                """,
            author: "Swiftful Thinking",
            postType: .playlist,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiLvzZFJI6rVIBtdolrJBVB",
            postPlatform: .youtube,
            postDate: Date.from(year: 2023, month: 6, day: 20)),
        Post(
            title: "SwiftUI Bootcamp",
            intro: """
                The fastest way to learn SwiftUI. Learn how to build beautiful screens and other UI components.
                """,
            author: "Swiftful Thinking",
            postType: .playlist,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 2, day: 3)),
        Post(
            title: "SwiftUI Todo List",
            intro: """
                Build your first app in SwiftUI! Learn how to build a real application with MVVM app architecture.
                """,
            author: "Swiftful Thinking",
            postType: .playlist,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpheGqemblOIA7v3oq0MS30i",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 3, day: 14)),
        Post(
            title: "Git & Source Control",
            intro: """
                A complete guide for learning how to use git. Practice using Source Control within Xcode, GitKraken, and Github. Get familiar with Git Flow.
                """,
            author: "Swiftful Thinking",
            postType: .playlist,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiALKk34l9mUS2f4mdJPvXq",
            postPlatform: .youtube,
            postDate: Date.from(year: 2024, month: 4, day: 29)),
        Post(
            title: "SwiftUI Map App",
            intro: """
                Build a map app to showcase real destinations around the world. Get familiar with data management and transitions.
                """,
            author: "Swiftful Thinking",
            postType: .playlist,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdpha5eVTjLM0eRlJ7-yDDwBk",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 12, day: 20)),
        Post(
            title: "SwiftUI Continued Learning",
            intro: """
                Building professional apps requires knowledge of data persistence and networking. This bootcamp builds on your existing knowledge of SwiftUI.
                """,
            author: "Swiftful Thinking",
            postType: .playlist,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiagxAXCT33Rkwnc5IVhTar",
            postDate: Date.from(year: 2021, month: 3, day: 29),
            studyLevel: .middle),
        Post(
            title: "SwiftUI Crypto App",
            intro: """
                Build a cryptocurrency app that downloads live price data from an API and saves the current user's portfolio. Get comfortable with Combine, Core Data, and MVVM.
                """,
            author: "Swiftful Thinking",
            postType: .playlist,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphbc3bgy_LpLRQ9DDfFGcFu",
            postDate: Date.from(year: 2021, month: 5, day: 24),
            studyLevel: .middle),
        Post(
            title: "SwiftUI Advanced Learning",
            intro: """
                Learn how to build custom views, animations, and transitions. Get familiar with coding techniques such as Dependency Injection and Protocol-Oriented Programming. Write your first unit tests and connect to CloudKit.
                """,
            author: "Swiftful Thinking",
            postType: .playlist,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphc1LLLjCaEd87BEg07M97y",
            postDate: Date.from(year: 2021, month: 8, day: 30),
            studyLevel: .advanced),
        
        
    ]
    
}

