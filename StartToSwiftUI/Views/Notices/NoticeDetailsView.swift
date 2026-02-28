//
//  NoticesDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 16.11.2025.
//

import SwiftUI
import SwiftData

struct NoticeDetailsView: View {
    
    @EnvironmentObject private var noticevm: NoticeViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    let noticeId: String
    
    private let sectionCornerRadius: CGFloat = 15
    
    private var notice: Notice? {
        noticevm.notices.first(where: { $0.id == noticeId })
    }

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
                                in: RoundedRectangle(cornerRadius: sectionCornerRadius)
                            )
                        Text(validNotice.noticeMessage)
                            .font(.body)
                            .padding()
//                            .frame(minHeight: 300, alignment: .topLeading)
                            .frame(maxWidth: .infinity,  alignment: .leading)
                            .background(
                                .thinMaterial,
                                in: RoundedRectangle(cornerRadius: sectionCornerRadius)
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
            noticevm.markAsRead(noticeId)
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
                    noticevm.deleteErase(notice)
                    coordinator.popModal()
                }
            }
        }
    }
    
}

#Preview {
    let noticeVM = NoticeViewModel(dataSource: MockNoticesDataSource())
    
    noticeVM.notices = PreviewData.sampleNotices
    
    let sampleNotice = PreviewData.sampleNotices[1]
    
    return NavigationStack {
        NoticeDetailsView(noticeId: sampleNotice.id)
    }
    .environmentObject(noticeVM)
    .environmentObject(AppCoordinator())
}
