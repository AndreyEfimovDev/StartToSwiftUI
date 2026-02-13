//
//  EmailService.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.09.2025.
//

import Foundation
import SwiftUI


struct EmailService {
    
    func sendEmail(to: String, subject: String, body: String) {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
