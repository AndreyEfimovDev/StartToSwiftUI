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


// MARK: - B006 Immersive Hero Header
//
// backgroundExtensionEffect() only has something to bleed into when the hero
// is the very first thing on screen, touching the real top safe area — the
// usual header-card-above-the-demo layout would block that. So unlike every
// other B0XX wrapper, this one puts the hero first and SnippetDemoHeader
// below it, in the same scroll region, instead of stacking two separate
// containers.
@available(iOS 26.0, *)
struct B006_ImmersiveHeroHeaderDemoView: View {
    let snippet: CodeSnippet

    var body: some View {
        ScrollView {
            hero
            SnippetDemoHeader(snippet: snippet)
                .padding()
        }
        .ignoresSafeArea(edges: .top)
        .foregroundStyle(Color.mycolor.myAccent)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.mycolor.myBlue, Color.mycolor.myPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 160))
                .foregroundStyle(.white.opacity(0.25))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            caption
        }
        .frame(height: 420)
        .frame(maxWidth: .infinity)
        .backgroundExtensionEffect()
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Glacier Bay")
                .font(.title.bold())
            Text("Tidewater glaciers calve into the sea here — home to humpback whales, sea otters, and nesting bald eagles.")
                .font(.subheadline)
                .lineLimit(2)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - B005 Zoom Navigation Transition
@available(iOS 26.0, *)
struct B005_ZoomNavigationTransitionDemoView: View {
    let snippet: CodeSnippet

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            B005_ZoomNavigationTransitionDemo()
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - B004 Mini Browser
@available(iOS 26.0, *)
struct B004_MiniBrowserDemoView: View {
    let snippet: CodeSnippet

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            B004_MiniBrowserDemo()
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - B003 Rich Text Notes
@available(iOS 26.0, *)
struct B003_RichTextNotesDemoView: View {
    let snippet: CodeSnippet

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            B003_RichTextNotesDemo()
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - B002 Album Player
@available(iOS 26.1, *)
struct B002_AlbumPlayerDemoView: View {
    let snippet: CodeSnippet

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            B002_AlbumPlayerDemo()
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - B001 Liquid Glass Playground
@available(iOS 26.0, *)
struct B001_LiquidGlassPlaygroundDemoView: View {
    let snippet: CodeSnippet

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SnippetDemoHeader(snippet: snippet)
                        .padding()
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            B001_LiquidGlassPlaygroundDemo()
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}


// MARK: - A016 Indeterminate Progress Bar
struct A016_IndeterminateProgressBarDemoView: View {
    
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
            
            A016_IndeterminateProgressBarDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}


// MARK: - A015 Card Swipe
struct A015_CardSwipeDemoView: View {
    
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
            
            A015_CardSwipeDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A014 Animation Type
struct A014_AnimationTypeDemoView: View {
    
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
            
            A014_AnimationTypeDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A013 Rotating Carousel
struct A013_RotatingCarouselDemoView: View {
    
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
            
            A013_RotatingCarouselDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}

// MARK: - A012 Bottom Tabs Container
struct A012_BottomTabsContainerDemoView: View {
    
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
            
            A012_BottomTabsContainerDemo()
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(Color.mycolor.myAccent)
    }
}


// MARK: - A011 Expandble Text Editor
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

// MARK: - A010 Mask DemoView
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



