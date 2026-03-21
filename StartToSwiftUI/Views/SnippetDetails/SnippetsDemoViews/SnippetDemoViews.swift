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


struct PreviewWrapper: View {
    @State private var text = ""
    var body: some View {
        A011_ExpandbleTextEditorDemo(text: $text)
            .padding()
    }
}


// MARK: - A009 OnTo Button DemoView
struct A011_ExpandbleTextEditorDemoView: View {
    
    @State private var text = ""
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A011_ExpandbleTextEditorDemo(text: $text)
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}
// MARK: - A009 OnTo Button DemoView
struct A010_MaskDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A010_MaskDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A009 OnTo Button DemoView
struct A009_OnToButtonDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A009_OnToButtonDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A008 Expandable Section DemoView
struct A008_ExpandableSectionDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A008_ExpandableSectionDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A007 Shimmer Wave DemoView
struct A007_ShimmerWaveDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A007_ShimmerWaveDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}
// MARK: - A006 Frame Transition DemoView
struct A006_FrameTransitionDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A006_FrameTransitionDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A005 SF Symbol Effects DemoView
struct A005_SFSymbolEffectsDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A005_SFSymbolEffectsDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A004_Pressable Button DemoView
struct A004_ShrinkingButtonDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            VStack {
                Text("Version for use within ScrollView")
                    .font(.headline)
                A004_ShrinkingButtonForScrollViewDemo()
                
                Text("Version for regular use")
                A004_ShrinkingButtonRegularDemo()
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A003_Progress Circle With Checkmark DemoView
struct A003_ProgressCircleWithCheckmarkDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A003_ProgressCircleWithCheckmarkDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A002_Trim Indicator DemoView
struct A002_TrimIndicatorDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A002_TrimIndicatorDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A001_Progress View Indicators DemoView
struct A001_ProgressViewIndicatorsDemoView: View {
    
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                    
                    if let thanks = snippet.thanks, !thanks.isEmpty {
                        SnippetThanksView(thanks: thanks)
                            .padding(.horizontal)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            
            A001_ProgressViewIndicatorsDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}


// MARK: - Shared helper views
private struct SnippetDemoHeader: View {
    let snippet: CodeSnippet
    
    @State private var showFullIntro: Bool = false
    @State private var isTruncated = false
    
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
            
            ExpandableSection(
                title: nil,
                text: snippet.intro,
                font: .subheadline,
                lineSpacing: 0,
                linesLimit: 3
            )
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
//
//#Preview("A001 Progress Indicators") {
//    NavigationStack {
//        A001_ProgressViewIndicatorsDemoView(snippet: SnippetsRepository.a001)
//            .environmentObject(AppCoordinator())
//    }
//}
//
//#Preview("A002 Trim Indicator") {
//    NavigationStack {
//        A002_TrimIndicatorDemoView(snippet: SnippetsRepository.a002)
//            .environmentObject(AppCoordinator())
//    }
//}
//#Preview("A003 Progress Circle With Checkmark") {
//    NavigationStack {
//        A003_ProgressCircleWithCheckmarkDemoView(snippet: SnippetsRepository.a003)
//            .environmentObject(AppCoordinator())
//    }
//}
//#Preview("A004_Shrinking Button") {
//    NavigationStack {
//        A004_ShrinkingButtonDemoView(snippet: SnippetsRepository.a004)
//            .environmentObject(AppCoordinator())
//    }
//}
//#Preview("A005_Sheet Transition") {
//    NavigationStack {
//        A006_FrameTransitionDemoView(snippet: SnippetsRepository.a006)
//            .environmentObject(AppCoordinator())
//    }
//}
