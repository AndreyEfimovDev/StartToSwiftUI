//
//  MyBackground.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 30.08.2025.
//

import Foundation
import SwiftUI

// MARK: - Helper Extension для Pull to Refresh

extension View {
    func refreshControl(action: @escaping () -> Void) -> some View {
        self.refreshable {
            action()
        }
    }
}

// MARK: - Adaptive Modifier for Modal views

extension View {
    func adaptiveModal(item: Binding<AppRoute?>) -> some View {
        modifier(AdaptiveModalModifier(route: item))
    }
}

// MARK: Adaptaion for iPad

extension View {
    func sheetForUIDeviceBoolean<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.sheet(isPresented: isPresented) {
                    // iPad sheet
                    content()
                }
            } else {
                self.fullScreenCover(isPresented: isPresented) {
                    // iPhone full screen
                    content()
                }
            }
        }
    }
}

extension View {
    func sheetForUIDeviceItem<T: Identifiable, Content: View>(
        item: Binding<T?>,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.sheet(item: item) { item in
                    // iPad sheet
                    content(item)
                }
            } else {
                self.fullScreenCover(item: item) { item in
                    // iPhone full screen
                    content(item)
                }
            }
        }
    }
}

extension View {
    func applyTabViewStyle() -> some View {
        Group {
            if UIDevice.isiPad {
                self.tabViewStyle(.automatic)
            } else {
                self
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }
}

extension View {
    func postNotSelectedEmptyView(text: String) -> some View {
        ZStack {
            VStack {
                Image("A_1024x1024_PhosphateInline_tr")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .opacity(0.15)
                Text(text)
                    .font(.largeTitle)
                    .bold()
                    .padding()
            }
            .foregroundStyle(Color.mycolor.myAccent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


// MARK: CUSTOM BACKGROUND

extension View {
    func mySsectionBackground() -> some View {
        self
            .background(Color.mycolor.mySectionBackground)
            .cornerRadius(8)
    }
}

extension View {
    func menuFormater(
        cornerRadius: CGFloat = 30,
        borderColor: Color = Color.mycolor.myBlue,
        lineWidth: CGFloat = 1
    ) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor.opacity(0.3), lineWidth: lineWidth)
            )

    }
}

extension View {
    func textFormater(
        cornerRadius: CGFloat = 30,
        borderColor: Color = Color.mycolor.myAccent,
        lineWidth: CGFloat = 1
    ) -> some View {
        self
            .font(.callout)
            .foregroundStyle(borderColor)
            .multilineTextAlignment(.center)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor.opacity(0.3), lineWidth: lineWidth)
            )
    }
}

extension View {
    func sectionSubheaderFormater(fontSubheader: Font, colorSubheader: Color) -> some View {
        self
            .font(fontSubheader)
            .bold()
            .foregroundStyle(colorSubheader)
            .padding(5)
    }
}

// MARK: - View Modifier for styling Preferences List Rows

extension View {
    
    func customListRowStyle(iconName: String, iconWidth: CGFloat) -> some View {
        HStack {
            Image(systemName: iconName)
                .frame(width: iconWidth)
                .foregroundStyle(Color.mycolor.myBlue)
            self
        }
    }
}

// MARK: - View Modifier for processing Single and Double tap on PostRow

extension View {
    func onTapAndDoubleTap(
        singleTap: @escaping () -> Void,
        doubleTap: @escaping () -> Void
    ) -> some View {
        modifier(TapAndDoubleTapModifier(
            singleTap: singleTap,
            doubleTap: doubleTap
        ))
    }
}

// MARK: - For PostDetails

extension View {
    func cardBackground() -> some View {
        self.background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 15)
        )
    }
}
extension View {
    func itemBackground() -> some View {
        self
            .padding(.vertical, 2)
            .padding(.horizontal,8)
            .background(.ultraThinMaterial)
            .clipShape(.capsule)
            .overlay(
                Capsule()
                    .stroke(Color.mycolor.mySecondary, lineWidth: 1)
                    .opacity(0.15)
            )

    }
}

