//
//  A012_BottomTabsContainer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.03.2026.
//

import SwiftUI

struct A012_BottomTabsContainerDemo: View {
    
    // MARK: - States
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
            Text("View")
                .font(.largeTitle)
                .foregroundColor(Color.mycolor.myBlue)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                tabView(name: "Tab 1") { showProgressTab = false }
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
                tabView(name: "Tab 2") { showRatingTab = false }
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
        color: Color, // for use in a certain tab if needed
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
            // asymmetric transition — instant removal, delayed insertion
            if isExpanded {
                content()
                    .padding(1) // make a space for stroke when expanded
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.smooth(duration: 0.2).delay(0.15)),
                        removal:   .opacity.animation(.smooth(duration: 0.05))
                    ))
            } else {
                tabButton(icon: icon, onTap: onTap)
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.smooth(duration: 0.15).delay(0.2)),
                        removal:   .opacity.animation(.smooth(duration: 0.05))
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
                Image(systemName: icon)
                    .padding(8)
            }
            .font(.headline)
            .foregroundColor(Color.mycolor.myBlue)
            .padding(.top, 4)
            .padding(.horizontal, 30)
            .background(.black.opacity(0.001))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    private func tabView(
        name: String,
        completion: @escaping () -> ()
    ) -> some View {
        VStack {
            Text(name)
                .font(.headline)
            Button("Close") { completion() }
                .foregroundStyle(Color.mycolor.myBlue)
                .padding()
                .background(.black.opacity(0.001))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func updateWidths(for width: CGFloat) {
        tabWidth = width * widthRatio
        expandedWidth = width
    }
}

#Preview {
    A012_BottomTabsContainerDemo()
}
