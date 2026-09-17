//
//  SnippetViewRegistry.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//
//  Place in Views/Snippets/
//
//  HOW TO ADD A NEW SNIPPET DEMO:
//  1. Create a new DemoView in Views/Snippets/Demos/
//  2. Add a case for the snippet's id below
//  3. Upload the snippet to Firestore with the matching id

import SwiftUI

struct SnippetViewRegistry {
    
    // AXXX - iOS 18 snippets
    // BXXX - iOS 26 snippets
    
    @ViewBuilder
    static func view(for snippet: CodeSnippet) -> some View {
        switch snippet.id {
        case "A001": A001_ProgressViewIndicatorsDemoView(snippet: snippet)
        case "A002": A002_TrimIndicatorDemoView(snippet: snippet)
        case "A003": A003_ProgressCircleWithCheckmarkDemoView(snippet: snippet)
        case "A004": A004_ShrinkingButtonDemoView(snippet: snippet)
        case "A005": A005_SFSymbolEffectsDemoView(snippet: snippet)
        case "A006": A006_FrameTransitionDemoView(snippet: snippet)
            
        case "A007": A007_ShimmerWaveDemoView(snippet: snippet)
        case "A008": A008_ExpandableSectionDemoView(snippet: snippet)
        case "A009": A009_OnToButtonDemoView(snippet: snippet)
        case "A010": A010_MaskDemoView(snippet: snippet)
        case "A011": A011_ExpandbleTextEditorDemoView(snippet: snippet)
            
        case "A012": A012_BottomTabsContainerDemoView(snippet: snippet)
        case "A013": A013_RotatingCarouselDemoView(snippet: snippet)
        case "A014": A014_AnimationTypeDemoView(snippet: snippet)
        case "A015": A015_CardSwipeDemoView(snippet: snippet)
        case "A016": A016_IndeterminateProgressBarDemoView(snippet: snippet)
            
        case "B001":
            if #available(iOS 26.1, *) {
                B001_AlbumPlayerDemoView(snippet: snippet)
            } else {
                SnippetUnavailableView(snippet: snippet)
            }
            
            
        default: SnippetNoPreviewView(snippet: snippet)
        }
    }
}

