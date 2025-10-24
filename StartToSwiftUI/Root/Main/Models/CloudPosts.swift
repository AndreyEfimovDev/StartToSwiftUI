//
//  CloudPostsViewModel.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 24.10.2025.
//

import Foundation

// CloudPosts model is for:
// - to download posts from Cloud as intermediate data massive between Cloud posts and App posts
// - to check and compare dates of Cloud posts and App posts for update purpose. If a date of Cloud posts is later than a date of App posts then a user will be notificated for updates on a HomeView when the App is lalunched or in the Preferences at the "Check posts for updates" button

struct CloudPosts: Codable {
    let dateStamp: Date
    let cloudPosts: [Post]
    
}
