//
//  NotificationsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import SwiftUI

struct NoticesView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var noticevm: NoticeViewModel

    private let hapticManager = HapticService.shared
    
    @State private var selectedNoticeID: String?
    @State private var showNoticeDetails: Bool = false
    
    var body: some View {
        ZStack {
            if noticevm.notices.isEmpty {
                noticesIsEmpty
            } else {
                ZStack {
                    List {
                        ForEach(noticevm.notices.sorted {$0.noticeDate > $1.noticeDate}) { notice in
                            NoticeRowView(notice: notice)
                                .background(.black.opacity(0.001))
                                .onTapGesture {
                                    selectedNoticeID = notice.id
                                    showNoticeDetails.toggle()
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
                        } // ForEach
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
                        .listRowSeparator(.hidden, edges: [.top])
                        .listRowInsets(
                            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                    } // List
                    .listStyle(.plain)
                } // ZStack
            } // if empty
        } // ZStack
        .navigationTitle("Notifications")
        .navigationBarBackButtonHidden(true)
//        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleStrokeButtonView(iconName: "chevron.left", isShownCircle: false) {
                    dismiss()
                }
            }
        }
        .navigationDestination(isPresented: $showNoticeDetails) {
            if let id = selectedNoticeID {
                withAnimation {
                    NoticeDetailsView(noticeId: id)
                }
            }
        }
        .onAppear {
            // Set User to be informed of new notices
            if !noticevm.isUserNotified {
                noticevm.isUserNotified = true
            }
        }
    }
    
    private var noticesIsEmpty: some View {
        ContentUnavailableView(
            "No notifications",
            systemImage: "tray.and.arrow.down",
            description: Text("Messages will appear here when are available.")
        )
    }
    
    
}

#Preview {
    NavigationStack {
        NoticesView()
            .environmentObject(NoticeViewModel())
    }
}

