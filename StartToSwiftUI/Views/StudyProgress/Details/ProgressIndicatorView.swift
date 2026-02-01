//
//  ProgressIndicatorView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 04.12.2025.
//

import SwiftUI

struct ProgressIndicator: View {
    
    @State private var trim: Double = 0
    @State private var isAppear: Bool = false
    
    var progress: Double = 0
    var colour: Color = Color.mycolor.myBlue
    var fontForTitle: Font = .headline
    var lineWidth: Double = 8.0
    var opacity: Double = 0.3
    
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .foregroundStyle(Color.mycolor.mySecondary)
                    .opacity(opacity)
                Circle()
                    .trim(from: 0, to: trim)
                    .stroke(style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round))
                    .foregroundStyle(colour)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.8), value: trim)
            }
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(String(format: "%.1f", trim * 100))
                    .font(fontForTitle)
                Text("%")
                    .font(.caption2)
            }
            .bold()
            .foregroundStyle(Color.mycolor.myAccent)
            .opacity(isAppear ? 1 : 0)
        }
        .onAppear {
            isAppear.toggle()
            trim = progress
        }
    }
}


fileprivate
struct ProgressViewCircleTrimPreview: View {
    
    @State var proportion: Double = 0.9
    @State var titles: [String] = ["Untapped", "Learning", "Studied", "Practiced"]
    @State var posts: [PostForTest] = [
        .init(title: "Title 1", progress: .fresh),
        .init(title: "Title 2", progress: .fresh),
        .init(title: "Title 3", progress: .practiced),
        .init(title: "Title 4", progress: .fresh),
        .init(title: "Title 5", progress: .practiced),
        .init(title: "Title 6", progress: .studied),
        .init(title: "Title 7", progress: .studied),
        .init(title: "Title 8", progress: .practiced),
        .init(title: "Title 9", progress: .fresh),
    ]
    
    var body: some View {
        
        VStack (spacing: 0) {
            
            Text("Progress")
                .font(.largeTitle)

            Text("Study level")
                .font(.body)
                .foregroundStyle(.green)

            ForEach(StudyProgress.allCases, id: \.self) { level in
                
                HStack {
                    
                    let count = levelPostsCount(for: level)
                    
                    VStack(spacing: 8) {
                        level.icon
                        Text(level.displayName)
                        Text("(\(count))")
                            .frame(maxWidth: .infinity)
                    }
                    .font(.title2)
                    .foregroundStyle(level.color)

                    Spacer()
                    
                    ProgressIndicator(progress: progressCount(for: level), colour: level.color)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.vertical)
                .padding(.trailing, 30)
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 30)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.blue, lineWidth: 1)
                )
                .padding(8)
            }
        }
        .foregroundStyle(Color.mycolor.myAccent)
        .bold()
    }
    
    private func progressCount(for progressLevel: StudyProgress) -> Double {
        
        guard !posts.isEmpty else { return 0 }
        
        let filteredPosts = posts.filter { $0.progress == progressLevel }
        return Double(filteredPosts.count) / Double(posts.count)
    }
    
    private func levelPostsCount(for progressLevel: StudyProgress) -> Int {
        posts.filter { $0.progress == progressLevel }.count
    }

}


struct PostForTest: Identifiable {
    let id = UUID().uuidString
    let title: String
    let progress: StudyProgress

    init(
        title: String,
        progress: StudyProgress
    ) {
        self.title = title
        self.progress = progress
    }
}


#Preview {
    ProgressViewCircleTrimPreview()
}
