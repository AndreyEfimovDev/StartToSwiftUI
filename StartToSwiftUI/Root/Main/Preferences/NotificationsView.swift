//
//  NotificationsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 14.11.2025.
//

import SwiftUI

struct NotificationsView: View {
    
    private let noticeService = NotificationCentre()
    

    
    var body: some View {
        
        
        List {
            ForEach(DevData.sampleNotices) { notice in
                
                let noticeDate = notice.noticeDate.formatted(date: .numeric, time: .omitted)
                HStack {
                    Button {
                        noticeService.isReadSet(notice: notice)
                    } label: {
                        Circle()
                            .fill(.white)
                            .frame(width: 15, height: 15)
                            .overlay(
                                Capsule()
                                    .stroke(Color.mycolor.myBlue, lineWidth: 1)
                            )
                            .frame(width: 30, height: 30)
                            .padding(4)
                            .border(.accent)
                    }
                    
                    VStack (alignment: .leading) {
                        Text("\(noticeDate)")
                            .border(.blue)

                        Text(notice.noticeMessage)
                            .border(.green)

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .border(.red)
                }
                
            }
        }
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    NotificationsView()
}
