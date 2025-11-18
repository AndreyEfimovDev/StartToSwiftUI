//
//  NoticeRowView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 16.11.2025.
//

import SwiftUI

struct NoticeRowView: View {
    
    let notice: Notice
    
    var body: some View {
        HStack {
//            Circle()
//                .fill(Color.mycolor.myBlue)
//                .frame(width: 8, height: 8)
//                .padding(.leading, 8)
//                .opacity(notice.isRead ? 0 : 1)
//                        
            VStack (alignment: .leading) {
                Text("\(notice.noticeDate.formatted(date: .numeric, time: .omitted))")
                    .font(.caption)
                
                Text(notice.title)
                    .font(.body)
                    .lineLimit(1)

            }
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.mycolor.myAccent)
            .fontWeight(notice.isRead ? .regular : .bold)
            .opacity(notice.isRead ? 0.5 : 1)
            .padding(.vertical, 16)
        }
        .background(.ultraThinMaterial)
    }
}

fileprivate struct NoticeRowPreView: View {
        
    var body: some View {
        List {
            ZStack {
                Color.pink.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack {
                    NoticeRowView(notice: DevData.sampleNotice1)
                    NoticeRowView(notice: DevData.sampleNotice2)
                    NoticeRowView(notice: DevData.sampleNotice3)
                }
                .padding()
            }
        }
        .listStyle(.plain)

    }
}


#Preview {
    NoticeRowPreView()
    
}
