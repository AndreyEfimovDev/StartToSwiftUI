//
//  SnippetDetailsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//

import SwiftUI

struct SnippetDetailsView: View {

    // MARK: - Dependencies
    @EnvironmentObject private var snippetvm: SnippetsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let hapticManager = HapticManager.shared

    // MARK: - Constants
    let snippet: CodeSnippet

    // MARK: - State
    @State private var showCodeSheet = false
    @State private var codeCopied = false
    @State private var isFavorite: Bool = false

    // MARK: - Body
    var body: some View {
        SnippetViewRegistry.view(for: snippet)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { toolbar }
            .sheet(isPresented: $showCodeSheet) { codeSheet }
            .onAppear {
                FBAnalyticsManager.shared.logScreen(name: "SnippetDetailsView_\(snippet.id)")
                isFavorite = snippetvm.isFavorite(snippet)
            }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {

        // ← Back (iPhone only — iPad uses split view)
        ToolbarItem(placement: .topBarLeading) {
            if UIDevice.isiPhone {
                BackButtonView { coordinator.pop() }
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {

            // ⭐ Favourite
            CircleStrokeButtonView(
                iconName: isFavorite ? "star.fill" : "star",
                iconFont: .headline,
                imageColorPrimary: isFavorite
                    ? Color.mycolor.myYellow
                    : Color.mycolor.myAccent,
                isShownCircle: false
            ) {
                snippetvm.favoriteToggle(snippet)
                isFavorite.toggle()
                hapticManager.impact(style: .light)
            }

            // </> View code
            CircleStrokeButtonView(
                iconName: "curlybraces",
                isShownCircle: false
            ) {
                showCodeSheet = true
                hapticManager.impact(style: .light)
            }
        }
    }

    // MARK: - Code Sheet
    private var codeSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Code block
                    Text(AttributedString.splashHighlighted(snippet.codeSnippet))
                        .font(.system(.footnote, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.mycolor.mySecondary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)

                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        Text("Source: @\(thanks)")
                            .font(.caption)
                            .foregroundStyle(Color.mycolor.myAccent.opacity(0.5))
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Copy button inside sheet
                ToolbarItem(placement: .topBarTrailing) {
                    CircleStrokeButtonView(
                        iconName: codeCopied ? "checkmark" : "doc.on.doc",
                        imageColorPrimary: codeCopied ? Color.mycolor.myGreen : Color.mycolor.myAccent,
                        isShownCircle: false
                    ) {
                        UIPasteboard.general.string = snippet.codeSnippet
                        hapticManager.notification(type: .success)
                        withAnimation { codeCopied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                codeCopied = false
                                showCodeSheet = false
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        showCodeSheet = false
                    }
                        .foregroundStyle(Color.mycolor.myAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
//        .presentationDetents(UIDevice.isiPad ? [.large] : [.medium, .large])
    }
}

// MARK: - Preview

#Preview("Snippet Details") {
    let vm = SnippetsViewModel()
    NavigationStack {
        SnippetDetailsView(snippet: SnippetsRepository.a001)
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
