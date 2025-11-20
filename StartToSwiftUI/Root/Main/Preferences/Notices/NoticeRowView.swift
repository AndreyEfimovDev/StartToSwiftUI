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
            VStack (alignment: .leading) {
                Text("\(notice.noticeDate.formatted(date: .numeric, time: .omitted))")
                    .font(.caption2)
                
                Text(notice.title)
                    .font(.body)
                    .minimumScaleFactor(0.75)
                    .lineLimit(2, reservesSpace: true)
                    .padding(.vertical)
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .fontWeight(notice.isRead ? .regular : .bold)
            .opacity(notice.isRead ? 0.8 : 1)

//            .padding(.leading, 8)
//            .frame(height: 80)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mycolor.mySectionBackground)
        }
    }
}

fileprivate struct NoticeRowPreView: View {
        
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
    NoticeRowPreView()
    
}
