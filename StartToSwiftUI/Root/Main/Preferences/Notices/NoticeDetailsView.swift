//
//  NoticesDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 16.11.2025.
//

import SwiftUI

struct NoticeDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var noticevm: NotificationCentre

    let noticeId: String
    
    private var notice: Notice? {
        noticevm.notices.first(where: { $0.id == noticeId })
    }
    
    var body: some View {
        if let validNotice = notice {
            ScrollView(showsIndicators: false) {
                VStack{
                    Text(validNotice.title)
                    Text(validNotice.noticeMessage)
                    Text(validNotice.noticeDate.formatted(date: .numeric, time: .omitted))
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                toolbarForNoticeDetails()
            }
            .onDisappear {
                noticevm.isReadSet(notice: validNotice)
            }
        }

    }
    
    
    @ToolbarContentBuilder
    private func toolbarForNoticeDetails() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            CircleStrokeButtonView(
                iconName: "chevron.left",
                isShownCircle: false)
            {
                dismiss()
            }
        }
    }
    
}

fileprivate struct NoticeDetailsPreView: View {
    
    
    let sampleNotices: [Notice] = [
        Notice(
            title: "Update for the curated posts in available",
            noticeDate: .now,
            noticeMessage: "New Update includes the following:",
            isRead: true
        ),
        Notice(
            title: "New App release 01.01.02 is availavle New App release 01.01.02 is availavle",
            noticeDate: .now + 1,
            noticeMessage: """
                New release includes the following:
                Line 1
                Line 2
                Line 3
                """,
            isRead: true
        ),
        Notice(
            title: "New App release 01.01.03 is availavle",
            noticeDate: .now + 2,
            noticeMessage: """
                New release includes the following:
                Line 1
                Line 2
                Line 3
                """
        )
        
        
    ]
    
    var body: some View {
        NavigationStack {
            NoticeDetailsView(noticeId: sampleNotices.first!.id)
        }
    }
//    private func createPreviewViewModel() -> PostsViewModel {
//        let viewModel = PostsViewModel()
//        viewModel.allPosts = DevData.postsForCloud
//        return viewModel
//    }
    
}


#Preview {
    NavigationStack{
        NoticeDetailsPreView()
    }
    .environmentObject(NotificationCentre())
}
