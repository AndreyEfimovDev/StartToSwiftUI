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
    @State private var showNoticeDetails: Bool = false
    
    var body: some View {
        ZStack {
            if noticevm.notices.isEmpty {
                noticesIsEmpty
            } else {
                ZStack {
                    List {
                        ForEach(noticevm.notices) { notice in
                            
                            noticesRow(notice: notice)
                                .listRowBackground(Color.clear)
                                .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
                                .listRowSeparator(.hidden, edges: [.top])
                                .listRowInsets(
                                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                                )
                        } // ForEach
                    } // List
                    .listStyle(.plain)
                    .background(Color.mycolor.myBackground)
                    
                    if showNoticeDetails {
                        if let selectedNotice = selectedNotice {
                            NavigationStack {
                                NoticeDetailsView(noticeId: selectedNotice.id) {
                                    withAnimation {
                                        showNoticeDetails = false
                                    }
                                }
                                .transition(.move(edge: .trailing))
                                .zIndex(1)
                            }
                        }
                    }
//                    .sheet(item: $selectedNotice) { notice in
//                        NoticeDetailsView(noticeId: notice.id)
//                    }
                } // ZStack
            } // if empty
        } // ZStack
        .navigationTitle("Notifications")
        .navigationBarBackButtonHidden(true)
        .toolbar(showNoticeDetails ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }
    }
    
    private func noticesRow(notice: Notice) -> some View {
        
        HStack {
            Button {
                selectedNotice = notice
                showNoticeDetails = true
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
                    noticevm.isReadToggle(notice: notice)
                }
                .tint(notice.isRead ? Color.mycolor.mySecondaryText : Color.mycolor.myBlue)
            } // left side swipe action buttons
        } // HStack
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

