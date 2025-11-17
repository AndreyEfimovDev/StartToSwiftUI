//
//  NotificationsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import SwiftUI

struct NoticesView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let hapticManager = HapticService.shared
    @EnvironmentObject private var noticevm: NoticeViewModel
    
    @State private var selectedNotice: Notice?
    
    var body: some View {
        ZStack {
            if noticevm.notices.isEmpty {
                noticesIsEmpty
            } else {
                List {
                    ForEach(noticevm.notices) { notice in
                        HStack {
                            Circle()
                                .fill(Color.mycolor.myBlue)
                                .frame(width: 5, height: 5)
                                .opacity(notice.isRead ? 0 : 1)

                            Button {
                                selectedNotice = notice
                            } label: {
                                NoticeRowView(notice: notice)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    withAnimation {
                                        noticevm.deleteNotice(notice: notice)
                                        hapticManager.notification(type: .success)
                                    }
                                } label: {
                                    VStack {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                            .font(.caption2)
                                    }
                                }
                                .tint(Color.mycolor.myRed)
                            } // right side swipe action buttonss
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(notice.isRead ? "Unread" : "Read", systemImage: notice.isRead ?  "eye.slash.circle" : "eye.circle") {
                                    withAnimation {
                                        noticevm.isReadToggle(notice: notice)
                                    }
                                }
                                .tint(notice.isRead ? Color.mycolor.mySecondaryText : Color.mycolor.myBlue)
                            } // left side swipe action buttons
                        } // HStack
                    } // ForEach
                } // List
                .sheet(item: $selectedNotice) { notice in
                        NoticeDetailsView(noticeId: notice.id)
                }
            } // if empty
        } // ZStack
        .navigationTitle("Notifications")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }
    }
    
    private var noticesIsEmpty: some View {
        ContentUnavailableView(
            "No notices",
            systemImage: "tray.and.arrow.down",
            description: Text("Notices will appear here when are available.")
        )
    }
    
    
}

#Preview {
    NavigationStack {
        NoticesView()
    }
    .environmentObject(NoticeViewModel())
    
}

