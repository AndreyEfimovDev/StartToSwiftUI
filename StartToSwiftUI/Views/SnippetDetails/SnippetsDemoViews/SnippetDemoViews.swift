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


// MARK: - A003_ProgressCircleWithCheckmark DemoView
struct A005_SFSymbolEffectsDemoView: View {

    let snippet: CodeSnippet

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                SnippetDemoHeader(snippet: snippet)

                // Live demo — original component
                A005_SFSymbolEffectsDemo()
                
                if let thanks = snippet.thanks, !thanks.isEmpty {
                    SnippetThanksView(thanks: thanks)
                }
            }
            .padding()
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}

// MARK: - A004_PressableButton DemoView
struct A004_PressableButtonDemoView: View {

    let snippet: CodeSnippet

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                    
                    // Live demo — original component
                    Text("Version for use within ScrollView")
                        .font(.headline)
                        .cardBackground()
                    A004_ShrinkingButtonForScrollViewDemo()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                    }
                }
                .padding()
            }
            .frame(maxHeight: 350)
            
            Group {
                Text("Version for regular use")
                    .font(.headline)
                    .cardBackground()
                    .frame(maxHeight: 55)
                    .padding()
                
                A004_ShrinkingButtonRegularDemo()
            }
            .foregroundStyle(Color.mycolor.myAccent)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - A003_ProgressCircleWithCheckmark DemoView
struct A003_ProgressCircleWithCheckmarkDemoView: View {

    let snippet: CodeSnippet

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                SnippetDemoHeader(snippet: snippet)

                // Live demo — original component
                A003_ProgressCircleWithCheckmarkDemo()

                if let thanks = snippet.thanks, !thanks.isEmpty {
                    SnippetThanksView(thanks: thanks)
                }
            }
            .padding()
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}

// MARK: - A002_TrimIndicator DemoView
struct A002_TrimIndicatorDemoView: View {

    let snippet: CodeSnippet

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                SnippetDemoHeader(snippet: snippet)

                // Live demo — original component
                A002_TrimIndicatorDemo()

                if let thanks = snippet.thanks, !thanks.isEmpty {
                    SnippetThanksView(thanks: thanks)
                }
            }
            .padding()
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}

// MARK: - A001_ProgressViewIndicators DemoView
struct A001_ProgressViewIndicatorsDemoView: View {

    let snippet: CodeSnippet

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                SnippetDemoHeader(snippet: snippet)

                // Live demo — original component
                A001_ProgressViewIndicatorsDemo()

                if let thanks = snippet.thanks, !thanks.isEmpty {
                    SnippetThanksView(thanks: thanks)
                }
            }
            .padding()
            .foregroundStyle(Color.mycolor.myAccent)
        }
    }
}


// MARK: - Shared helper views
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
                .minimumScaleFactor(0.75)
                .lineLimit(showFullIntro ? nil : 1)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                Text(snippet.intro)
                    .font(introFont)
                    .lineLimit(showFullIntro ? nil : introLinesLimit)
                    .lineSpacing(introLineSpacing)
                    .frame(minHeight: 55, alignment: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        // Invisible text without restrictions - only for line counting
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
#Preview("A003 Progress Circle With Checkmark") {
    NavigationStack {
        A003_ProgressCircleWithCheckmarkDemoView(snippet: SnippetsRepository.a003)
            .environmentObject(AppCoordinator())
    }
}
#Preview("A004_Pressable Button") {
    NavigationStack {
        A004_PressableButtonDemoView(snippet: SnippetsRepository.a004)
            .environmentObject(AppCoordinator())
    }
}
