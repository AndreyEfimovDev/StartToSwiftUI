//
//  NoticeRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 16.11.2025.
//

import SwiftUI
import SwiftData

struct NoticeRowView: View {
    
    @EnvironmentObject private var noticevm: NoticeViewModel
    
    let notice: Notice
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("\(notice.noticeDate.formatted(date: .numeric, time: .omitted))")
                .font(.caption2)
                .padding(.top, 4)
            
            Text(notice.title)
                .font(.body)
                .minimumScaleFactor(0.75)
                .lineLimit(2, reservesSpace: true)
                .padding(.vertical)
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .fontWeight(notice.isRead ? .regular : .bold)
        .opacity(notice.isRead ? 0.8 : 1)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

fileprivate struct NoticeRowPreView: View {
        
    @EnvironmentObject private var noticevm: NoticeViewModel

    var body: some View {
            ZStack {
                Color.pink.opacity(0.1)
                    .ignoresSafeArea()
                
                List {
                    NoticeRowView(notice: PreviewData.sampleNotice1)
                    NoticeRowView(notice: PreviewData.sampleNotice2)
                    NoticeRowView(notice: PreviewData.sampleNotice3)
                }
                .padding()
            }
    }
}


#Preview {
    let container = try! ModelContainer(
        for: Post.self, Notice.self, AppState.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    
    let noticevm = NoticeViewModel(modelContext: context)
    
    NavigationStack {
        NoticeRowPreView()
            .environmentObject(noticevm)
    }
}
