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
        urlString: "https://youtu.be/ExwwrvOT8mI?si=SU__YwU8UlR461Zb",
        postPlatform: .youtube,
        postDate: Date.from(year: 2021, month: 3, day: 26),
        studyLevel: .beginner,
        favoriteChoice: .yes,
        notes: "",
        origin: .cloud
    )
    
    static let samplePost2 = Post(
        title: "SwiftUI Advanced Learning",
        intro: """
            Learn how to build custom views, animations, and transitions. Get familiar with coding techniques such as Dependency Injection and Protocol-Oriented Programming. Write your first unit tests and connect to CloudKit.
            """,
        author: "Swiftful Thinking",
        postType: .course,
        urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphc1LLLjCaEd87BEg07M97y",
        postDate: Date.from(year: 2021, month: 8, day: 30),
        studyLevel: .advanced,
        origin: .local
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
        urlString: "https://www.youtube.com/watch?v=rbtIcKKxQ38", //
        postPlatform: .website,
        postDate: Date.from(year: 2022, month: 8, day: 11),
        studyLevel: .middle,
        favoriteChoice: .no,
        notes: """
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
        origin: .local
    )
    
    
    
    
    static let postsForCloud = [
        Post(
            title: "Styling SwiftUI Text Views",
            intro: """
            In this video we are going to explore how we can stylize text for our Text views in SwiftUI.
            We will start by looking at how we can create a `Text` view with the Markdown-formatted base postLanguage version of the string as the localization key,
            We will also see how we can utilize string interpolation to combine and stylize our strings and present them in a text view.
            And finally, we will take a quick look at the power of Attributed strings in SwiftUI.
            """,
            author: "Stewart Lynch",
            urlString: "https://www.youtube.com/watch?v=rbtIcKKxQ38",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 5, day: 7),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Customizing the appearance of symbol images in SwiftUI",
            intro: """
            Symbol images are vector-based icons from Apple's SF Symbols library, designed for use across Apple platforms. These scalable images adapt to different sizes and weights, ensuring consistent, high-quality icons throughout our apps. Using symbol images in SwiftUI is straightforward with the Image view and the system name of the desired symbol.
            """,
            author: "Natalia Panferova",
            urlString: "https://nilcoalescing.com/blog/CustomizingTheAppearanceOfSymbolImagesInSwiftUI/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 9, day: 22),
            origin: .cloud
        ),
        Post(
            title: "ViewBuilder: Organize your views",
            intro: "ViewBuilders in SwiftUI are an excellent way to keep your code clean and organized. They make your code easier to read and maintain by allowing you to structure your views more clearly. This simplifies the process of building complex user interfaces, ensuring that your code remains elegant and efficient. Embracing ViewBuilders enhances both the readability and manageability of your SwiftUI projects.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-viewbuilder-organize-your-views/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 27),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "ClipShape: Shape Your Application",
            intro: """
            clipShape is a SwiftUI modifier that allows developers to define a shape that clips a view to shape it. This means that the view will be confined to the defined shape. You can create anything from circles to rectangles, it’s up to you.
                            
            In this post you will learn about ClipShape in SwiftUI. You will learn how to implement them and we will also cover the different shapes available.
            """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-clipshape-shape-your-application/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 13),
            origin: .cloud
        ),
        Post(
            title: "Long Press Gesture: Complete How-To Guide",
            intro: "The Long Press gesture in SwiftUI is a powerful interaction that triggers when a user presses and holds a view for a specific duration. This essential gesture recognizer is frequently implemented in modern iOS apps for context menus, drag and drop functionality, or revealing additional information to enhance user experience.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-long-press-how-to-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 7),
            origin: .cloud
        ),
        Post(
            title: "Toggle: Turn On And Off",
            intro: """
            SwiftUI Toggle is a UI control that enables users to switch between two states, typically represented as on and off. If you are building a view where you can enable a feature, then the Toggle view is the way to go.

            With very little code you can implement a simple and effective way of getting user input. In this blog post we will cover how to implement a Toggle switch, change the color, hide the label and execute a function when turned on.
            """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-toggle-turn-on-and-off/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 2),
            origin: .cloud
        ),
        Post(
            title: "Animate SF Symbols",
            intro: """
                SF Symbols is a great solution for making visual tasks with developing an iOS application. Not only are they great, but there are so many different ones to choose from. If you want to make your SF Symbols stand out a bit more or create some kind of visual effect, then animating your SF Symbols is the way to go.

                In the following examples, we will discover different variations of animations, so you are ready to animate your SF Symbols.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-animate-sf-symbols/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 24),
            origin: .cloud
        ),
        Post(
            title: "Shadow: Create depth and dimension",
            intro: """
                Shadows can add depth, dimension, and a touch of realism to your application.

                In this blog post, we will discover how to use the shadow() modifier in effect on any view in SwiftUI and we will also cover how you can customize the shadow effect.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-shadow-create-depth-and-dimension/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 3),
            origin: .cloud
        ),
        Post(
            title: "ShareLink: Share with ease",
            intro: """
                No matter what kind of app you are building, if your application has the feature to share data, do yourself a favor and implement ShareLink. Not only is it really easy to implement it also increases useability.

                In this blog post, we’re going to dive into SwiftUI’s ShareLink and how you can share a URL or Image with ease.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-sharelink-share-with-ease/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 28),
            origin: .cloud
        ),
        Post(
            title: "Launch screen: First Impressions Matters",
            intro: "In this blog post, we cover how to create a launch screen in SwiftUI, exploring why they’re not just a good idea, but a crucial element in crafting an exceptional user experience.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-launch-screen-first-impressions-matters/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 21),
            origin: .cloud
        ),
        Post(
            title: "Swift check network connection",
            intro: """
                Most applications nowadays use the internet. Whether you’re developing an application for the sole purpose of checking the network connection or simply trying to optimize user experience, knowing how to check network connectivity in your Swift application can be a game-changer.

                In this guide, we will check the network connection inside a SwiftUI application using NWPathMonitor, which was introduced in iOS 12.

                NB: Before diving into this guide, it’s a good idea to test on an iPhone and not the simulator.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swift-check-network-connection/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 28),
            origin: .cloud
        ),
        Post(
            title: "Request review: Complete guide",
            intro: """
                This article provides insights into the SwiftUI implementation of review requests, offering practical guidance on code usage and adherence to Apple’s best practices for soliciting feedback effectively.

                In this blog post we will cover how to request a review in SwitUI, we will also cover best practices on when to ask for a review and Apple’s guidelines.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-request-review-complete-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 2, day: 22),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Segmented control: Easy to follow guide",
            intro: """
                SwiftUI Segmented Control is a great and user-friendly way that allows users to choose between multiple options within a segmented, tap-friendly control.

                In this blog post, we’ll learn how to create a Segmented Control in SwiftUI and explore how to change the selected color and background color.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-segmented-control/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 2, day: 21),
            origin: .cloud
        ),
        Post(
            title: "Email: A Complete Guide",
            intro: """
                In today’s digital landscape, email remains a cornerstone of communication, seamlessly connecting users worldwide. This guide caters to developers of all skill levels, offering a concise walkthrough from project setup to email composition and dispatch within your SwiftUI app.

                In this blog post, we’ll explore how to send emails using SwiftUI, both with and without an attachment.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-email-a-complete-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 12),
            origin: .cloud
        ),
        Post(
            title: "Material: How to use material",
            intro: """
                When you want to create a blurred background, you should differently use SwiftUI material. Material was launched in SwiftUI 3 and is a great way of making a blurred background or see through view, Apple has provided an easy way of making a blur effect as a background.

                In this blog post, you will learn what Material is and how you use it and we will create an example with a view where we use material.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-material-how-to-use-material/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 1, day: 14),
            origin: .cloud
        ),
// 3 page
        Post(
            title: "Blur: A short guide",
            intro: """
                The blur effect is a visual enhancement technique used in graphic design and user interface development to create a sense of depth, focus, or aesthetic appeal.

                In SwiftUI, the blur effect is achieved using the blur modifier. This modifier allows developers to apply a blur to any SwiftUI view.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-blur-a-short-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 1, day: 11),
            origin: .cloud
        ),
        Post(
            title: "Pull to refresh: Easy guide",
            intro: """
                SwiftUI Pull-to-Refresh is an essential feature in most apps, people just expect to be able to pull to refresh on lists of data. Pull to refresh allows users to update content effortlessly by pulling down on a view. 

                In this blog post, we will explore the implementation of SwiftUI Pull to Refresh, its benefits, and the steps to integrate this feature into your application.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-pull-to-refresh-easy-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 12, day: 29),
            origin: .cloud
        ),
        Post(
            title: "Link: How to guide",
            intro: "Link is a great and hassle-free way of opening a website from your application. In this article, we will cover how you use SwiftUI Link and how you can customize it to fit inside your application.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-link-how-to-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 12, day: 28),
            origin: .cloud
        ),
        Post(
            title: "Divider: A powerful line",
            intro: """
                SwiftUI divider is a simple yet powerful element that plays a crucial role in crafting visually appealing and well-structured interfaces. 

                In this blog post, we’ll explore the SwiftUI Divider and how it can elevate your app’s design and how to customize it to fit in your application.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-divider-a-powerful-line/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 12, day: 20),
            origin: .cloud
        ),
        Post(
            title: "Swift convert strings into different data types: Easy guide",
            intro: """
                As a software developer, you often encounter scenarios where you need to convert data from one type to another, and string conversion is a fundamental skill to master. 

                In this blog post, we’ll explore the art of converting strings into different data types like int, date, double and you will also learn how to convert your strings and prevent your app from crashing if it’s a wrong data type.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/converting-strings-into-different-data-types-easy-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 12, day: 8),
            origin: .cloud
        ),
        Post(
            title: "ColorPicker: A complete guide to Color Selection",
            intro: """
                SwiftUI ColorPicker enhances the user experience by providing an interactive and visually pleasing way to select colors. 

                In this blog post dive into the SwiftUI ColorPicker, exploring its functionality and how it simplifies the process of color selection within your SwiftUI applications.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-colorpicker-a-complete-guide-to-color-selection/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 28),
            origin: .cloud
        ),
        Post(
            title: "Swipe Actions: Complete guide with examples",
            intro: "One awesome and helpful feature in SwiftUI that enhances user interaction is swipe actions. In this blog post, we’ll explore the world of SwiftUI swipe actions, we will learn how to implement them and customize them to fit into your application, so you can provide even more value for your users.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-swipe-actions-complete-guide-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 27),
            origin: .cloud
        ),
        Post(
            title: "SF Symbols: A easy guide",
            intro: """
                SwiftUI SF Symbols stand out as a powerful tool for enhancing the visual appeal of your apps. These symbols, introduced by Apple, provide a vast collection of scalable, customizable icons that can breathe life into your user interface. 

                In this blog post, we’ll explore how to implement SwiftUI SF Symbols and dive into how they can be customized to fit your needs.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-sf-symbols-a-easy-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 23),
            origin: .cloud
        ),
        Post(
            title: "DatePicker: Integrating dates in your app",
            intro: """
                SwiftUI DatePicker is a powerful tool that simplifies date and time selection in your iOS apps. The SwiftUI DatePicker provides a seamless way for users to choose dates and times within your app, eliminating the need for complex input forms or manual date entry. With a sleek and customizable interface, this component enhances the user experience and streamlines the development process.

                In this blog post, you will learn how to use the DatePicker in SwiftUI and how to customize it so it fits right into the style of your application.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-datepicker-integrating-dates-in-your-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 21),
            origin: .cloud
        ),
