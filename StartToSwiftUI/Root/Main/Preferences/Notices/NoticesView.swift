//
//  NotificationsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import SwiftUI

struct NoticesView: View {
    
    private let hapticManager = HapticService.shared
    @EnvironmentObject private var nvm: NotificationCentre

    @State private var selectedNoticeId: String?
    @State private var selectedNotice: Notice?
    @State private var showDetailView: Bool = false

    
    var body: some View {
        
            List {
                ForEach(nvm.notices) { notice in
//                    HStack {
                        //                        Circle()
                        //                        .fill(.white)
                        //                        .frame(width: 15, height: 15)
                        //                        .overlay(
                        //                            Capsule()
                        //                                .stroke(Color.mycolor.myBlue, lineWidth: 1)
                        //                        )
                        //                        .frame(width: 30, height: 30)
                        //                        .padding(4)
                        //                        .border(.accent)
                        //                        .opacity(0)
                        
                        NoticeRowView(notice: notice)
                            .border(.red)
                            .onTapGesture {
                                selectedNoticeId = notice.id
                                showDetailView.toggle()
                            }
                        
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", systemImage: "trash") {
                                    selectedNotice = notice
                                    hapticManager.notification(type: .warning)
                                }.tint(Color.mycolor.myRed)
                            } // right side swipe action buttonss
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(notice.isRead ? "Unread" : "Read" , systemImage: notice.isRead ?  "heart.slash.fill" : "heart.fill") {
                                    nvm.isReadSet(notice: notice)
                                }
                                .tint(notice.isRead ? Color.mycolor.mySecondaryText : Color.mycolor.myYellow)
                            } // left side swipe action buttons
//                    }
                } // ForEach
                
            } // List
            .navigationDestination(isPresented: $showDetailView) {
                
                if let id = selectedNoticeId {                    NoticeDetailsView(noticeId: id)
                }
            }
        }
    
}

#Preview {
    NavigationStack {
        NoticesView()
    }
    .environmentObject(NotificationCentre())

}
