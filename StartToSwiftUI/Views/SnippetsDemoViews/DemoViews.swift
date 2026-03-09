//
//  DemoViews.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.03.2026.
//
//  Place in Views/SnippetsDemoViews/
//
//  Thin wrappers that embed original demo components into
//  the SnippetDetailsView context (header, live demo, source credit).
//  Original files A001_... and A002_... are not modified.

import SwiftUI

// MARK: - Shared helper views

//private struct SnippetDemoHeader: View {
//    let snippet: CodeSnippet
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(snippet.title)
//                .font(.title2)
//                .fontWeight(.semibold)
//                .frame(maxWidth: .infinity, alignment: .leading)
////            Text(snippet.date.formatted(date: .numeric, time: .omitted))
////                .font(.caption)
//            Text(snippet.intro)
//                .font(.subheadline)
//                .foregroundStyle(Color.mycolor.myAccent.opacity(0.75))
//        }
//        .cardBackground()
//    }
//}

private struct SnippetDemoHeader: View {
    let snippet: CodeSnippet

    @State private var showFullIntro: Bool = false
    @State private var lineCountIntro: Int = 0

    private let introFont: Font = .subheadline
    private let introLineSpacing: CGFloat = 0
    private let introLinesLimit: Int = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(snippet.title)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                Text(snippet.intro)
                    .font(introFont)
                    .lineLimit(showFullIntro ? nil : introLinesLimit)
                    .lineSpacing(introLineSpacing)
                    .frame(minHeight: 55, alignment: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        // Невидимый текст без ограничений — только для подсчёта строк
                        Text(snippet.intro)
                            .font(introFont)
                            .lineSpacing(introLineSpacing)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .hidden()
                            .onLineCountChanged(font: introFont, lineSpacing: introLineSpacing) { count in
                                lineCountIntro = count - 1
                            }
                    )
                if lineCountIntro > introLinesLimit {
                    HStack(alignment: .top) {
                        Spacer()
                        MoreLessTextButton(showText: $showFullIntro)
                    }
                }
            }
        }
        .cardBackground()
    }
}

private struct SnippetThanksView: View {
    let thanks: String

    var body: some View {
        Text("Source: @\(thanks)")
            .font(.caption)
            .foregroundStyle(Color.mycolor.myAccent.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 4)
    }
}

// MARK: - A001_ProgressViewIndicatorsDemoView

struct A001_ProgressViewIndicatorsDemoView: View {

//    @State private var isHeaderExpanded = true
    let snippet: CodeSnippet

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                SnippetDemoHeader(snippet: snippet)
//                    .onTapGesture {
//                        withAnimation(.spring) { isHeaderExpanded.toggle() }
//                    }
//                    .frame(height: isHeaderExpanded ? nil : 44)
//                    .clipped()
                

                // Live demo — original component, untouched
                A001_ProgressViewIndicators()
                    .cardBackground()

                if let thanks = snippet.thanks, !thanks.isEmpty {
                    SnippetThanksView(thanks: thanks)
                }
            }
            .padding()
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}

// MARK: - A002_TrimIndicatorDemoView

struct A002_TrimIndicatorDemoView: View {

    let snippet: CodeSnippet

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                SnippetDemoHeader(snippet: snippet)

                // Live demo — original component, untouched
                A002_TrimIndicator()
                    .cardBackground()

                if let thanks = snippet.thanks, !thanks.isEmpty {
                    SnippetThanksView(thanks: thanks)
                }
            }
            .padding()
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}

// MARK: - Previews

#Preview("A001 Progress Indicators") {
    NavigationStack {
        A001_ProgressViewIndicatorsDemoView(snippet: SnippetsRepository.a001)
            .environmentObject(AppCoordinator())
    }
}

#Preview("A002 Trim Indicator") {
    NavigationStack {
        A002_TrimIndicatorDemoView(snippet: SnippetsRepository.a002)
            .environmentObject(AppCoordinator())
    }
}
