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
        
        VStack (alignment: .leading) {
            Text("\(notice.noticeDate.formatted(date: .numeric, time: .omitted))")
                .font(.caption)
            
            Text(notice.title)
                .font(.body)
                .lineLimit(1)
                .padding(.vertical, 8)
        }
//        .padding(.horizontal)
        .fontWeight(notice.isRead ? .regular : .bold)
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(.ultraThinMaterial)
//        .clipShape(
//            RoundedRectangle(cornerRadius: 10)
//                
//        )
    }
}

#Preview {
    ZStack {
        Color.blue
            .ignoresSafeArea()
        List {
            NoticeRowView(notice: DevData.sampleNotice1)
        }
    }
}
