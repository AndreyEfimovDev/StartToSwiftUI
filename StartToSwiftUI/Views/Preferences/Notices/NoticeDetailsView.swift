//
//  NoticesDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 16.11.2025.
//

import SwiftUI
import SwiftData

struct NoticeDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    let noticeId: String
    
    init(noticeId: String) {
        self.noticeId = noticeId
    }
    
    private var notice: Notice? {
        noticevm.notices.first(where: { $0.id == noticeId })
    }
    
    private let sectionCornerRadius: CGFloat = 15
    
    var body: some View {
        ZStack {
            if let validNotice = notice {
                ScrollView(showsIndicators: false) {
                    VStack (alignment: .leading){
                        Text(validNotice.noticeDate.formatted(date: .numeric, time: .omitted))
                            .font(.caption)
                            .padding()
                        
                        Text(validNotice.title)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity,  alignment: .leading)
                            .background(
                                .thinMaterial,
                                in: RoundedRectangle(cornerRadius: 15)
                            )
                        Text(validNotice.noticeMessage)
                            .font(.body)
                            .padding()
                            .frame(minHeight: 300, alignment: .topLeading)
                            .frame(maxWidth: .infinity,  alignment: .leading)
                            .background(
                                .thinMaterial,
                                in: RoundedRectangle(cornerRadius: 15)
                            )
                    } //VStack
                    .foregroundStyle(Color.mycolor.myAccent)
                    .padding(.horizontal)
                } // ScrollView
            } else {
                Text("Notice is not found")
            }
        } // ZStack root
        .onAppear {
            noticevm.markAsRead(noticeId: noticeId)
        }
        .navigationTitle("Notice message")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarForNoticeDetails()
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarForNoticeDetails() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            BackButtonView() {
                coordinator.popModal()
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            CircleStrokeButtonView(
                iconName: "trash",
                imageColorPrimary: Color.mycolor.myAccent,
                isShownCircle: false
            ) {
                withAnimation {
                    noticevm.deleteNotice(notice: notice)
                    coordinator.popModal()
                }
            }
        }
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppSyncState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let noticevm = NoticeViewModel(modelContext: context)
    
    NavigationStack{
        NoticeDetailsView(noticeId: "001")
    }
    .environmentObject(noticevm)
    .environmentObject(Coordinator())
}
