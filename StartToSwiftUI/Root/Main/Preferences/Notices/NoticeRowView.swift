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

            Circle()
                .fill(Color.mycolor.myBlue)
                .frame(width: 8, height: 8)
                .padding(.leading, 8)
                .opacity(notice.isRead ? 0 : 1)
            
//            Spacer()
            
            VStack (alignment: .leading) {
                Text("\(notice.noticeDate.formatted(date: .numeric, time: .omitted))")
                    .font(.caption)
//                    .border(.yellow)
                
                Text(notice.title)
                    .font(.body)
                    .lineLimit(1)
//                    .border(.green)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.mycolor.myAccent)
            .fontWeight(notice.isRead ? .regular : .bold)
            .padding(.vertical, 16)
        }
        .background(.ultraThinMaterial)

//        .border(.red)
    }
}

fileprivate struct NoticeRowPreView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
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
