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
//                            .border(.blue)
            
            Text(notice.title)
                .font(.body)
//                .border(.green)
                .lineLimit(1)
            
            Text(notice.id)
                .font(.caption2)
//                .border(.green)
                .lineLimit(1)
        }
        .fontWeight(notice.isRead ? .regular : .bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
                
        )
        .border(.red)

    }
}

#Preview {
    NoticeRowView(notice: DevData.sampleNotice1)
}
