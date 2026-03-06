//
//  ButtonURL.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 18.11.2025.
//

import SwiftUI

struct LinkButtonURL: View {
    
    let buttonTitle: String
    let urlString: String
    
//    private var validURL: URL? {
//        guard let url = URL.withScheme(urlString) else { return nil }
//        return url.isValidWebURL ? url : nil
//    }
    
    private var validURL: URL? {
        URL.withScheme(urlString).flatMap { $0.isValidWebURL ? $0 : nil }
    }
    
    private var isValid: Bool { validURL != nil }

    var body: some View {
        
        ZStack {
            if let url = validURL {
                Link(destination: url){
                    buttonLabel
                }
            } else {
                // Показываем задизейбленную кнопку вместо пустоты
                buttonLabel
                    .opacity(0.4)
                    .overlay(
                        Text("Invalid URL")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.top, 36),
                        alignment: .center
                    )
            }
        }
    }
    
    private var buttonLabel: some View {
        Text(buttonTitle)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(Color.mycolor.mySectionBackground)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(isValid ? Color.mycolor.myBlue : Color.mycolor.myRed, in: .capsule)
    }

}

extension URL {
    /// Creates a URL with a guaranteed https:// scheme if it is missing
    static func withScheme(_ string: String) -> URL? {
        
        // Cleaning String
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        // Replacing http:// with https://
        if trimmed.lowercased().hasPrefix("http://") {
            return URL(string: "https://" + trimmed.dropFirst("http://".count))
        }
            
        if trimmed.lowercased().hasPrefix("https://") {
            return URL(string: trimmed)
        }
        
        // Reject any other schemes: ftp://, mailto:, etc.
        if trimmed.contains("://") || trimmed.contains(":") {
            return nil
        }
        
        // Reject lines with spaces — they cannot be a valid host
        if trimmed.contains(" ") {
            return nil
        }

        // Adding https:// automatically
        return URL(string: "https://" + trimmed)
    }
    
    /// Checking the URL is suitable for opening in the browser.
    var isValidWebURL: Bool {
        guard let scheme = scheme?.lowercased() else { return false }
        return (scheme == "http" || scheme == "https") && host != nil
    }
}


#Preview("URL Validation") {
    let urls = [
        "https://www.apple.com",     // ✅ valid https
        "http://www.apple.com",      // ✅ converted to https
        "www.apple.com",             // ✅ added https
        "ftp://server",              // ❌ Invalid URL
        "",                          // ❌ Invalid URL
        "not a url !@#",             // ❌ Invalid URL
    ]
    
    ScrollView {
        VStack(spacing: 12) {
            ForEach(urls, id: \.self) { urlString in
                VStack(alignment: .leading, spacing: 4) {
                    // Подпись чтобы видеть какой urlString тестируем
                    Text(urlString.isEmpty ? "(empty)" : urlString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    LinkButtonURL(
                        buttonTitle: "Go to the Source",
                        urlString: urlString
                    )
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}

