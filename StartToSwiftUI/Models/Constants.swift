//
//  Constants.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 23.10.2025.
//

import Foundation


struct Constants {
#warning("Check correct url for curated Posts before deployment to App Store")
    // GitHub cloud url on JSON file with curated posts
//    static let cloudPostsURL = "https://raw.githubusercontent.com/AndreyEfimovDev/Support/refs/heads/main/cloudPosts.json"
    // GitHub cloud url on JSON file with with TEST curated posts
    static let cloudPostsURL = "https://raw.githubusercontent.com/AndreyEfimovDev/Archive/refs/heads/main/cloudPosts.json"

#warning("Check correct url for Notices before deployment to App Store")
    // GitHub cloud url on JSON file with notifications
//    static let cloudNoticesURL = "https://raw.githubusercontent.com/AndreyEfimovDev/Support/refs/heads/main/notificaions_app.json"
    // GitHub cloud url on JSON file with TEST notifications
    static let cloudNoticesURL = "https://raw.githubusercontent.com/AndreyEfimovDev/Archive/refs/heads/main/notificaions_app.json"

    static let mainCategory = "SwiftUI"
    // Filename for File Manager to keep all posts locally saved
    static let localPostsFileName = "posts_app.json"
    
    // Filename for File Manager to keep all notificaions locally saved
    static let localNoticesFileName = "notificaions_app.json"

    static let urlStart = "https://"
}