// 4 page

        Post(
            title: "TextEditor character limit",
            intro: """
                SwfitUI TextEditor is a great tool for letting your users edit large text elements, but sometimes you want to limit the character count — your backend API might have a limit. For example, Twitter (now X) has a character limit of 280.

                In this blog post, you will learn how to create a TextEditor with a limit of 280 characters. We’ll create the TextEditor in its own view so you can easily use it in different places inside your application. We will also create the character limit as a custom modifier — that way you can have different text editors with different limits.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-texteditor-character-limit/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 9),
            origin: .cloud
        ),
        Post(
            title: "TextEditor: A user friendly guide",
            intro: """
                SwiftUI TextEditor is a great component that empowers developers to work with large text input and editing in SwiftUI applications. TextEditor is a dynamic, rich, and customisable solution that offers a world of possibilities for crafting engaging user interfaces.

                In this blog post, we’re going to take a deep dive into SwiftUI TextEditor, exploring its features, capabilities, and how you can use it in your application. I hope that whether you’re new to SwiftUI or a seasoned developer, this guide will provide you with insights and practical examples to unlock the full potential of TextEditor in your projects.
                """,
            author: "softwareanders.com",
            urlString: "",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 7),
            origin: .cloud
        ),
        Post(
            title: "Line chart: Complete guide with examples",
            intro: """
                SwiftUI Line chart is a great tool to use. A line chart, also known as a line graph or a time series chart, is a type of data visualization that displays information as a series of data points connected by straight lines. It is commonly used to represent data that changes continuously over a period of time, making it an effective tool for visualising trends, patterns, and relationships in data.

                In SwiftUI it’s easy to make a line chart and in this blog post you will learn everything you need to know about line charts in SwiftUI.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-line-chart-complete-guide-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 10, day: 11),
            origin: .cloud
        ),
        Post(
            title: "TabView: All you need to know",
            intro: """
                One of the fundamental components for organizing and navigating through content in a mobile application is by using a tabbar at the bottom of the screen. In this blog post, we’ll explore how we can easily create a tabbar in SwiftUI by using the native tabview. 

                In this blog post I will provide you with practical examples to help you master the native tabview.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-tabview-all-you-need-to-know/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 10, day: 10),
            origin: .cloud
        ),
        Post(
            title: "Menu: A complete Guide",
            intro: """
                SwiftUI menu provide a seamless and organized way to present actions and options to users and allowing developers to create powerful and interactive interfaces.

                In this post, we will explore various aspects of SwiftUI Menu. We will cover a basic example, add a image to the menu, add a checkmark and more.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-menu-a-complete-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 31),
            origin: .cloud
        ),
        Post(
            title: "Toolbar: A complete Guide with examples",
            intro: "Toolbar is a powerful tool for designing elegant and functional user interfaces. In this blog post, we’ll be working with the native SwiftUI Toolbar and exploring its capabilities, providing examples, and showing you how to customize things like its background color to match your app’s design.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-toolbar-a-complete-guide-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 24),
            origin: .cloud
        ),
        Post(
            title: "Search: Enhance User Experience with SwiftUI Searchable",
            intro: """
                To create applications that users will love, developers must embrace intuitive design and create a great user experience. When thinking user experience one important note is efficient data presentation. One way of achieving that is by implementing search in SwiftUI. SwiftUI offers a powerful tool for achieving this: the Searchable modifier.

                In this blog post, we’ll dive into SwiftUI Searchable modifier, explore its capabilities, and learn how to search simple strings and complex objects. We will also use search suggestions and search scopes.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-search-enhance-user-experience-with-swiftui-searchable/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 22),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Swift UserDefaults: All you need to know",
            intro: "Swift UserDefaults is a lightweight and convenient data persistence store provided by Apple’s Foundation framework. It allows you to store small pieces of data, such as user preferences, settings, and simple configuration values. These values are automatically saved to the device’s file system, making them accessible even after the app is closed or the device is rebooted.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swift-userdefaults-all-you-need-to-know/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 15),
            origin: .cloud
        ),
        Post(
            title: "PhotoPicker: A Hands-On Guide with Examples",
            intro: """
                SwiftUI PhotoPicker is a powerful package for seamlessly integrating photo and media selection capabilities into your applications. 

                In this blog post, we’ll dive into how you can implement PhotoPicker and how you let the user pick a single image or select multiple images and of course how you can filter what kind of images they can select.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-photopicker-a-hands-on-guide-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 08, day: 10),
            origin: .cloud
        ),
// 5 page
        
        Post(
            title: "ConfirmationDialog — with examples",
            intro: """
                It is important to ensure a smooth and delightful user experience thougth out your app. In iOS 15 Apple have introduced SwiftUI confirmationDialog that can help us with just that. SwiftUI confirmationDialog is a easy way for you as a developer to show a dialog with multiple choices, provide a title and a hint message to make sure your users know what to do. 

                In this blog post we will explore what SwiftUI confirmationDialiog is, how it works and give examples on how to use it in your own app.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-confirmationdialog-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 8, day: 8),
            origin: .cloud
        ),
        
        Post(
            title: "TextField clear button",
            intro: """
                Creating a clear button for a TextField in SwiftUI can greatly enhance the user experience and make your app more user-friendly. This simple feature allows users to easily clear the text within the TextField, eliminating the need to manually delete characters. 

                A clear button allows users to quickly erase the content of a TextField with a single tap. It eliminates the need to manually delete characters, making it more efficient for users to correct their input or start over.

                In this blog post, I will walk you through the steps of implementing a clear button for a TextField in SwiftUI. You will learn how to quickly add a clear button to one TextField and you will also learn how to create a ViewModifier so you can reuse the solution throughout your app.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-textfield-clear-button/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 8, day: 4),
            origin: .cloud
        ),
        
        Post(
            title: "TextField Placeholder: Best Practices and Tips",
            intro: "A well-crafted placeholder can greatly impact the overall user experience. In this blog post, we will explore the importance of TextField placeholders, learn how to change the color of the placeholder, use a image in placeholder and change the font. We will end the blog post with some great tips make better placeholders.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-textfield-placeholder-best-practices-and-tips/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 8, day: 3),
            origin: .cloud
        ),
        
        Post(
            title: "Swift EventKit: Calendar management",
            intro: """
                With Swift EventKit framework it provides powerful capabilities for working with calendars, allowing developers to seamlessly create, edit, fetch and delete calendar events within their applications. 

                In this blog post, we will explore a full example of eventkit to create, edit, and delete calendar events, helping users stay organized and on top of their schedules. 
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swift-eventkit-calendar-management/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 7, day: 28),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Password: Show and Hide",
            intro: "When creating an app security is very important but so is convenience therefore the ability to show and hide passwords has become a crucial feature for mobile applications. In this blog post, we will explore how to create a secure text field that hides the password but also learn how to create the ability to show/hide the password.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-password-show-and-hide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 7, day: 26),
            origin: .cloud
        ),
        Post(
            title: "TextField Background Color",
            intro: """
                In SwiftUI, the TextField is a versatile user interface element that allows users to input text seamlessly. One way to enhance the visual appeal and user experience of TextFields is by customizing their background colors. In this blog post, we’ll delve into different techniques for setting background colors for SwiftUI TextFields and explore creative use cases.

                In this guide about background color for textfield in SwiftUI we will cover the basics but also learn how to set a gradient background and how to change the background based on user input.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-textfield-background-color/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 7, day: 25),
            origin: .cloud
        ),
        Post(
            title: "TextField: A User-Friendly Guide",
            intro: "SwiftUI’s TextField is a powerful user interface element that enables developers to effortlessly capture user input and create interactive experiences in their applications. Whether you’re a seasoned SwiftUI developer or just starting your journey, this blog post will walk you through the ins and outs of SwiftUI TextFields, providing valuable insights, use cases, and code examples along the way. Let’s dive in!",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-textfield-a-user-friendly-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 7, day: 24),
            origin: .cloud
        ),
        Post(
            title: "AsyncImage: Asynchronous Image Loading",
            intro: """
                In the world of mobile app development, displaying images is a common task. However, when dealing with images, it can quickly become tough to display them fast enough while not blocking the UI thread. Luckily Apple have thought of this when creating SwiftUI and they have created a powerful solution called AsyncImage. 

                In this blog post, we’ll explore how AsyncImage simplifies the process of loading remote images in SwiftUI, making it easier and more efficient for developers — the easier it is, the happier the developer.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-asyncimage/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 28),
            origin: .cloud
        ),
        Post(
            title: "Alert: Best Practices and Examples",
            intro: "When creating a mobile app it’s important to notify the users when something happens like an API request went OK or failed. With SwiftUI Alerts, you can quickly inform users, gather input, and prompt them to take specific actions. In this article, we’ll explore the power of SwiftUI Alerts and learn how to leverage them to enhance user interaction in your apps.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-alert/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 29),
            origin: .cloud
        ),
        Post(
            title: "Navigation Bar: A Complete Guide",
            intro: """
                Learn how to create and customize a Navigation Bar in SwiftUI — the essential component for effortless app navigation. Discover the power of SwiftUI’s declarative syntax to build modern and visually stunning apps that provide a seamless user experience.

                SwiftUI navigation bar is a UI element that allows users to navigate between different views in an app. It is typically used to provide a hierarchical navigation experience, where users can move from a parent view to a child view, and then back to the parent view.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-navigation-bar-a-complete-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 15),
            origin: .cloud
        ),
// 6 page
                
        Post(
            title: "Mastering Buttons: A Comprehensive Guide",
            intro: """
                In the world of iOS app development, SwiftUI has emerged as a powerful framework for building user interfaces. One of its fundamental components is the button. Buttons enable users to interact with your app, triggering actions and providing a seamless user experience. In this blog post, we’ll dive into SwiftUI buttons, exploring their versatility, customization options, and best practices.

                By the end, you’ll be equipped with the knowledge to create beautiful and interactive buttons that elevate your app’s user interface.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-buttons/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 13),
            origin: .cloud
        ),
        Post(
            title: "ScrollView: Building Dynamic and Interactive Interfaces",
            intro: """
                SwiftUI ScrollView is a powerful container view provided by Apple’s SwiftUI framework for creating scrollable user interfaces in iOS, macOS, watchOS, and tvOS applications. It allows users to scroll through views that exceed the screen’s boundaries, providing a seamless and interactive scrolling experience.

                The ScrollView automatically adjusts its content size based on the views it contains, enabling the user to scroll vertically or horizontally through the content. It handles various complexities, such as dynamic content heights, nested scroll views, and lazy loading, making it a versatile tool for building dynamic and interactive user interfaces.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-scrollview-building-dynamic-and-interactive-interfaces/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 6),
            origin: .cloud
        ),
        Post(
            title: "Mastering Picker: A Powerful Tool for User Input",
            intro: "The Picker is a powerful and versatile user interface component in SwiftUI that allows users to select an option from a predefined list. In this blog post, we will explore the capabilities of the SwiftUI Picker and how you can leverage its features to enhance your app’s user experience.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-picker/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 6, day: 2),
            origin: .cloud
        ),
        Post(
            title: "Rotation Animation: Bringing Your App to Life",
            intro: "is a powerful framework for building user interfaces in iOS apps. One of the many features it offers is the ability to create animations easily, including rotation animations. In this post, we will explore how to use SwiftUI rotation animation, as well as some use cases and examples.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-rotation-animation/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 5, day: 16),
            origin: .cloud
        ),
        Post(
            title: "Mastering Redacted: Hide data and show loading",
            intro: "In this article, we’ll explore the power of SwiftUI’s redacted views, including their use cases and examples. You will be able to implement redated in no time",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-redacted/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 5, day: 8),
            origin: .cloud
        ),
        Post(
            title: "ProgressView: An Overview",
            intro: "As developers, we strive to create applications that are easy to use and visually appealing. Part of achieving this goal is incorporating a user interface that provides clear feedback to the user about the state of the application. One way to achieve this is through the use of progress indicators. In SwiftUI, we have the ProgressView, a view that displays the progress of a task or process. In this post, we’ll explore what ProgressView is, how to use it, and why it’s a good idea.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-progressview/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 4, day: 12),
            origin: .cloud
        ),
        Post(
            title: "Sheet – with examples",
            intro: """
                SwiftUI Sheet is a type of modal presentation style in Apple’s SwiftUI framework for building user interfaces on Apple platforms like iOS, iPadOS, and macOS. 

                Sheets present new content as a slide-over card that covers part of the screen and is used to initiate a task or to present a small amount of content. You can interact with the content on the main screen while the sheet is open. 

                You can dismiss the sheet by tapping on the background, dragging it down, or using a specific action. To create a sheet in SwiftUI, use the sheet modifier on a view.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-sheet/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 4, day: 1),
            origin: .cloud
        ),
        Post(
            title: "Swift guard statement — need to know with examples",
            intro: "In Swift the guard statement is a control flow statement that is used to check for certain conditions, and if those conditions are not met, it will exit the current scope early, returning from the current function, method, or closure.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swift-guard-statement-need-to-know-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 4, day: 1),
            origin: .cloud
        ),
        Post(
            title: "Stepper: A Powerful Tool for User Input — with examples",
            intro: """
                User input is an essential part of any application. Without it, apps would be static and unresponsive. To enable user input, developers rely on various tools and widgets to make it as easy and intuitive as possible. One such tool is the SwiftUI Stepper, which allows users to input numerical values in a simple and elegant way.

                In this blog post, we will explore the SwiftUI Stepper, how to use it, and why it’s a good idea to use it in your apps. We’ll also look at some use cases where the Stepper can be useful.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-stepper-a-powerful-tool-for-user-input-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 28),
            origin: .cloud
        ),
        Post(
            title: "Forms",
            intro: "One of the most commonly used views in SwiftUI is the Form view, which is a container for grouping related controls and data entry fields in a structured way. In this post, we’ll explore the basics of SwiftUI Form, along with some examples and use cases.",
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swiftui-form/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 27),
            origin: .cloud
        ),
