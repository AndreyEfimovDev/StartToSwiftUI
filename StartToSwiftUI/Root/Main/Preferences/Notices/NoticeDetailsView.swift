//
//  NoticesDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 16.11.2025.
//

import SwiftUI

struct NoticeDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var noticevm: NoticeViewModel
    
    let noticeId: String
    
    private var notice: Notice? {
        noticevm.notices.first(where: { $0.id == noticeId })
        //        DevData.sampleNotice2
    }
    
    private let sectionCornerRadius: CGFloat = 15
    
    var body: some View {
        NavigationView{
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
                            .frame(maxWidth: .infinity,  alignment: .leading)
                            .background(
                                .thinMaterial,
                                in: RoundedRectangle(cornerRadius: 15)
                            )
                    } //VStack
                } // ScrollView
                .padding(.horizontal)
                .navigationBarBackButtonHidden(true)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbar {
                    toolbarForNoticeDetails()
                }
                .onDisappear {
                    if !validNotice.isRead {
                        noticevm.isReadSetTrue(notice: validNotice)
                    }
                }
            } else {
                Text("Notice is not found")
            }
        }
        
    }
    
    
    @ToolbarContentBuilder
    private func toolbarForNoticeDetails() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CircleStrokeButtonView(
                iconName: "chevron.left",
                isShownCircle: false)
            {
                dismiss()
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
                CircleStrokeButtonView(iconName: "trash", isShownCircle: false) {
                    withAnimation {
                        noticevm.deleteNotice(notice: notice)
//                        hapticManager.notification(type: .success)
                        dismiss()

                    }
//                                        dismiss()
                }
            }

    }
    
}

#Preview {
    NavigationStack{
        NoticeDetailsView(noticeId: "001")
    }
    .environmentObject(NoticeViewModel())
}
