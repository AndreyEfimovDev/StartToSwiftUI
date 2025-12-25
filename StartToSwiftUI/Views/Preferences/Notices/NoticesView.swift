//
//  NotificationsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import SwiftUI
import SwiftData

struct NoticesView: View {
    
    let isRootModal: Bool
    
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    private let hapticManager = HapticService.shared
    
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
                                        coordinator.pushModal(.noticeDetails(noticeId: notice.id))
                                    }
                                    // right side swipe action buttonss
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
                                    }
                                    // left side swipe action buttons
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button(notice.isRead ? "Unread" : "Read", systemImage: notice.isRead ?  "eye.slash.circle" : "eye.circle") {
                                            noticevm.isReadToggle(notice: notice)
                                        }
                                        .tint(notice.isRead ? Color.mycolor.mySecondary : Color.mycolor.myBlue)
                                    }                            } // ForEach
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
                            .listRowSeparator(.hidden, edges: [.top])
                            .listRowInsets(
                                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                            )
                        } // List
                        .listStyle(.plain)
                    } // ZStack
                }
            } // ZStack
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if isRootModal {
                    // Open as root window (from HomeView)
                    // Show Back button only
                    ToolbarItem(placement: .topBarLeading) {
                        BackButtonView() {
                            coordinator.closeModal()
                        }
                    }
                } else {
                    // Opened as a child window (from PreferencesView)
                    // Show Back and Home buttons
                    ToolbarItem(placement: .topBarLeading) {
                        BackButtonView() {
                            coordinator.popModal()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            coordinator.closeModal()
                        } label: {
                            Image(systemName: "house")
                                .foregroundStyle(Color.mycolor.myAccent)
                        }
                    }
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
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let noticevm = NoticeViewModel(modelContext: context)
    
    NavigationStack {
        NoticesView(isRootModal: true)
            .environmentObject(noticevm)
            .environmentObject(NavigationCoordinator())
    }
}

