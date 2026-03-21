//
//  A012_BottomTabsContainer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.03.2026.
//

import SwiftUI
/*
 Layout:

 .safeAreaInset вместо ZStack — правильный hit-testing
 .ignoresSafeArea(.container, edges: .bottom) на контенте — не двигается при открытии таба
 UIScreen.main.bounds.width * 0.55 — кнопки тапабельны сразу, не ждут onAppear

 Анимация:

 Одна .animation(.smooth(duration: 0.25), value: isExpanded) на selectionTabView управляет frame
 .transition(.asymmetric(...)) с анимацией прямо внутри — переопределяет родительский тайминг для opacity отдельно для insertion и removal
 removal: .opacity.animation(.smooth(duration: 0.05)) — мгновенное исчезновение контента при закрытии

 Ключевой инсайт: .asymmetric с анимацией внутри transition имеет приоритет над родительским .animation — это позволяет задать разный тайминг для разных направлений независимо от контекста.
 */
struct A012_BottomTabsContainer: View {
    
    // MARK: - State
    @State private var showRatingTab: Bool = false
    @State private var showProgressTab: Bool = false
    @State private var zIndexBarRating: Double = 0
    @State private var zIndexBarProgress: Double = 0
    
    @State private var maxHeight: CGFloat = 350
    @State private var tabWidth: CGFloat = UIScreen.main.bounds.width * 0.55
    @State private var expandedWidth: CGFloat = UIScreen.main.bounds.width
    
    // MARK: - Constants
    private let widthRatio: CGFloat = 0.55
    
    // MARK: - Computed Properties
    private var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var minHeight: CGFloat {
        isiPad ? 60 : 75
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            Text("Main View")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                // ✅ контент игнорирует сжатие от safeAreaInset — не двигается при открытии таба
                .ignoresSafeArea(.container, edges: .bottom)
                .safeAreaInset(edge: .bottom) {
                    bottomTabsContainer
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    updateWidths(for: proxy.size.width)
                }
                .onChange(of: proxy.size.width) { _, newValue in
                    updateWidths(for: newValue)
                }
        }
    }
    
    // MARK: - Bottom Tabs
    private var bottomTabsContainer: some View {
        ZStack {
            selectionTabView(
                icon: "1.circle",
                color: Color.mycolor.myGreen,
                alignment: .leading,
                isExpanded: showProgressTab,
                otherIsExpanded: showRatingTab,
                zIndexTab: zIndexBarProgress
            ) {
                VStack {
                    Text("Tab 1")
                        .font(.headline)
                    Button("Close") { showProgressTab = false }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } onTap: {
                maxHeight = 300
                zIndexBarProgress = 1
                zIndexBarRating = 0
                showProgressTab.toggle()
            }
            
            selectionTabView(
                icon: "2.circle",
                color: Color.mycolor.myYellow,
                alignment: .trailing,
                isExpanded: showRatingTab,
                otherIsExpanded: showProgressTab,
                zIndexTab: zIndexBarRating
            ) {
                VStack {
                    Text("Tab 2")
                        .font(.headline)
                    Button("Close") { showRatingTab = false }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } onTap: {
                maxHeight = 300
                zIndexBarRating = 1
                zIndexBarProgress = 0
                showRatingTab.toggle()
            }
        }
    }
    
    @ViewBuilder
    private func selectionTabView<Content: View>(
        icon: String,
        color: Color,
        alignment: Alignment,
        isExpanded: Bool,
        otherIsExpanded: Bool,
        zIndexTab: Double,
        @ViewBuilder content: () -> Content,
        onTap: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .top) {
            if isiPad {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.bar)
                    .strokeBorder(
                        Color.mycolor.mySecondary.opacity(0.5),
                        lineWidth: 1,
                        antialiased: true
                    )
            } else {
                UnevenRoundedRectangle(
                    topLeadingRadius: 30,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 30,
                    style: .continuous
                )
                .fill(.bar)
                .strokeBorder(
                    Color.mycolor.mySecondary.opacity(0.5),
                    lineWidth: 1,
                    antialiased: true
                )
            }
            if isExpanded {
                content()
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.smooth(duration: 0.2).delay(0.15)),
                        removal:   .opacity.animation(.smooth(duration: 0.05)) // ✅ исчезает мгновенно
                    ))
            } else {
                tabButton(icon: icon, onTap: onTap)
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.smooth(duration: 0.15).delay(0.2)),
                        removal:   .opacity.animation(.smooth(duration: 0.05)) // ✅ исчезает мгновенно
                    ))
            }

        }
        .frame(height: isExpanded ? maxHeight : minHeight)
        .frame(minWidth: 80, maxWidth: isExpanded ? expandedWidth : tabWidth)
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding(isiPad ? 8 : 0)
        .zIndex(zIndexTab)
        .offset(y: otherIsExpanded && !isExpanded ? maxHeight : 0)
        .animation(.smooth(duration: 0.25), value: isExpanded)
    }
    
    private func tabButton(icon: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "control")
                    .font(.headline)
                Image(systemName: icon)
                    .imageScale(.small)
                    .padding(8)
            }
            .foregroundColor(Color.mycolor.mySecondary)
            .padding(.top, 4)
            .padding(.horizontal, 30)
            .background(.black.opacity(0.001))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    private func updateWidths(for width: CGFloat) {
        tabWidth = width * widthRatio
        expandedWidth = width
    }
}

#Preview {
    A012_BottomTabsContainer()
}
