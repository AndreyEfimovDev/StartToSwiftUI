//
//  NoticeRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 16.11.2025.
//

import SwiftUI

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
//            .padding()
//            .background(.ultraThinMaterial)
        
    }
}

fileprivate struct NoticeRowPreView: View {
        
    @EnvironmentObject private var noticevm: NoticeViewModel

    var body: some View {
            ZStack {
                Color.pink.opacity(0.1)
                    .ignoresSafeArea()
                
                List {
                    NoticeRowView(notice: DevData.sampleNotice1)
                    NoticeRowView(notice: DevData.sampleNotice2)
                    NoticeRowView(notice: DevData.sampleNotice3)
                }
                .padding()
            }
    }
}


#Preview {
    NavigationStack {
        NoticeRowPreView()
            .environmentObject(NoticeViewModel())
    }
}
