//
//  FBNoticeManager.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 20.02.2026.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct FBNoticeModel {
    let noticeId: String
    let title: String
    let message: String
    let noticeDate: Date
    
    init(
        noticeId: String,
        title: String,
        message: String,
        noticeDate: Date
    ) {
        self.noticeId = noticeId
        self.title = title
        self.message = message
        self.noticeDate = noticeDate
    }
}


final class FBNoticesManager {
    
    static let shared = FBNoticesManager()
    
    private init() {
    }
    
    private let noticesCollection: CollectionReference = Firestore.firestore().collection("notices")
    
    private func noticeDocument(noticeId: String) -> DocumentReference {
        noticesCollection.document(noticeId)
    }
    
    func getAllNotices() async {
//        var noticeValidated: FBNoticeModel? = nil
//        var noticesReceived: [FBNoticeModel] = []
        do {
            let querySnapshot = try await noticesCollection.getDocuments()
            for noticeSnapShot in querySnapshot.documents {
                print("\(noticeSnapShot.documentID) => \(noticeSnapShot.data())")
            }
        } catch {
            print("error in getting all notices")
        }
    }
}

