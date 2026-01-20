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
    @EnvironmentObject private var coordinator: AppCoordinator
    
    private let hapticManager = HapticService.shared
    
    @State private var showNoticeDetails: Bool = false
    
    var body: some View {
     
            ZStack {
                if noticevm.notices.isEmpty {
                    noticesIsEmpty
                } else {
                    noticesContent
                }
            } // ZStack
            .navigationBarBackButtonHidden(true)
            .toolbar {
                navigationToolbar()
            }
    }
    
    private var noticesContent: some View {
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
                        }
                } // ForEach
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
                .listRowSeparator(.hidden, edges: [.top])
                .listRowInsets(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
            }
            .listStyle(.plain)
        }
    }
    
    @ToolbarContentBuilder
    private func navigationToolbar() -> some ToolbarContent {
        if isRootModal {
            // Open as root View (from HomeView)
            // Show Back button only
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView() {
                    coordinator.closeModal()
                }
            }
        } else {
            // Opened as a child View (from PreferencesView)
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
    
    private var noticesIsEmpty: some View {
        ContentUnavailableView(
            "No notifications",
            systemImage: "tray.and.arrow.down",
            description: Text("Messages will appear here when are available.")
        )
    }
    
}

#Preview("Root Modal (from HomeView)"){
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
        
    let mockNotices = [
        Notice(
            title: "Notice Title 1",
            noticeDate: Date().addingTimeInterval(-3600), // 1 hr back
            noticeMessage: "",
            isRead: true
        ),
        Notice(
            title: "Notice Title 2",
            noticeDate: Date().addingTimeInterval(-7200), // 2 hrs back
            noticeMessage: "",
            isRead: false
        ),
        Notice(
            title: "Notice Title 3",
            noticeDate: Date().addingTimeInterval(-86400), // 1 day back
            noticeMessage: "",
            isRead: true
        ),
        Notice(
            title: "Notice Title 4",
            noticeDate: Date().addingTimeInterval(-172800), // 2 days back
            noticeMessage: "",
            isRead: false
        )
    ]
        
    for notice in mockNotices {
        context.insert(notice)
    }

    try? context.save()

    let noticevm = NoticeViewModel(modelContext: context)
    let coordinator = AppCoordinator()

    return Group {
        NavigationStack {
            NoticesView(isRootModal: true)
                .environmentObject(noticevm)
                .environmentObject(coordinator)
                .modelContainer(container)
        }
    }
    .background(Color.mycolor.myBackground)
    .ignoresSafeArea()
}

#Preview("Child View (from Preferences)") {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
        
    let mockNotices = [
        Notice(
            title: "Notice Title 1",
            noticeDate: Date().addingTimeInterval(-3600), // 1 hr back
            noticeMessage: "",
            isRead: true
        ),
        Notice(
            title: "Notice Title 2",
            noticeDate: Date().addingTimeInterval(-7200), // 2 hrs back
            noticeMessage: "",
            isRead: false
        ),
        Notice(
            title: "Notice Title 3",
            noticeDate: Date().addingTimeInterval(-86400), // 1 day back
            noticeMessage: "",
            isRead: true
        ),
        Notice(
            title: "Notice Title 4",
            noticeDate: Date().addingTimeInterval(-172800), // 2 days back
            noticeMessage: "",
            isRead: false
        )
    ]
        
    for notice in mockNotices {
        context.insert(notice)
    }

    try? context.save()

    let noticevm = NoticeViewModel(modelContext: context)
    let coordinator = AppCoordinator()

    return Group {
        NavigationStack {
            NoticesView(isRootModal: false)
                .environmentObject(noticevm)
                .environmentObject(coordinator)
                .modelContainer(container)
        }
    }
    .background(Color.mycolor.myBackground)
    .ignoresSafeArea()
}

#Preview("Empty") {
    
    let coordinator = AppCoordinator()

    return Group {
        NavigationStack {
            let emptyContainer = try! ModelContainer(
                for: Post.self, Notice.self, AppSyncState.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            let emptyContext = ModelContext(emptyContainer)
            let emptyNoticeVM = NoticeViewModel(modelContext: emptyContext)
            
            NoticesView(isRootModal: true)
                .environmentObject(emptyNoticeVM)
                .environmentObject(coordinator)
                .modelContainer(emptyContainer)
        }
    }
    .background(Color.mycolor.myBackground)
    .ignoresSafeArea()
}

