//
//  B005_ZoomNavigationTransition.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.09.2026.
//

import SwiftUI

struct B005_Destination: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]

    static let all: [B005_Destination] = [
        .init(id: "kyoto", title: "Kyoto", subtitle: "Temples & maple leaves",
              icon: "leaf.fill", colors: [Color.mycolor.myRed, Color.mycolor.myOrange]),
        .init(id: "iceland", title: "Iceland", subtitle: "Glaciers & northern lights",
              icon: "snowflake", colors: [Color.mycolor.myBlue, Color.mycolor.myPurple]),
        .init(id: "sahara", title: "Sahara", subtitle: "Dunes at sunset",
              icon: "sun.max.fill", colors: [Color.mycolor.myYellow, Color.mycolor.myOrange]),
        .init(id: "amazon", title: "Amazon", subtitle: "Rainforest canopy",
              icon: "tree.fill", colors: [Color.mycolor.myGreen, Color.mycolor.myBlue]),
        .init(id: "santorini", title: "Santorini", subtitle: "White cliffs, blue domes",
              icon: "water.waves", colors: [Color.mycolor.myBlue, Color.mycolor.mySecondary]),
        .init(id: "patagonia", title: "Patagonia", subtitle: "Granite peaks & wind",
              icon: "mountain.2.fill", colors: [Color.mycolor.mySecondary, Color.mycolor.myPurple])
    ]
}

@available(iOS 26.0, *)
struct B005_ZoomNavigationTransitionDemo: View {
    // Shared between the grid cards and the pushed detail view — the source
    // and destination must use the same Namespace for the zoom to connect them.
    @Namespace private var zoomNamespace
    @State private var favoriteIDs: Set<String> = []

    var body: some View {
        // On iPad this demo sits directly in a NavigationSplitView's detail
        // column, which has no NavigationStack of its own — navigationDestination
        // there tries to advance to a next column instead of pushing within
        // this one. On iPhone the host already provides a NavigationStack, so
        // adding a second one here would nest stacks instead.
        if UIDevice.isiPad {
            NavigationStack {
                content
            }
        } else {
            content
        }
    }

    private var content: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                ForEach(B005_Destination.all) { destination in
                    NavigationLink(value: destination) {
                        card(for: destination)
                    }
                    .buttonStyle(.plain)
                    // Marks this card as the anchor the zoom grows from and
                    // shrinks back into on dismiss.
                    .matchedTransitionSource(id: destination.id, in: zoomNamespace)
                }
            }
            .padding()
        }
        .navigationDestination(for: B005_Destination.self) { destination in
            detail(for: destination)
                // In iOS 26 a glass toolbar on the destination materializes as
                // part of this same zoom instead of just fading in afterwards.
                .navigationTransition(.zoom(sourceID: destination.id, in: zoomNamespace))
        }
    }

    // MARK: - Grid card

    private func card(for destination: B005_Destination) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: destination.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: destination.icon)
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.35))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(destination.title)
                    .font(.headline)
                Text(destination.subtitle)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .padding(12)
        }
        .frame(height: 150)
    }

    // MARK: - Detail

    private func detail(for destination: B005_Destination) -> some View {
        ZStack {
            LinearGradient(
                colors: destination.colors,
                startPoint: .top,
                endPoint: .bottom
            )

            Image(systemName: destination.icon)
                .font(.system(size: 140))
                .foregroundStyle(.white.opacity(0.25))

            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(destination.title)
                    .font(.largeTitle.bold())
                Text(destination.subtitle)
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let isFavorite = favoriteIDs.contains(destination.id)
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? Color.mycolor.myRed : Color.mycolor.myAccent)
                    .frame(width: 36, height: 36)
                    .glassEffect(.regular.interactive(), in: Circle())
                    .onTapGesture {
                        toggleFavorite(destination.id)
                    }
            }
        }
    }

    private func toggleFavorite(_ id: String) {
        withAnimation(.bouncy(duration: 0.3)) {
            if favoriteIDs.contains(id) {
                favoriteIDs.remove(id)
            } else {
                favoriteIDs.insert(id)
            }
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B005_ZoomNavigationTransitionDemo()
    }
}