// 7 page
        Post(
            title: "List — the basics with examples",
            intro: """
                In this tutorial, you will learn how to use List in SwiftUI. I have included the most basic usages of List that includes list with strings, objects, sections, styles, delete, selection and of course pull to refresh.

                A List in SwiftUI is a container view that presents rows of data arranged in a single column. It can be used to display a vertically scrolling list of items, where each item is a separate row. A List is a fundamental building block of a SwiftUI app, and it provides several features out-of-the-box, such as automatic scrolling, dynamic row heights, and support for sectioned lists.
                """,
            author: "softwareanders.com",
            urlString: "",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 18),
            origin: .cloud
        ),
        Post(
            title: "MVVM in SwiftUI — a easy guide",
            intro: """
                MVVM is widely used when developing mobile applications or applications for Windows or Mac. MVVM in swiftUI provides an easy way to separate UI and business logic.

                In this tutorial, you will learn what MVVM is and you will get an example of how to implement it in your SwiftUI app easily.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/mvvm-in-swiftui-a-easy-guide/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 16),
            origin: .cloud
        ),
        Post(
            title: "Swift error handling — with examples",
            intro: """
                Error handling in Swift is a mechanism for dealing with errors or exceptional situations that may occur in your code. It allows you to identify and respond to potential problems in a controlled and predictable manner, rather than allowing them to cause your program to crash.

                In Swift, errors are represented by values of types that conform to the Error protocol. When a function encounters an error, it can throw an error using the throw statement. The error can then be caught and handled by a surrounding do-catch statement.
                """,
            author: "softwareanders.com",
            urlString: "https://softwareanders.com/swift-error-handling-with-examples/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 3, day: 13),
            origin: .cloud
        ),
        
// Stewart Lynch
        Post(
            title: "Mastering iOS 26 Toolbars & Modal Sheets in SwiftUI – New Glass Buttons, Transitions & More",
            intro: """
                iOS 26 brings a fresh take on SwiftUI toolbars and modal presentations, and in this tutorial, I’ll guide you through everything you need to know. We’ll explore semantic and positional toolbar item placements, new glass button styles, toolbar spacers, and subtitle options—including some quirks to be aware of. You’ll also learn how to use the new matchGeometry transition with modal sheets for a polished, modern experience.

                By the end of the video, you’ll be equipped to take full advantage of toolbars and sheet presentation enhancements in iOS 26.
                """,
            author: "Stewart Lynch",
            urlString: "https://www.youtube.com/watch?v=IiLDbrtBsn0",
            postPlatform: .youtube,
            postDate: Date.from(year: 2025, month: 9, day: 14),
            origin: .cloud
        ),
        
        Post(
            title: "Mastering Liquid Glass in SwiftUI – Buttons, Containers & Transitions",
            intro: """
                SwiftUI’s Liquid Glass effect in OS 26 is more than just eye candy—it’s a whole new design system. In this tutorial, I’ll guide you through the new button styles, applying glass effects to various views, and using GlassEffectContainer to create seamless, fluid layouts.

                We’ll also explore namespace-powered unions, matched geometry transitions, and clever control interactions that elevate your app’s UI. This is hands-on, practical, and comprehensive.

                Whether you’re building for iOS, macOS, or visionOS, Liquid Glass is a game-changer—and I’ll help you get the most out of it.
                """,
            author: "Stewart Lynch",
            urlString: "https://www.youtube.com/watch?v=E2nQsw0El8M",
            postPlatform: .youtube,
            postDate: Date.from(year: 2025, month: 8, day: 31),
            origin: .cloud
        ),
// 2025-10-25 DONE
        Post(
            title: "Swift Basics",
            intro: """
                Get started with the Swift programming language. Write your first line of code and learn the fundamentals.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiLvzZFJI6rVIBtdolrJBVB",
            postPlatform: .youtube,
            origin: .cloud
        ),
        Post(
            title: "SwiftUI Bootcamp",
            intro: """
                The fastest way to learn SwiftUI. Learn how to build beautiful screens and other UI components.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO",
            postPlatform: .youtube,
            origin: .cloud
        ),
        Post(
            title: "SwiftUI Todo List",
            intro: """
                Build your first app in SwiftUI! Learn how to build a real application with MVVM app architecture.
                """,
            author: "Swiftful Thinking",
            postType: .solution,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpheGqemblOIA7v3oq0MS30i",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 3, day: 14),
            origin: .cloud
        ),
        Post(
            title: "Git & Source Control",
            intro: """
                A complete guide for learning how to use git. Practice using Source Control within Xcode, GitKraken, and Github. Get familiar with Git Flow.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiALKk34l9mUS2f4mdJPvXq",
            postPlatform: .youtube,
            origin: .cloud
        ),
        Post(
            title: "SwiftUI Map App",
            intro: """
                Build a map app to showcase real destinations around the world. Get familiar with data management and transitions.
                """,
            author: "Swiftful Thinking",
            postType: .solution,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdpha5eVTjLM0eRlJ7-yDDwBk",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 12, day: 20),
            origin: .cloud
        ),
        Post(
            title: "SwiftUI Continued Learning",
            intro: """
                Building professional apps requires knowledge of data persistence and networking. This bootcamp builds on your existing knowledge of SwiftUI.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4VfkdpiagxAXCT33Rkwnc5IVhTar",
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "SwiftUI Crypto App",
            intro: """
                Build a cryptocurrency app that downloads live price data from an API and saves the current user's portfolio. Get comfortable with Combine, Core Data, and MVVM.
                """,
            author: "Swiftful Thinking",
            postType: .solution,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphbc3bgy_LpLRQ9DDfFGcFu",
            postDate: Date.from(year: 2021, month: 5, day: 24),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "SwiftUI Advanced Learning",
            intro: """
                Learn how to build custom views, animations, and transitions. Get familiar with coding techniques such as Dependency Injection and Protocol-Oriented Programming. Write your first unit tests and connect to CloudKit.
                """,
            author: "Swiftful Thinking",
            postType: .course,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphc1LLLjCaEd87BEg07M97y",
            studyLevel: .advanced,
            origin: .cloud
        ),
// 2025-10-26 DONE
        Post(
            title: "Tips to Git",
            intro: """
                The source contains tutorials on merging and rebasing, resetting, checking out, reverting, and other usefull guides, in Git.
                """,
            author: "www.atlassian.com",
            postType: .post,
            urlString: "https://www.atlassian.com/git/tutorials",
            postPlatform: .website,
            postDate: nil,
            studyLevel: .beginner,
            origin: .cloud
        ),
// 2025-10-27 DONE
        Post(
            title: "List or LazyVStack: Choosing the Right Lazy Container in SwiftUI",
            intro: """
                In the world of SwiftUI, List and LazyVStack, as two core lazy containers, offer robust support for developers to display large amounts of data. However, their similar performance in certain scenarios often causes confusion among developers when making a choice. This article aims to analyze the characteristics and advantages of these two components to help you make a better decision.
                """,
            author: "Fatbobman",
            postType: .post,
            urlString: "https://fatbobman.com/en/posts/list-or-lazyvstack/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 7, day: 10),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Encapsulating SwiftUI view styles",
            intro: """
                Regardless of what framework or tool that’s used to build a given UI, finding a good way to separate the structure and internal logic of our various views from the styles that are being applied to them is often key in order to make UI code easier to maintain and manage.
                
                While certain technologies offer a quite natural way of separating those two aspects of UI development, such as how websites declare their structure through HTML and their styles using CSS — when it comes to SwiftUI, it might not initially seem like that kind of separation is practical, or even encouraged.
                
                However, if we start exploring SwiftUI’s various APIs and conventions a bit further, it turns out that there are a number of tools and techniques that we can use to create a clean separation between our view hierarchy, its styles, and the components that we’re looking to reuse across a given project.
                
                That’s exactly what we’ll take a look at in this week’s article.
                """,
            author: "John Sundell",
            postType: .post,
            urlString: "https://www.swiftbysundell.com/articles/encapsulating-swiftui-view-styles/",
            postPlatform: .website,
            postDate: Date.from(year: 2020, month: 9, day: 27),
            studyLevel: .beginner,
            origin: .cloud
        ),
// 2025-10-28
        Post(
            title: "How to use AnyLayout in SwiftUI | Bootcamp #70",
            intro: """
                This video introduces AnyLayout, which allows us to customize the layout of our Views. This is similar to using an HStack or VStack, except gives us additional capabilities to customize the View for different environments or settings.
                """,
            author: "Swiftful Thinking",
            postType: .post,
            urlString: "https://www.youtube.com/watch?v=7BAW70amSCA&list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO&index=73",
            postPlatform: .youtube,
            postDate: Date.from(year: 2023, month: 11, day: 9),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "How to use ViewThatFits in SwiftUI | Bootcamp #71",
            intro: """
                In this video, we'll learn how to use ViewThatFits to add custom View rendering into our application! This allows us to dynamically change the "View" to the best "fit" for the current frame. This is especially helpful when displaying on devices with different screen sizes.
                """,
            author: "Swiftful Thinking",
            postType: .post,
            urlString: "https://www.youtube.com/watch?v=oN3Rqo6V6Uc&list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO&index=74",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 11, day: 14),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "How to use ControlGroup in SwiftUI | Bootcamp #75",
            intro: """
                Explore ControlGroup in SwiftUI to efficiently organize UI controls in your iOS and macOS apps. This video covers how to use ControlGroup for grouping related user interface elements, improving both the design and functionality of your applications. Essential for developers looking to enhance their SwiftUI projects.
                """,
            author: "Swiftful Thinking",
            postType: .post,
            urlString: "https://www.youtube.com/watch?v=oN3Rqo6V6Uc&list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO&index=74",
            postPlatform: .youtube,
            postDate: Date.from(year: 2024, month: 02, day: 26),
            studyLevel: .beginner,
            origin: .cloud
        ),

        Post(
            title: "How to make a reusable ActionSheet in SwiftUI | Bootcamp #33",
            intro: """
                The Action Sheet is a super convenient component in SwiftUI that presents a message and buttons to our users. Implementing an .actionSheet() is very similar to the .alert() which we learned the last video of the SwiftUI Bootcamp, however, the action sheet pops up from the bottom and can support more than 2 buttons! In this video we will learn how to implement and customize the .actionSheet to make it adaptable and dynamic.
                """,
            author: "Swiftful Thinking",
            postType: .post,
            urlString: "https://www.youtube.com/watch?v=tNwnihqJf2I&list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO&index=36",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 2, day: 21),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "How to safely unwrap optionals in Swift with if-let and guard statements | Bootcamp #47",
            intro: """
                In almost every application there are cases where you will declare variables as optional. In Swift we declare a value as optional be using the ?. When we do this, we are telling Xcode that this variable has the potential to be nil (or without a value). Therefore, when we go to use that variable in our code, we need to safely check whether or not it really has a value at that time. Two of the smartest and safest ways to safely "unwrap" these optionals is be using 'if let' and 'guard' statements. In this video we will learn both! It should be noted that both of these methods are MUCH safer than explicitly unwrapping optionals by using the ! symbol (avoid this!).
                """,
            author: "Swiftful Thinking",
            postType: .post,
            urlString: "https://www.youtube.com/watch?v=wmQIl0O9HBY&list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO&index=50",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 3, day: 7),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "How to select text with TextSelection in SwiftUI | Bootcamp #56",
            intro: """
                One of the most underrated features released in iOS 15 is the ability to let users select and copy text in SwiftUI. In this quick video, we will learn how to use the .textSelection modifier! This feature probably did not need it's own video, but I think it's a pretty important feature to know about. This is great for chat apps or any content-based app where users might want to share some text with a friend. Sharing is not only a great feature for your users, but will help drive organic growth as users share with others.
                """,
            author: "Swiftful Thinking",
            postType: .post,
            urlString: "https://www.youtube.com/watch?v=AiSLtya25ac&list=PLwvDm4VfkdphqETTBf-DdjCoAvhai1QpO&index=59",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 12, day: 7),
            studyLevel: .beginner,
            origin: .cloud
        ),
// 2025-10-30
        Post(
            title: "SwiftUI Crypto App",
            intro: """
                Build a cryptocurrency app that downloads live price data from an API and saves the current user's portfolio. Get comfortable with Combine, Core Data, and MVVM.
                """,
            author: "Swiftful Thinking",
            postType: .solution,
            urlString: "https://www.youtube.com/playlist?list=PLwvDm4Vfkdphbc3bgy_LpLRQ9DDfFGcFu",
            postPlatform: .youtube,
            postDate: Date.from(year: 2024, month: 8, day: 8),
            origin: .cloud
        ),

    ]
        
    
    
    
    // MARK: My Private Posts
    
    
    
    
    static let myPrivatePosts = [
// 2025-10-30
        Post(
            title: "Property Wrappers",
            intro: "В этом видео я расскажу вам обо всех оболочках, которые нам предлагает SwiftUI для хранения временных данных. Так же вы поймете, в чем отличие между такими оболочки как @State, @StateObject, @ObservedObject, @EnvironmentObject. Эти оболочки очень похожи друг на друга и знание того, когда и какую лучше использовать, имеет решающее значение.",
            author: "Evgenia Bruyko",
            urlString: "https://youtu.be/ExwwrvOT8mI?si=SU__YwU8UlR461Zb",
            postPlatform: .youtube,
            postDate: Date.from(year: 2021, month: 3, day: 26),
            origin: .cloud
        ),
        Post(
            title: "Combine – швейцарский нож iOS-разработчика. Или нет?",
            intro: """
                Привет! Меня зовут Антон, я iOS-разработчик в Банки.ру. Когда я только начинал изучать Combine, он казался для меня магией. Пара команд и вот у тебя уже есть какие-то данные. Чтобы Combine перестал оставаться черным ящиком давайте заглянем внутрь. Эта статья – мое виденье этого фреймворка.
                """,
            author: "Anton @Toshhhh",
            postType: .post,
            urlString: "https://habr.com/ru/companies/banki/articles/958650/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 22),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Xcode: ключевые инструменты для ручного тестирования мобильных приложений",
            intro: """
                Привет! Я – Андрей, QA-лид из компании «Совкомбанк Технологии». Хочу поделиться опытом тестировании мобильных приложений в Xcode — среде, которую многие используют только для разработки. По внутренним данным нашей компании, примерно 65% критических багов в iOS-приложениях можно выловить ещё на этапе разработки, если грамотно использовать встроенные инструменты Xcode.
                """,
            author: "Andrey @SovcomTech",
            postType: .post,
            urlString: "https://habr.com/ru/companies/sovcombank_technologies/articles/956112/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 14),
            studyLevel: .middle,
            origin: .cloud
        ),
        
 // Create With Swift: www.createwithswift.com
        Post(
            title: "SwiftUI",
            intro: """
                A collection of SwiftUI posts.
            """,
            author: "Create With Swift",
            postType: .course,
            urlString: "https://www.createwithswift.com/tag/swiftui/",
            postPlatform: .website,
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Swift 6.2: Расширяем границы производительности и безопасности",
            intro: """
                Мы рады представить выпуск Swift 6.2! Это обновление призвано повысить производительность каждого разработчика, независимо от того, над каким проектом он работает. От улучшенных инструментов и библиотек до серьёзных продвижений в параллелизме и производительности — Swift 6.2 предлагает богатый набор функций для реальных задач на всех уровнях программного стека.
                
                В этой статье мы расскажем о ключевых изменениях в языке, библиотеках, инструментах и поддержке платформ, а также о том, как начать работу с новой версией.
                """,
            author: "@Chidorin",
            postType: .post,
            urlString: "https://habr.com/ru/articles/957390/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 17),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "Combine",
            intro: """
                A collection of posts about Combine.
                """,
            author: "Create With Swift",
            postType: .course,
            urlString: "https://www.createwithswift.com/tag/combine/",
            postPlatform: .website,
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "@propertyWrapper: Encoding Strings to Valid URL Characters",
            intro: """
                With this @propertyWrapper code snippet you will be able to wrap String values into wrapped values of url safe characters.
                
                Porperty wrappers serve as a new type to wrap properties and add additional logic if needed. It's part of Swift since version 5.1 and can be useful to validate values woth a set of rules or tranform values to match certain requirements etc.
                
                As a simple example, you might want to ensure that String is using upper case, for example to correctly describe the abbreviation of federal states in the U.S. like California (CA) or New York (NY) or you could ensure that a url provided as a String includes only valid url characters.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/propertywrapper-reference-encoding-strings-to-valid-urls/",
            postPlatform: .website,
            postDate: Date.from(year: 2021, month: 6, day: 24),
            studyLevel: .middle,
            notes: """
                The Swift Programming Language (6.2)
                Properties
                https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/
                """,
            origin: .cloud
        ),
        Post(
            title: "Combine: Combining Operators",
            intro: """
                With these short code snippets you will be able to combine operators when configuring publishers in Combine.
            
                This brief overview will demonstrate some basic features that may come in handy when working with publishers in Combine, Apple's framework to handle asynchronous events by combining event-processing operators. The Publisher protocol declares a type that transmits a sequence of values over time that subscribers can receive as input by adopting the Subscriber protocol.
            
                Using a sequence as values to publish, Combine allows typical operators available in Swift to shape the values that will be published or received. These operators can also be combined to customize results to your liking.
            """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/reference-combine-combining-operators/",
            postPlatform: .website,
            postDate: Date.from(year: 2021, month: 9, day: 1),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Combine: switchToLatest",
            intro: """
                With this short reference code snippet, you will be able to use the convenient switchToLatest() operator when configuring subscribers in Combine.
                
                This brief overview will demonstrate some basic features that may come in handy when working with publishers in Combine, Apple's framework to handle asynchronous events by combining event-processing operators. The Publisher protocol declares a type that transmits a sequence of values over time that subscribers can receive as input by adopting the Subscriber protocol.
                
                A common use case would be that multiple requests for asynchronous work may be issued, but only the latest request is really needed. For example, requests could be aimed at loading images from a remote source. A user might tap on a button to load the image but may decide to move on and tap on another button to load another image before the first request is even completed. In this case, subscriptions in Combine can be configured with a .switchToLatest() operator to receive a new publisher from the upstream publisher and cancel its previous subscription.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/reference-combine-switchtolatest/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 1, day: 27),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Publishing DocC Documentation as a Static Website on GitHub Pages",
            intro: """
                This tutorial shows how to generate DocC documentation archives, how to process them for static hosting and deploy the on GitHub Pages.
                
                At WWDC 2021, Apple introduced DocC. It is an amazing framework to create rich API reference documentation and interactive tutorials for Swift projects, frameworks, or packages. With a custom DocC Markdown syntax - documentation markup - the compiler can create rich documentation for Swift projects and displays it right in the Xcode documentation window.
                
                Even better, you can also host the generated documentation on a website with the same look and feel as the official Apple Developer Documentation. While this was a bit complicated in the beginning, as of Xcode 13.3, exporting DocC documentation for static websites has become pretty straightforward. So let's have a look.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/publishing-docc-documention-as-a-static-website-on-github-pages/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 2, day: 22),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Using SF Symbols in SwiftUI",
            intro: """
                This reference article covers how to use SF Symbols in SwiftUI and the most common modifiers associated with them.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-sf-symbols-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 4, day: 5),
            studyLevel: .beginner,
            notes: """
                SF Symbols is a library of icons designed to be used with the San Francisco font, the system font for Apple platforms. You can have access to the library of over 3,000 symbols by downloading the mac app available on the official Apple Website.

                https://developer.apple.com/sf-symbols/?ref=createwithswift.com

                And for guidelines on how to use them on your applications check the Human Interface Guidelines page dedicated to them. In there you can see all the different properties you can change and even how to create your custom symbols.

                https://developer.apple.com/design/human-interface-guidelines/sf-symbols/overview/?ref=createwithswift.com
                """,
            origin: .cloud
        ),
        Post(
            title: "Using ViewThatFits to replace GeometryReader in SwiftUI",
            intro: """
                This article shows how to use the new ViewThatFits released at WWDC 2022 to replace GeometryReader when building views in SwiftUI.
                """,
            author: "Marco Falanga",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-viewthatfits-to-replace-geometryreader-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 6, day: 16),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Adaptive layouts with ViewThatFits",
            intro: """
                In iOS 16 SwiftUI introduces a new API to create adaptive layouts ViewThatFits. This API allows us to provide alternative views when a certain view doesn't fit into available space.
                
                I've been experimenting with ViewThatFits to see what kind of layouts we can achieve and I would like to share my findings so far in this post.
                """,
            author: "Natalia Panferova",
            postType: .post,
            urlString: "https://nilcoalescing.com/blog/AdaptiveLayoutsWithViewThatFits/?ref=createwithswift.com",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 7, day: 11),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "How to check if Text is truncated in SwiftUI?",
            intro: """
                When displaying text of various lengths, our design needs to be clear on whether there should be a maximum number of displayable lines, or if the full text should always be shown.
                
                Text doesn't always behave predictably: sometimes the text gets truncated for no apparent reason, despite having plenty of space at our disposal (e.g. within Forms and Lists).
                
                In this article, let's have a look at how we can deal with these scenarios, and more.
                """,
            author: "Federico Zanetello",
            postType: .post,
            urlString: "https://www.fivestars.blog/articles/trucated-text/",
            postPlatform: .website,
            postDate: Date.from(year: 2021, month: 1, day: 12),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Prototyping SwiftUI interfaces with OpenAI's ChatGPT",
            intro: """
                Understand how to use OpenAI's ChatGPT conversational machine learning model to create working code for SwitfUI apps within a few minutes.
                
                In recent months and years, OpenAI released many artificial intelligence APIs and machine learning models that support use cases from text summarization, translation, parsing unstructured data, clasification, text composition and many more. The latest addition is a model called ChatGPT which is implemented as an conversational tool.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/building-a-swiftui-app-to-interact-with-the-openai-chatgpt-api/",
            postPlatform: .website,
            postDate: Date.from(year: 2022, month: 12, day: 3),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "Creating a SwiftUI App to interact with the OpenAI ChatGPT API",
            intro: """
                Understand how to use the OpenAISwift Package to easily connect with the OpenAI API to create your own ChaptGPT SwiftUI app.
                
                The internet is overflowing with many examples of OpenAI's ChatGPT use cases, ranging from funny to mindblowing 🤯. We already explored its ability to create usable Swift code based on simple prompts. Today we want to help you to get started with creating your own ChatGPT-based app.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/building-a-swiftui-app-to-interact-with-the-openai-chatgpt-api/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 2, day: 14),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "Creating a SwiftUI App to generate Text Completions with GPT-3.5 through the OpenAI API",
            intro: """
                Understand how to use the OpenAI Swift Package to connect with the OpenAI API to generate text completions within your SwiftUI app.
                
                Since the release of ChatGPT, OpenAI is as hot as ever within the field of artificial intelligence. Yet, OpenAI has many more capabiltites to offer beyond the conversational chatbot. For example, the ability to generate text completions with GPT-3.5 or even GTP-4 from natural language prompts.
                
                MacPaw recently published an open-source OpenAI Swift Package that abstracts access to the OpenAI HTTP API and allows you to create apps that interface with the OpenAI capabilities easily. The library allow you to use GTP-3.5 or GPT-4 through the different model families, Dalle-E and other OpenAI features. Register at openai.com/api and obtain an API key to get started.
                
                Follow along to learn how to generate responses with GPT-3.5, also called completions, through the OpenAI API with just a few lines of code.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-a-swiftui-app-to-generate-text-completions-with-gpt-3-5-through-the-openai-api/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 5, day: 23),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "Updating the User’s Location with Core Location and Swift Concurrency in SwiftUI",
            intro: """
                Learn how to create an asynchronous API to access Core Location on a SwiftUI app.
                
                You can create your own wrappers to manage access to iOS core services, taking advantage of the features of the Swift language to create modern and flexible APIs for your application.
                
                One of the services you can work with is Core Location, using Swift Concurrency to create a simple and elegant approach to accessing the user location. With a CheckedContinuation object, we can interface between synchronous and asynchronous code, so we can update the location of the user once the location manager can retrieve it using delegation.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/updating-the-users-location-with-core-location-and-swift-concurrency-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 10, day: 10),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "Animating numeric text in SwiftUI with the Content Transition modifier",
            intro: """
                Learn how to use the content transition modifier to animate numeric text in SwiftUI.
                
                ContentTransition is a simple modifier you can use to create animated transitions upon content change in your SwiftUI applications. For example, when you have a numeric value that changes over time or upon an action triggering the change, like the time on a timer or a currency that updates live.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/animating-numeric-text-in-swiftui-with-the-content-transition-modifier/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 17),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Accessing the app life cycle within a SwiftUI app",
            intro: """
                Learn how to have access to the application life cycle of a SwiftUI-based app.
                
                There are procedures within the execution of an application that must be executed at a specific moment of its life-cycle, for example when the app finishes launching, when it goes to the background, or right before it is closed.
                
                Within the App protocol in SwiftUI, the launch options are limited in defining the entry point of our application. In order to access different moments of the life cycle of the application we must use an object that conforms to the UIApplicationDelegate protocol, which is defined as the default entry point of a UIKit-based application.
                
                In this reference article, we will disclose how to work with the life cycle of a SwiftUI app.
                """,
            author: "Matteo Altobello, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/accessing-the-app-life-cycle-within-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2023, month: 11, day: 28),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Picking an Image from the Photos Library in a SwiftUI App",
            intro: """
                Learn how to use the photos picker to allow users to select a photo from their photo library.
                
                The PhotosPicker component enables users to import photos or videos from their photos library directly within a SwiftUI app. This reference will guide you through the implementation of this component.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/picking-an-image-from-the-photos-library-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 1, day: 16),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Create an animated transition with Matched Geometry Effect in SwiftUI",
            intro: """
                Learn how to use matched geometry effect to animate views in SwiftUI.
                
                In SwiftUI we can create smooth transitions between views from one state to another with the Matched Geometry Effect. Using unique identifiers we can blend the geometry of two views with the same identifier creating an animated transition. Transitions like this can be useful for navigation or changing the state of UI elements.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/create-an-animated-transition-with-matched-geometry-effect-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 2, day: 9),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "Using Swift Charts on a SwiftUI app",
            intro: """
                Learn how to use the Swift Charts framework to present charts on a SwiftUI app.
                
                Introduced at WWDC22, Swift Charts allows you to create rich charts in your SwiftUI application. With this framework, developers can represent data in different forms of visualization with just a few lines of code.
                This tutorial will explore the Swift Charts framework to plot your data with the available chart views and how to customize them to represent data effectively.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-swift-charts-on-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 1),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Sign in with Apple on a SwiftUI application",
            intro: """
                Learn how to add Sign in with Apple to a SwiftUI project using the Authentication Services framework.
                
                Sign in with Apple is an authentication service that leverages Apple ID credentials for login, eliminating the need to create and manage separate passwords. This service integrates deeply into the Apple ecosystem and offers a secure, fast, and user-friendly authentication experience. It offers a quick and private method for signing into apps and provides users with a consistent and immediate experience.
                
                In this article, we will guide you through implementing the Sign in with Apple button in a SwiftUI app.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/sign-in-with-apple-on-a-swiftui-application/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 5),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "Creating a custom view modifier in SwiftUI",
            intro: """
                Learn how to create custom view modifiers on SwiftUI.
                
                Let’s understand how to create custom View Modifiers in a SwiftUI app project.
                
                From the official Apple documentation, a modifier is what you apply to a view or another view modifier, producing a different version of the original value.
                
                In SwiftUI, modifiers are one of the building blocks of how we create our user interfaces. They allow us to modify the Views we place on the UI visually, to add behaviors to our interface components, and to insert a view into another view structure.
                """,
            author: "Tiago Gomes Pereira, Pasquale Vittoriosi",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-a-custom-view-modifier-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 3, day: 21),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Camera capture setup in a SwiftUI app",
            intro: """
                In this short tutorial you will learn how to set a camera feed capture in a SwiftUI app.
                
                There are numerous guides discussing how to obtain a camera feed on an iOS app. Let’s explore a method that works on all devices that have at least one integrated camera.
                You will learn the easiest and quickest method to obtain a live feed and use it in an app created with SwiftUI. It serves as a foundation for incorporating a camera feed into projects that need so.
                """,
            author: "Gianluca Orpello",
            postType: .post,
            urlString: "https://www.createwithswift.com/camera-capture-setup-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 4),
            studyLevel: .middle,
            notes: """
                AVFoundation
                """,
            origin: .cloud
        ),
        Post(
            title: "Display empty states with ContentUnavailableView in SwiftUI",
            intro: """
                Learn how to use the ContentUnavailableView to represent empty states in a SwiftUI application.
                
                If you've ever encountered an iOS app that fails to display content due to network issues or empty data sets you might have seen a "content unavailable" view.
                
                This view was introduced in iOS 17 both in SwiftUI and UIKit to indicate that the content cannot be displayed.
                
                It's typically displayed in the following scenarios:
                - When you have an empty list of elements
                - When the detail view of a NavigationSplitView has nothing selected
                - When a search doesn't return any results
                - When there is no internet connection
                
                In this article, we'll take a closer look at when to use this view and how to use it correctly in SwiftUI.
                """,
            author: "Pasquale Vittoriosi",
            postType: .post,
            urlString: "https://www.createwithswift.com/display-empty-states-with-contentunavailableview-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 9),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Making your lists searchable in a SwiftUI app",
            intro: """
                Learn how to make a list searchable in a SwiftUI application.
                
                When listing information on our application interfaces one of the most common actions a user expects to be able to do is to filter that list in order to find the specific data they are looking for, without having to scroll through the whole list.
                
                Enabling search on your lists in a SwiftUI application is made possible by using the searchable(text:placement:prompt:) modifier. It automatically configures the user interface to display the search field.
                
                In this short tutorial, we will implement a simple search by filtering functionality on a List view on SwiftUI using the searchable(text:placement:prompt:) modifier.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/making-your-lists-searchable-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 4, day: 16),
            studyLevel: .beginner,
            notes: """
                The searchable modifier has many variations and you can find them all on the official page for search in the Apple documentation:

                https://developer.apple.com/documentation/swiftui/search?ref=createwithswift.com
                """,
            origin: .cloud
        ),
        Post(
            title: "Using gradients in SwiftUI",
            intro: """
                Learn how to use the different types of gradients to color your SwiftUI views.
                
                In this article, we will explore the world of gradients in SwiftUI, including the different types and properties for creating customized gradient effects in our View.
                
                The different ways of creating gradients we will explore are:
                - Simple gradient
                - Custom gradient
                - Linear gradient
                - Angular gradient
                - Angular gradient
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-gradients-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 7),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Using materials with SwiftUI",
            intro: """
                Learn how to use materials in a SwiftUI app interface.
                
                To improve the readability of our content we can create a visual separation between background and foreground using a Material, a translucent layer that serves to blur the background while maintaining the clarity of the foreground content.
                
                In augmented reality apps for example, by using materials we ensure that symbols and labels remain legible in every frame.
                
                Materials are also fundamental when our app features an image as background, like the Weather app, where separating the content from the background is crucial to accessing the information effectively.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-materials-with-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 14),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Providing feedback with the sensory feedback modifier",
            intro: """
                Learn how to easily add haptic feedback to your app using the sensory feedback modifier in SwiftUI.
                
                Feedback is one of the key design principles behind iOS. Receiving a visual, audio, or haptic response to the actions performed improves the user experience of an app and you can find them all around the operational system.
                
                From unlocking the iPhone with Face ID to using toggles, menus, and all the native components, this type of feedback enriches the user experience and guides the user in understanding what's happening and the result of certain operations.
                
                Incorporating haptic feedback into our app has never been easier using the new sensoryFeedback(trigger:_:) modifier. After the user performs an action, we can specify the type of feedback to be delivered to the user.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/providing-feedback-sensory-feedback-modifier/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 5, day: 21),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Using App Intents in a SwiftUI app",
            intro: """
                Learn how to add App Intents to your SwiftUI app enabling users to reach its main functionalities from anywhere on the phone.
                
                Released with iOS 16, the AppIntents framework enables developers to extend the core functionality of an app to system services like Siri, Spotlight, Shortcut, and the new Action Button. In this way, users can use your app features almost everywhere in the system.
                
                In this tutorial, we will guide you on how to integrate the AppIntents framework within a SwiftUI app by building a simple movie tracker. In this app, users will be able to add a new movie and mark a movie as seen, complete with a rating, by only using actions in the Shortcut app.
                
                By the end of this tutorial, you will understand how to expose your app's logic and entities to the operative system and create useful actions that are available in the system.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-app-intents-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 4),
            studyLevel: .advanced,
            origin: .cloud
        ),
        Post(
            title: "Using multi-step animations in SwiftUI",
            intro: """
                Explore how to define and use a multi-step animation in your SwiftUI app.
                
                Animations can serve as visual indicators that inform users about activities within your app. They are especially useful when the user interface state changes, such as when loading new content or revealing new actions, improving the overall look of your app.
                
                We will utilize the PhaseAnimator container to define a multi-step animation for our view. This is especially beneficial when we require an animation that loops continuously and responds to events.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-multi-step-animations-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 25),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Formatting time in a Text view in SwiftUI",
            intro: """
                Discover how to format data about time to be displayed in a SwiftUI app.                
                Rendering the data of your application on the user’s interface used to require parsing the data as text yourself, but the Text view makes our lives easier with the Text(_:format:) initializer.
                
                New format styles were introduced in iOS 18 to support rendering information about time, including format style for:
                - Date Offsets
                - Date References
                - Stopwatches
                - Timers
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/formatting-time-in-a-text-view-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 23),
            studyLevel: .beginner,
            notes: """
                TimelineView()
                .Date.FormatStyle
                SystemFormatStyle.DateOffset
                SystemFormatStyle.DateReference
                SystemFormatStyle.Stopwatch
                SystemFormatStyle.Timer
                .addingTimeInterval
            """,
            origin: .cloud
        ),
        Post(
            title: "Formatting data in a Text view in SwiftUI",
            intro: """
                Learn how to format different types of data within the Text view in SwiftUI.   
                
                SwiftUI’s Text view offers a wide range of options for formatting text, allowing us to display currencies, dates, measurements, and other types of data in a user-friendly manner.
                """,
            author: "Tiago Gomes Pereira, Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/formatting-data-as-text-in-a-text-view-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 7),
            studyLevel: .beginner,
            notes: """
                Measurement()
                Measurement.FormatStyle
                .measurement
                Date.FormatStyle
                ListFormatStyle
                PersonNameComponents
                inflect
            """,
            origin: .cloud
        ),
        Post(
            title: "Converting between image formats",
            intro: """
                Discover how to convert between CIImage, CGImage, and UIImage and use them within an Image view.                
                
                When working with images in your app development projects, you may have to convert between different types to use the image for the intended purposes.
                
                A common use case for example can be switching between using the UIImage class, commonly used in UIKit to assign images to a UIImageView and the Image view used to present pictures in a SwiftUI app.
                """,
            author: "Moritz Philip Recke",
            postType: .post,
            urlString: "https://www.createwithswift.com/converting-between-image-formats/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 17),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Preparing your App Icon for dark and tinted appearance",
            intro: """
                Discover the new requirements for app icons introduced with iOS 18.                
                
                During WWDC24, Apple announced major changes to how App Icons are displayed on the Home Screen. Users can now customize the App Icons to adapt to a fixed Dark Mode or apply a color tint to them.
                """,
            author: "Flora Damiano",
            postType: .post,
            urlString: "https://www.createwithswift.com/preparing-your-app-icon-for-dark-and-tinted-appearance/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 20),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Animating SF Symbols with the symbol effect modifier",
            intro: """
                Explore the different ways you can animate SF Symbols with SwiftUI.                
                One of the latest enhancements Apple introduced for SF Symbols is the ability to play dynamic animations and visual effects using the symbolEffect(_:) modifier. For example, when connecting to Wi-Fi or mirroring a screen, these subtle animations help users understand the current status or progress of the action.
                
                In this guide, we will see the various types of animations available and show how to implement them in our SF Symbols.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/animating-sf-symbols-with-the-symbol-effect-modifier/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 6, day: 26),
            studyLevel: .beginner,
            notes: """
                symbolEffect(_:options:value:)
            
                Appear (AppearSymbolEffect)
                Disappear (DisappearSymbolEffect)
                Bounce (BounceSymbolEffect)
                Scale (ScaleSymbolEffect)
                Variable Color (VariableColorSymbolEffect)
                Pulse (PulseSymbolEffect)
                Replace (ReplaceSymbolEffect)
            
                Wiggle (WiggleSymbolEffect)
                Rotate (RotateSymbolEffect)
                Breath (BreatheSymbolEffect)
            
                DiscreteSymbolEffect
                IndefiniteSymbolEffect
                TransitionSymbolEffect
                ContentTransitionSymbolEffect
            """,
            origin: .cloud
        ),
        Post(
            title: "Translating text in your SwiftUI app with the Translation framework",
            intro: """
                Discover how to use the Translation framework to provide text translation features within a SwiftUI app.
                
                The Translation API is one of the new tools introduced during WWDC24, and it is available for developers to natively translate content inside their apps using machine learning models that run locally on the device without requiring an internet connection. Until now this option was only available in Safari and some native apps like Messages.
                
                IIn this reference, we will cover how to integrate the translation API overlay within a simple SwiftUI View.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/translating-text-in-your-swiftui-app-with-the-translation-framework/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 8, day: 1),
            studyLevel: .middle,
            notes: """
                translationPresentation
            """,
            origin: .cloud
        ),
        Post(
            title: "Using the Translation framework for language-to-language translation",
            intro: """
                Learn how to translate text to a specific language using on-device models with the Translation framework.

                The article "Translating text in your SwiftUI app with the Translation framework" covers adding a presentation overlay to enable basic translation in an application.
                
                To have a deeper translation integration in our app we can utilize the translationTask(_:action:) modifier from the Translation framework. This modifier allows us to translate our app's content using local ML models even when offline.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-the-translation-framework-for-language-to-language-translation/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 8, day: 2),
            studyLevel: .middle,
            notes: """
                TranslationSession.Configuration
                translationTask
                translate
                prepareTranslation
            """,
            origin: .cloud
        ),
        Post(
            title: "Text Effects using TextRenderer in SwiftUI",
            intro: """
                Explore the TextRenderer protocol and learn how to make text effects in a SwiftUI app.

                When you find yourself limited by the built-in SwiftUI Text modifiers and want to create more dynamic, animated, or custom-rendered text, you’ll be happy to know that Apple introduced a powerful new API in iOS 18 and aligned releases: TextRenderer.
                
                With TextRenderer, we can take complete control over how text is drawn, enabling effects ranging from subtle highlights to full character animations.
                """,
            author: "Letizia Granata",
            postType: .post,
            urlString: "https://www.createwithswift.com/text-effects-using-textrenderer-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 28),
            studyLevel: .middle,
            notes: """
                The key is combining:
                - TextRenderer -> custom drawing logic;
                - Animatable -> time-based changes;
                - TextAttribute -> selective emphasis;
                - Transition -> integration into SwiftUI animations.
            
                a text gradually fading out
                pulse effect
                bounce effect
                BounceAttribute
                BounceRenderer
            """,
            origin: .cloud
        ),
        Post(
            title: "Using the zoom navigation transition in SwiftUI",
            intro: """
                Learn how to use the zoom navigation transition from iOS 18 in a SwiftUI app.

                The NavigationTransition protocol allows developers to customize transitions between Views using the .navigationTransition(_:) modifier. Beyond the typical left-to-right movement, a new zoom transition effect has been introduced that can be particularly useful for presenting UI items on a full screen.
                
                In this reference, we will integrate the new Zoom transition to push a View within a NavigationStack.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-the-zoom-navigation-transition-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 9, day: 26),
            studyLevel: .middle,
            notes: """
                @Namespace
                .zoom
                .matchedTransitionSource
            """,
            origin: .cloud
        ),
        Post(
            title: "Giving depth to your App Icons",
            intro: """
                Learn how to enhance your App Icon’s design by adding depth effects.

                Icons have always lived in our displays, serving as the first point of contact between the user and the interface. They encapsulate the greatest value of your product at a glance and act as the business card of your application across different contexts.
                """,
            author: "Flora Damiano",
            postType: .post,
            urlString: "https://www.createwithswift.com/giving-depth-to-your-app-icons/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 3),
            studyLevel: .middle,
            notes: """
                @Namespace
                .zoom
                .matchedTransitionSource
            """,
            origin: .cloud
        ),
        Post(
            title: "Applying visual effects combined with scrolling in SwiftUI",
            intro: """
                Learn how to apply visual effects to your views while scrolling with SwiftUI.

                Visual effects are powerful tools used for improving the aesthetics and usability of applications. Their usage is crucial when it comes to creating engaging and visually appealing interfaces while keeping them dynamic and responsive to interactions, ensuring both clarity and accessibility.
                
                Visual effects are used on application and operational system levels in more places than we imagine. Here are some examples of how visual effects improve the user experience:
                
                - Adjusting blurs, shadows, materials, or the scaling of UI components can create a sense of depth and layering. It establishes a clear visual hierarchy by highlighting key elements on the screen, maintaining context, and enhancing readability.
                
                - The visual feedback from user interactions - rendered as adjusting brightness, contrast, hue, saturation, opacity, scaling, rotation, etc. - emphasizes user actions or changes in the app's state.
                
                - They are also employed in the creation of smooth transitions between different parts of the app, making navigation feel natural and fluid.
                
                Let's explore how to use the visualEffect(_:) modifier to implement visual effects in a SwiftUI view.
                """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/applying-visual-effects-combined-with-scrolling-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 10),
            studyLevel: .middle,
            notes: """
                visualEffect
                .hueRotation
            """,
            origin: .cloud
        ),
        Post(
            title: "Plotting math equations using Swift Charts",
            intro: """
                Discover how to plot math equations using Swift Charts in a SwiftUI app.

                The tutorial Using Swift Charts in a SwiftUI app shows how to represent data in different forms of visualization with just a few lines of code. Since this WWDC24 the Swift Charts framework also supports mathematical equation plotting introducing two new charts components, LinePlot and AreaPlot.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/plotting-math-equation-using-swift-charts/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 11),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Creating view transitions in SwiftUI",
            intro: """
                Learn how to use create animated transitions in a SwiftUI using the transition and animation modifiers.

                Transitions are animated visual effects that smoothen the change between different views or layouts when UI elements change state, preventing abrupt shifts.
                
                They enhance the user experience by making interactions more fluid and polished. By providing visual feedback during interface changes the connection between different UI elements and actions is visually highlighted. Examples are:
                - when navigating between screens;
                - when adding or removing items from a list;
                - when displaying modal views.
                
                This guidance makes the app feel more cohesive, responsive, and easier to use.
                
                We will explore how to implement built-in transitions and how to create custom ones for more tailored behaviors, using the transition(_:) method and the Transition protocol.
                """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-view-transitions-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 24),
            studyLevel: .middle,
            notes: """
                Transition
                TransitionPhase
                move, slide, push, scale
                combined
                """,
            origin: .cloud
        ),
        Post(
            title: "Implement blurring when multitasking in SwiftUI",
            intro: """
                Learn how to implement automatic screen blurring in SwiftUI apps to enhance user privacy when the app enters multitasking mode.

                Enhancing user privacy is critical in modern app development. This tutorial explains how to build a SwiftUI app that automatically blurs its screen when it enters multitasking or background mode, a useful privacy feature for protecting sensitive content.
                
                We'll explore how to implement this concept with a playful example involving developer "secrets," which get blurred when the app isn’t active. Following this step-by-step short tutorial, you'll learn how to apply this privacy technique in your SwiftUI apps.
                """,
            author: "Giovanni Monaco",
            postType: .post,
            urlString: "https://www.createwithswift.com/implement-blurring-when-multitasking-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 10, day: 29),
            studyLevel: .middle,
            notes: """
                blur
                """,
            origin: .cloud
        ),
        Post(
            title: "Prevent screenshot capture of sensitive SwiftUI views",
            intro: """
                Learn to build a SwiftUI modifier that hides sensitive content from screenshots and screen recordings, which is ideal for apps prioritizing user privacy.

                This short tutorial will guide you through implementing a privacy feature in SwiftUI to prevent sensitive content from appearing in both screenshots and screen recordings. Such a feature is valuable for apps handling private user data, like financial, healthcare, or messaging apps.
                """,
            author: "Giovanni Monaco",
            postType: .post,
            urlString: "https://www.createwithswift.com/prevent-screenshot-capture-of-sensitive-swiftui-views/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 11, day: 5),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Exploring Interactive Bottom Sheets in SwiftUI",
            intro: """
                Explore how to effectively use presentation detents to create interactive customized sheets like those in the Apple Maps, Find My and Stocks apps.

                In this article, we’ll explore how to effectively use presentationDetents and related modifiers to create interactive customized sheets like those in the mentioned apps.
                """,
            author: "Pasquale Vittoriosi",
            postType: .post,
            urlString: "https://www.createwithswift.com/exploring-interactive-bottom-sheets-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 11, day: 19),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Implementing search suggestions in SwiftUI",
            intro: """
                Learn how to provide suggestions when searching in a SwiftUI app by building an example app with real-time filtering, search suggestions, and recent search tracking.

                SwiftUI's searchSuggestions(_:) modifier is a powerful feature that enhances the search experience in iOS applications. When combined with the tracking of recent searches, it creates an intuitive interface that helps users quickly find what they're looking for and easily return to previously viewed items.
                
                Let’s create an Apple Products catalog app that showcases SwiftUI's search capabilities. We'll implement a smart search system that not only filters products in real-time but also provides search suggestions and keeps track of recently viewed items.
                
                By the end of this tutorial, you'll learn how to:
                -Implement real-time search filtering
                -Display dynamic search suggestions
                -Track and show recent searches
                -Create a seamless navigation experience
                """,
            author: "Giovanni Monaco",
            postType: .post,
            urlString: "https://www.createwithswift.com/implementing-search-suggestions-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 11, day: 26),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Mastering Forms in SwiftUI: Creating and Styling",
            intro: """
                Learn how to create and customize the appearance of data-entry interfaces using forms in SwiftUI apps.

                Applications, in order to deliver value to their user, often rely on user-generated data to work with. A reminders app needs reminders, a calendar app needs events, a contacts app needs contact information, and apps that rely on tracking, in general, need the user to input the information in the app.
                
                User-created content comes in many shapes and forms and one of the most common use cases for user input is by presenting a form for them to fill.
                
                Forms serve as the backbone of user interaction, presenting an interface for data entry. They are everywhere, whether it’s signing up for a service, making a purchase, or providing feedback.
                
                On SwiftUI the Form container provides a standardized look and feel for data input experiences, very similar to the List container. The different types of views and controls you place inside it will be organized in a list-like fashion, with scrolling working and the ability to create sections.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/mastering-forms-in-swiftui-creating-and-styling/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 12, day: 8),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Mastering Forms in SwiftUI: Selecting Information",
            intro: """
                Learn how to use picker, date picker and color picker controls to provide a proper single data selection data-entry experience in a form in SwiftUI apps.

                When creating data-entry experiences in iOS apps, SwiftUI's Picker view offers a solution that allows users to select from a list of distinct options. This component enhances form interfaces by providing an intuitive and efficient way to make selections across various app contexts like settings screens and profile configurations.
                
                SwiftUI has three controls for single-value selection: Picker, DatePicker and ColorPicker. They present multiple visual configurations so you as a developer can choose the one that better adapts to the needs of your user experience.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/mastering-forms-in-swiftui-selecting-information//",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 12, day: 11),
            studyLevel: .beginner,
            notes: """
                TextField
                """,
            origin: .cloud
        ),
        Post(
            title: "Mastering Forms in SwiftUI: Creating and Styling",
            intro: """
                Learn how to use text fields and secure field controls in forms in SwiftUI apps.

                An essential type of information collected by filling out forms is text. It could be a simple entry, like the username for an account, or a longer text entry, like the bio for a user profile. SwiftUI has multiple types of views to support form-based data-entry experiences.
                
                The importance of providing a good user experience for collecting text-based information cannot be overlooked, and when it is it communicates to the user a lack of care by the developer. Apple’s Human Interface Guidelines provide a set of best practices and platform considerations when using text fields in your application user interface.
                """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/mastering-forms-in-swiftui-text-fields/",
            postPlatform: .website,
            postDate: Date.from(year: 2024, month: 12, day: 17),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Enhance UI/UX with the confirmation dialog component",
            intro: """
                Understand how to use confirmation dialogs within a SwiftUI app.

                The confirmationDialog sheet is a SwiftUI component that presents a temporary dialog to confirm an action or provide a set of related options. It appears from the bottom of the screen and offers buttons for users to make a choice which can include destructive actions, multiple choices, or simply canceling the operation.

                In the Apple ecosystem, it is used when you want to:
                - Present the user with a set of options or a specific context;
                - Confirm their intent before proceeding with an action that can be potentially destructive;
                - Offering a way to cancel or back out of an action.
                """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/enhance-ui-ux-with-the-confirmation-dialog-component/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 1, day: 7),
            studyLevel: .beginner,
            notes: """
                    .confirmationDialog(
                        // 1. The title of the Sheet
                        "Title for the confirmation Dialog Sheet",
                        
                        // 2. The bool to enable the presentation of the sheet
                        isPresented: $isPresented,
                        
                        // 3. The visibility of the title
                        titleVisibility: .visible,
                        
                        // 4. Data to be presented
                        presenting: dataToPresent
                        
                    ) { data in
                        // 5. Buttons for different types of actions
                        // a. A destructive action
                        Button("Confirm", role: .destructive) {
                            // Do something
                        }
                        // b. Different Options Actions
                        Button("An action") {
                            // Do something
                        }
                        Button("Another action") {
                            // Do something
                        }
                        
                        // c. Cancel the action
                        Button("Cancel", role: .cancel) {
                            isPresented = false
                        }
                    }
            """,
            origin: .cloud
        ),
        Post(
            title: "Keyboard-driven actions in SwiftUI with onKeyPress",
            intro: """
                Learn how to capture and respond to the pressed keys in a hardware keyboard in a SwiftUI app.
            
                In iOS 17 and later, you can use the onKeyPress(_:action:) method to make a view respond to a physical keyboard event. It detects when a key is pressed and lets you perform actions based on it.
            
                To take advantage of this method, be sure the view is focusable.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/keyboard-driven-actions-in-swiftui-with-onkeypress/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 1, day: 9),
            studyLevel: .beginner,
            notes: """
                @FocusState
                .focusable
                .focused
                .onKeyPress
                """,
            origin: .cloud
        ),
        Post(
            title: "Controlling keyboard events with keys and phases",
            intro: """
                Learn how to respond to pressed keys and phases in a hardware keyboard in a SwiftUI app.

                The onKeyPress(_:action:) method is present in several variations, providing complete control over triggering actions. These variations allow the developer to specify exactly how and when actions should be executed in response to key presses.

                The behavior can be customized by specifying:
                - particular keys being pressed;
                - the phase of a key press;
                - a combination of both keys and their phases;
                - the characters produced by the pressed keys.
                """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/controlling-keyboard-events-with-keys-and-phases/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 1, day: 10),
            studyLevel: .beginner,
            notes: """
                @FocusState
                .focusable
                .focused
                .onKeyPress
                KeyEquivalent
                KeyPress.Phases
                CharacterSet
                """,
            origin: .cloud
        ),
        Post(
            title: "Implementing tab bar in a SwiftUI app",
            intro: """
                Learn how to implement tab bar navigation with SwiftUI on iOS, iPadOS, macOS and visionOS.
            
                When designing our app, we must carefully choose the components to implement, understand their purpose, and determine when and how they should be used. One of the most commonly used components for app navigation is the tab bar. This enables what is often called flat navigation, allowing users to access different sections of the app by simply tapping on a specific tab.
            
                With the SwiftUI framework, implementing this type of component is as straightforward as it gets because developers can use the built-in tab bar with just a few lines of code. This not only simplifies our work but also ensures users enjoy a consistent experience across all apps installed on their devices.
            
                Of course, different devices require different kinds of experiences. We will have an overview of how tabs behave in the different operating systems and how to implement the tab bar within an app.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/implementing-tab-bar-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 1, day: 30),
            studyLevel: .beginner,
            notes: """
                When you use custom symbol in tab bar remember to have a look at the Human Interface Guidelines to export them in the correct size.

                https://developer.apple.com/design/human-interface-guidelines/tab-bars?ref=createwithswift.com#Target-dimensions

                Additionally to automatically enable the accent color for your custom symbol set the"Render As" option as "Template Image, you can find this option in the Attribute Inspector section.
                """,
            origin: .cloud
        ),
        Post(
            title: "Grouping Controls with ControlGroup",
            intro: """
                Understand how to use control groups, improving the user experience of your SwiftUI apps.
            
                ControlGroup is a SwiftUI component introduced with iOS 15 that allows arranging together semantically connected controls. This container view helps to improve the app user experience by adding:
                - clarity - as visual organization enables easier understanding;
                - discoverability - as it makes related actions easier to be found and used;
                - consistency - as it provides a consistent visual pattern for related actions.
            
                All resulting in a more intuitive and user-friendly interface.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/grouping-controls-with-controlgroup/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 6),
            studyLevel: .beginner,
        notes: """
            ImageResource
            .controlGroupStyle
            """,
            origin: .cloud
        ),
        Post(
            title: "Enabling Interaction with Table View in SwiftUI",
            intro: """
                Discover how to enable single-selection, multi-selection and collapsible rows on a Table view in a SwiftUI app.
            
                Representing data within an app using tables offers users a clear and effective overview at a glance. A significant enhancement is enabling users to interact with the table rows, allowing them to perform actions like copying or sharing data with other apps.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/enabling-interaction-with-table-view-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 18),
            studyLevel: .middle,
            notes: """
                Table
                TableColumn
                TableRow
                .contextMenu
                DisclosureTableRow
                """,
            origin: .cloud
        ),
        Post(
            title: "Creating Custom SF Symbols",
            intro: """
                Learn everything you need to know to create custom SF Symbols for your applications.
            
                Introduced in 2019 with 1,000 symbols, the SF Symbols library has since grown exponentially, reaching a substantial 6,000 symbols over six years. These symbols are designed to integrate seamlessly with Apple’s San Francisco font, ensuring visual consistency across apps. This enhances user familiarity, promotes intuitive navigation, and creates a smoother experience across devices.
            
                With the extensive variety SF Symbols offers, it's rare not to find a symbol that fits your app's needs. The comprehensive collection caters to a wide range of use cases, reducing the necessity to design icons from scratch.
            
                However, there is always room for customization: if a specific symbol isn't available, for instance, icons can be exported into vector graphics editing tools, modified, or created entirely from scratch, maintaining the shared design language and accessibility features of the existing library. This flexibility ensures that app interfaces can be unique and consistent with Apple's design standards.
            
                There are many ways to create a new custom symbol and despite which of these ways is going to be used, the process always follows the same structure:
                - Create the symbol.
                    = Optionally, you can customize it to have more control over its rendering behavior.
                - Get the file ready to be used in the Xcode.
                - Use the symbols in a SwiftUI view.
            
                Let’s explore this process.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-custom-sf-symbols/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 20),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Grouping Controls with ControlGroup",
            intro: """
                Understand how to use control groups, improving the user experience of your SwiftUI apps.
            
                ControlGroup is a SwiftUI component introduced with iOS 15 that allows arranging together semantically connected controls. This container view helps to improve the app user experience by adding:
                - clarity - as visual organization enables easier understanding;
                - discoverability - as it makes related actions easier to be found and used;
                - consistency - as it provides a consistent visual pattern for related actions.
            
                All resulting in a more intuitive and user-friendly interface.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/grouping-controls-with-controlgroup/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 6),
            studyLevel: .beginner,
            notes: """
                ImageResource
                .controlGroupStyle
                """,
            origin: .cloud
        ),
        Post(
            title: "Enabling Interaction with Table View in SwiftUI",
            intro: """
                Discover how to enable single-selection, multi-selection and collapsible rows on a Table view in a SwiftUI app.
            
                Representing data within an app using tables offers users a clear and effective overview at a glance. A significant enhancement is enabling users to interact with the table rows, allowing them to perform actions like copying or sharing data with other apps.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/enabling-interaction-with-table-view-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 18),
            studyLevel: .middle,
            notes: """
                Table
                TableColumn
                TableRow
                .contextMenu
                DisclosureTableRow
                """,
            origin: .cloud
        ),
        Post(
            title: "Generating images programmatically with Image Playground",
            intro: """
                Learn how to use the ImageCreator API to create images programmatically within a SwiftUI app.
            
                The ImageCreator API is available in beta for Apple Intelligence compatible devices with at least iOS 18.4, iPadOS 18.4, MacOS 15.4 and visionOS 2.4 or higher.
            
                By using the new ImageCreator API, developers can programmatically generate images using Apple’s local models without relying on the Image Playground interface. This provides greater flexibility and integration possibilities within applications while ensuring that image generation remains efficient and secure.
            
                To generate images, we need to provide three parameters:
                -A textual prompt for the image
                -The desired style
                -The maximum number of images to be generated
            
                By understanding and optimizing these parameters, we can fully leverage the API’s capabilities to create high-quality, customized images that meet our needs. Let’s explore how to make the most of this powerful tool.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/generating-images-programmatically-with-image-playground/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 26),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Generating images programmatically with Image Playground",
            intro: """
                Learn how to use the ImageCreator API to create images programmatically within a SwiftUI app.
            
                The ImageCreator API is available in beta for Apple Intelligence compatible devices with at least iOS 18.4, iPadOS 18.4, MacOS 15.4 and visionOS 2.4 or higher.
            
                By using the new ImageCreator API, developers can programmatically generate images using Apple’s local models without relying on the Image Playground interface. This provides greater flexibility and integration possibilities within applications while ensuring that image generation remains efficient and secure.
            
                To generate images, we need to provide three parameters:
                -A textual prompt for the image
                -The desired style
                -The maximum number of images to be generated
            
                By understanding and optimizing these parameters, we can fully leverage the API’s capabilities to create high-quality, customized images that meet our needs. Let’s explore how to make the most of this powerful tool.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/generating-images-programmatically-with-image-playground/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 26),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Symmetrical and asymmetrical transitions in SwiftUI with the Scroll Transition modifier",
            intro: """
                Learn how to implement animated scroll transitions when the view enters and exits the visible area in a SwiftUI application.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/symmetrical-and-asymmetrical-transitions-in-swiftui-with-the-scroll-transition-modifier/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 2, day: 27),
            studyLevel: .middle,
        notes: """
            scrollTransition
            ScrollTransitionConfiguration
            ScrollTransitionPhase
            """,
            origin: .cloud
        ),
        Post(
            title: "Placing UI components within the Safe Area Inset",
            intro: """
                Learn how to place views and controls on the borders of a view container in a SwiftUI app.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/placing-ui-components-within-the-safe-area-inset/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 3, day: 13),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Dynamically adapting to available space with ViewThatFits",
            intro: """
                Learn how to create views that adapt their size in order to fill the available space on the UI with SwiftUI.
            
                ViewThatFits is a SwiftUI component introduced from iOS 16 that allows your view to become responsive according to the available space that will contain it.
            
                By providing a series of possible views to display - ordered by preference, the component will use the @ViewBuilder to build the first one that fits the space available.
            
                This is very useful when the parent’s container size is not fixed and you want the child view to adapt based on that size.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/dynamically-adapting-to-available-space-with-viewthatfits/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 3, day: 20),
            studyLevel: .advanced,
            notes: """
                ViewThatFits
                @ViewBuilder 
            """,
            origin: .cloud
        ),
        Post(
            title: "Presenting an Inspector with SwiftUI",
            intro: """
                Learn how to use the inspector API to provide details in your user interface in SwiftUI.
            
                Introduced with iOS 17, iPadOS 17 and macOS 14, the inspector is a SwiftUI element that displays extra information about selected content. It can be implemented by using the inspector(isPresented:content:) modifier. It is usually used when you need to inspect, edit or customize properties of an object, actions or files in a more detailed and structured way.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/presenting-an-inspector-with-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 4, day: 1),
            studyLevel: .advanced,
            notes: """
                iPad
                NavigationStack
                NavigationSplitView
                navigationBar 
            """,
            origin: .cloud
        ),
        Post(
            title: "Mastering Forms in SwiftUI: Toggles",
            intro: """
                Learn how to create and customize the appearance of toggles in a form-based experience with SwiftUI.
            
                A constant presence in any form-based experience is to provide answers to yes-or-no questions. They can also be found within an app user interface, most commonly on settings or customization panels, as options to turn on or off.
            
                The toggle is the UI element that translates this use case in the user interface, and it can be visually represented as a switch (on mobile interfaces and when representing an on and off state), a toggled button, or a checkbox (on desktop interfaces or when representing a metaphor of “inclusion”)
            """,
            author: "Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/mastering-forms-in-swiftui-toggles/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 4, day: 4),
            studyLevel: .advanced,
            notes: """
                Toggling multiple options at once
                isOn
                bundle
                toggleStyle(.switch)
                toggleStyle(.button)
                toggleStyle(.checkbox)
            """,
            origin: .cloud
        ),
        Post(
            title: "Create flexible interfaces in SwiftUI",
            intro: """
                Learn how to bind your view’s size to its container in a SwiftUI app.
            
                When building interfaces, we want them to look good on different devices or screen sizes. Starting from iOS 17, views have been enriched with a new modifier, containerRelativeFrame(_:alignment:_:), which makes it easier to create user interfaces that automatically adjust based on the size of its nearest container.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/create-flexible-interfaces-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 4, day: 1),
            studyLevel: .advanced,
            notes: """
                containerRelativeFrame
            """,
            origin: .cloud
        ),
        Post(
            title: "Integrating TimelineView in a SwiftUI app",
            intro: """
                Learn how to periodically refresh and update UI components, enabling smooth and efficient animations in your SwiftUI app.
            
                The TimelineView is a powerful container view in SwiftUI designed to build dynamic, time-based interfaces. Unlike traditional views that update only when state changes, TimelineView allows updates to occur on a defined schedule, making it ideal for smooth, continuous animations and building interactive elements that respond to the passage of time.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/integrating-timelineview-in-a-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 4, day: 10),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Donate content to Spotlight and open it using NSUserActivity",
            intro: """
                Learn how to expose the content of your app to Spotlight.
            
                In this article, we’ll explore how to make your app content discoverable in Spotlight and navigate users directly to detailed views using a combination of CSSearchableItem and NSUserActivity.
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/donate-content-to-spotlight-and-open-it-using-nsuseractivity/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 6, day: 10),
            studyLevel: .advanced,
            notes: """
                CoreSpotlight
                AppIntent
                IndexedEntity
                OpenIntent
                CSSearchableItem
                CSSearchableIndex
                indexSearchableItems
                Deep Link
                NSUserActivity
                CSSearchableItemActionType
                IndexedEntity
                CSSearchableItemAttributeSet 
            """,
            origin: .cloud
        ),
        Post(
            title: "Creating valid dates using the Swift language",
            intro: """
                Learn how to convert DateComponents into a valid Date using a Calendar instance.
            
                Date is the type we use to handle calendar information in Swift. It stores all the information needed to represent a specific point in time, independent of any calendar or time zone, by representing a time interval relative to an absolute reference date.
            
            In an application’s user interface, it is common to handle dates and times by picking specific calendar values to represent the date. A user will usually choose a day, a month, an hour, or a minute, for example and then your application will have to transform that value into a valid Date value.
            
            That’s where DateComponents comes in handy. It allows you to represent a date or time in terms of units, which can then be evaluated in a calendar system and time zone.
            """,
            author: "Gabriel Fernandes Thomaz, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-valid-dates-using-the-swift-language/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 6, day: 19),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Triggering actions after a time interval with Timers",
            intro: """
                Learn how to trigger actions or emit a message after a certain period of time in the Swift language.
            
               If you need to trigger an action or send a message after a certain period of time, use the Timer class, which lets you schedule actions to run in the future, with or without repetition.
            """,
            author: "Gabriel Fernandes Thomaz, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/triggering-actions-after-a-time-interval-with-timers/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 6, day: 17),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Implementing advanced speech-to-text in your SwiftUI app",
            intro: """
                Learn how to integrate real-time voice transcription into your application using SpeechAnalyzer.
            
                Apple has recently introduced speech-to-text functionality across many of its apps, including Notes and Voice Memos, reflecting a broader shift toward voice as a primary input method. In line with this, Apple has released a new API called SpeechAnalyzer, which leverages a faster, more efficient model specifically fine-tuned for processing longer audio recordings and handling speech from distant speakers.
            
                By the end of this tutorial, you will understand how to access an audio buffer using the microphone and then make it available for the new SpeechAnalyzer class to process and convert into text.
            """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/implementing-advanced-speech-to-text-in-your-swiftui-app/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 8, day: 5),
            studyLevel: .advanced,
            notes: """
                Speech
                AVFoundation
                AVAudioApplication
                AVAudioPCMBuffer
                .measurement
                .duckOthers
                stopAudioStream()
                SFSpeechRecognizer
               SpeechTranscriber
            """,
            origin: .cloud
        ),
        Post(
            title: "Making the tab bar collapse while scrolling",
            intro: """
                Learn how to make tab bar minimize when responding to scrolling gesture using the new minimize behavior modifier.
            
                With iOS 26 and the Liquid Glass design system, Apple introduced a new way the tab bar can respond to scrolling. Compliant to its Liquid Glass core principle, content first, TabView can now collapse as you scroll, letting the tab bar step out of the way so your content can take center stage.
            
                The modifier that enables this behavior is tabBarMinimizeBehavior(_:).
            """,
            author: "Antonella Giugliano",
            postType: .post,
            urlString: "https://www.createwithswift.com/making-the-tab-bar-collapse-while-scrolling/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 8, day: 28),
            studyLevel: .middle,
            origin: .cloud
        ),
        Post(
            title: "Exploring Concentricity in SwiftUI",
            intro: """
                Learn about the concept of concentricity applied to UI elements in a SwiftUI app.
                
                Concentricity is one of the key design principles Apple highlighted at the last WWDC. It’s a concept already present in many parts of their operating systems. A clear example is the Dynamic Island, where its corner radius perfectly mirrors the rounded corners of the device’s bezel.
                """,
            author: "Matteo Altobello",
            postType: .post,
            urlString: "https://www.createwithswift.com/exploring-concentricity-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 9, day: 5),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Displaying web content in SwiftUI",
            intro: """
                At WWDC 2025, Apple unveiled a new SwiftUI native view for displaying web content directly in SwiftUI, without the need to bridge with UIKit, the WebView, available for iOS 26, macOS 26, and more.
                
                Part of the WebKit framework, SwiftUI's view WebView offers two distinct approaches depending on your needs:
                - Simple URL-based loading
                - Advanced control with WebPage
                """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/displaying-web-content-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 9, day: 11),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Creating custom layouts with SwiftUI",
            intro: """
                Understand how to create custom layouts with the Layout protocol in SwiftUI.
            
                When you find yourself struggling with GeometryReader to position views exactly where you want them, or when HStack and VStack just can't create the layout you're envisioning because you have complex positioning requirements that built-in layouts can't handle... maybe you need custom layouts.
            
                Built-in layouts work great for common patterns, but they have limitations. For example, VStack and HStack only allow linear arrangements, LazyVGrid allows fixed column structures, ZStack is only about simple layering without intelligent positioning and GeometryReader can give performance issues and requires complex calculations.
            
                Custom layouts in SwiftUI are types that define the geometry of a collection of views. Instead of relying on the predefined behavior of built-in layouts, you can create your own layout logic that positions views exactly where you want them.
            """,
            author: "Letizia Granata",
            postType: .post,
            urlString: "https://www.createwithswift.com/creating-custom-layouts-with-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 9, day: 16),
            studyLevel: .middle,
            notes: """
                CNContactStore
                requestAccess
                authorizationStatus
                CNAuthorizationStatus
            """,
            origin: .cloud
        ),
        Post(
            title: "Presenting critical information in SwiftUI with alerts",
            intro: """
                Learn how to create and use alerts within a SwiftUI app.
            
                There are different ways to present information in a modal experience, one of which is through alerts. An alert interrupts the user with critical information they need immediately and presents different actions that can be triggered directly from the alert itself.
            
                Use alerts for important messages, such as communicating errors, requesting confirmations (especially for destructive actions), or requesting permission.
            
                SwiftUI provides several variations of the alert modifier, each designed for different use cases. By understanding these different alert presentations, you can choose the most appropriate approach for each situation in your SwiftUI applications, creating better user experiences that provide the right information at the right time.
            """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/presenting-critical-information-in-swiftui-with-alerts/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 9, day: 30),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Getting started with the Contacts framework",
            intro: """
                Learn how to get access to the user contacts for your SwiftUI applications.
            
                If you need to trigger an action or send a message after a certain period of time, use the Timer class, which lets you schedule actions to run in the future, with or without repetition.
            """,
            author: "Gabriel Fernandes Thomaz, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/getting-started-with-the-contacts-framework/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 18),
            studyLevel: .middle,
            notes: """
                CNContactStore
                requestAccess
                authorizationStatus
                CNAuthorizationStatus
            """,
            origin: .cloud
        ),
        Post(
            title: "Listing contacts with the Contacts framework",
            intro: """
                Learn how to fetch contact information with the Contacts framework.
            
                The Contacts framework provides you with he tools necessary for listing, reading, and displaying contact information from the user’s virtual address book.
            """,
            author: "Gabriel Fernandes Thomaz, Tiago Gomes Pereira",
            postType: .post,
            urlString: "https://www.createwithswift.com/listing-contacts-with-the-contacts-framework/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 19),
            studyLevel: .middle,
            notes: """
                CNContactStore
                requestAccess
                authorizationStatus
                CNAuthorizationStatus
            """,
            origin: .cloud
        ),
        Post(
            title: "Implementing draw animations for SF Symbols in SwiftUI",
            intro: """
                Learn how to apply the new draw animations of SF Symbols 7 in a SwiftUI app.
            
                When adding visuals to your SwiftUI app, SF Symbols have always been a reliable choice to maintain consistency with Apple's Human Interface Guidelines in iconography. With SF Symbols 7 and iOS 26, Apple introduces draw animations, a new feature that brings icons to life.
            """,
            author: "Letizia Granata",
            postType: .post,
            urlString: "https://www.createwithswift.com/implementing-draw-animations-for-sf-symbols-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 30),
            studyLevel: .beginner,
            origin: .cloud
        ),
        Post(
            title: "Programmatic navigation with navigation destination in SwiftUI",
            intro: """
                Learn how to use the navigation destination modifier for triggering navigation in a SwiftUI app.
            
                SwiftUI’s modern NavigationStack isolates the logic of how navigation is triggered from how the UI handles it. While NavigationLink(destination:label:) can directly navigate to a view, the navigation destination modifiers provide a more flexible, data-driven approach. Let's explore the different variations of the modifier and when to use each of them.
            """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/programmatic-navigation-with-navigation-destination-in-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 3),
            studyLevel: .beginner,
            notes: """
                navigationDestination
                NavigationPath
            """,
            origin: .cloud
        ),
        Post(
            title: "Taking control of your navigation in SwiftUI with NavigationPath",
            intro: """
                Understand how to perform data-driven navigation in a SwiftUI app.
            
                SwiftUI's NavigationStack and NavigationPath provide a powerful and flexible way to perform programmatic navigation in your app. When managing navigation in a SwiftUI app, you often want to push and pop views programmatically, and NavigationPath enables this while also maintaining strong type-safety and flexibility.
            
                The NavigationStack(root:) default initializer sets the root of your navigation hierarchy and handles the navigation path behind the scenes. If you want more control over the navigation path and enable a programmatic approach to your navigation, you can store it with a @State variable and pass it to the NavigationStack(path:root:) initializer. The path parameter needs to be of Binding<Data> type and there are two ways you can use it.
            """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/taking-control-of-your-navigation-in-swiftui-with-navigationpath/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 9),
            studyLevel: .beginner,
            notes: """
                navigationDestination
                NavigationPath
                """,
            origin: .cloud
        ),
        Post(
            title: "Using rich text in the TextEditor with SwiftUI",
            intro: """
                Explore the usage of rich text within the TextEditor in SwiftUI using AttributedString.
            
                When you need to display and edit long-form text in SwiftUI, TextEditor is often the natural choice. By default, it works with a simple String and behaves as a plain text editor, making it ideal for simple notes or basic input fields.
            
                But starting with iOS 26, macOS 26, and related platforms, TextEditor gained first-class support for AttributedString. With this change, you can transition from editing plain text to creating fully formatted rich text, complete with Markdown, links, attribute transformations, and more.
            """,
            author: "Alfonso Tarallo",
            postType: .post,
            urlString: "https://www.createwithswift.com/using-rich-text-in-the-texteditor-with-swiftui/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 17),
            studyLevel: .beginner,
            notes: """
                AttributedString
                AttributeContainer
                AttributedTextSelection
                typingAttributes
                transformAttributes
                """,
            origin: .cloud
        ),
