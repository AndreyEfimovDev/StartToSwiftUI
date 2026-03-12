//
//  SharedToolbarLeadingItems.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.03.2026.
//

import SwiftUI

// MARK: - Shared Toolbar Items
// Used by HomeView and SnippetsHomeView
struct SharedToolbarLeadingItems: ToolbarContent {
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var noticevm: NoticesViewModel
    
    private let hapticManager = HapticManager.shared
    
    var body: some ToolbarContent {
        
        // ⚙️ Preferences
        ToolbarItem(placement: .topBarLeading) {
            CircleStrokeButtonView(iconName: "gearshape", isShownCircle: false) {
                hapticManager.impact(style: .light)
                coordinator.push(.preferences)
            }
        }
        
        // 🔔 Notices badge (only when unread)
        if noticevm.unreadCount > 0 {
            ToolbarItem(placement: .navigationBarLeading) {
                noticeButton
            }
        }
        
        // ⇄ Switch section
        ToolbarItem(placement: .topBarTrailing) {
            CircleStrokeButtonView(
                iconName: coordinator.activeSection.switchLabel,
                isShownCircle: false
            ) {
                hapticManager.impact(style: .light)
                coordinator.switchSection()
            }
        }
    }

    
    private var noticeButton: some View {
        CircleStrokeButtonView(iconName: "message", isShownCircle: false) {
            hapticManager.impact(style: .light)
            coordinator.push(.notices)
        }
        .overlay {
            Capsule()
                .fill(Color.mycolor.myRed)
                .frame(maxWidth: 15, maxHeight: 10)
                .overlay {
                    Text("\(noticevm.unreadCount)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.mycolor.myButtonTextPrimary)
                }
                .offset(x: 6, y: -9)
        }
        .background(
            Circle()
                .stroke(Color.mycolor.myRed,
                        lineWidth: noticevm.shouldAnimateNoticeButton ? 3 : 0)
                .scaleEffect(noticevm.shouldAnimateNoticeButton ? 1.2 : 0.8)
                .opacity(noticevm.shouldAnimateNoticeButton ? 0 : 1)
                .animation(
                    noticevm.shouldAnimateNoticeButton ? .easeOut(duration: 1.0) : .none,
                    value: noticevm.shouldAnimateNoticeButton
                )
        )
    }
}