// 2025-10-31
        Post(
            title: "Swift Codable",
            intro: """
                Swift Codable - протокол, позволяющий преобразовывать структуры в бинарные данные и обратно. В этой cтатье раскрыт механизм его работы "под капотом".
                """,
            author: "Grandschtien",
            postType: .post,
            urlString: "https://habr.com/ru/articles/953560/",
            postPlatform: .website,
            postDate: Date.from(year: 2025, month: 10, day: 5),
            studyLevel: .beginner),
        Post(
            title: "Swift: Dead Simple Formatting (Dates, Numbers, Currency, Measurement, Time)",
            intro: """
                In this video I show you the power of the FormatStyle API as well as a resource that shows examples of all the ways you can format numbers, currency, dates, measurements, time, and more. You can now easily create any format you like with this powerful API.
                """,
            author: "Sean Allen",
            postType: .post,
            urlString: "https://habr.com/ru/articles/953560/",
            postPlatform: .youtube,
            postDate: Date.from(year: 2025, month: 1, day: 2),
            studyLevel: .beginner,
            notes: """
                https://fuckingformatstyle.com/
                https://github.com/brettohland/fuckingformatstyle
                """,
            origin: .cloud
        ),
        Post(
            title: "Format Styles In Excruciating Detail",
            intro: """
                Swift’s FormatStyle and ParseableFormatStyle are the easiest way to convert Foundation data types to and from localized strings. Unfortunately Apple hasn’t done a great job in documenting just what it can do, or how to use them.

                This site is going to help you do just that.
            """,
            author: "Ampersandsoftworks",
            postType: .post,
            urlString: "https://fuckingformatstyle.com/#the-basics",
            postPlatform: .website,
            postDate: nil,
            studyLevel: .beginner,
            origin: .cloud
        ),
        
        
        
        
        
        
        
    ]
    
    

}

// 2025-10-25

