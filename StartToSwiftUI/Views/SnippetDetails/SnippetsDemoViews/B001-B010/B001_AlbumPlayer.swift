//
//  B001_GlassEffect.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 22.03.2026.
//

import SwiftUI
import Combine

@available(iOS 26.1, *)
struct B001_AlbumPlayerDemo: View {
    // State for controlling the visibility of the mini-player
    @State private var isPlaying = false
    @State private var isPlayerVisible = false   // player visibility flag
    @State private var currentTrack = Track(singer: "Billie Eilish", title: "Bad Guy")
    
    var body: some View {
        // 1. Main TabView
        TabView {
            // Home tab
            Tab("Home", systemImage: "house") {
                PlayerHomeView(
                    isPlaying: $isPlaying,
                    isPlayerVisible: $isPlayerVisible,
                    currentTrack: $currentTrack)
            }
            
            // Library tab
            Tab("Library", systemImage: "books.vertical") {
                PlayerLibraryView()
            }
            
            // Search tab
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                PlayerSearchView()
            }
            
        }
        // 2. Add a mini-player as an accessory
        .tabViewBottomAccessory(isEnabled: isPlayerVisible) {
            MiniPlayerView(
                track: currentTrack,
                initialPlayingState: isPlaying,
                onPlayPause: { playing in
                    isPlaying = playing
                }
            )
        }
        // 3. Configure the tab bar to collapse when scrolling
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

// MARK: - Track Data Model
struct Track: Identifiable, Equatable {
    let id: String
    let singer: String
    let title: String
    
    init(id: String = UUID().uuidString, singer: String, title: String) {
        self.id = id
        self.singer = singer
        self.title = title
    }
}

// MARK: - Track Mock Data
extension Track {
    static let tracks: [Track] = [
        Track(singer: "Billie Eilish", title: "Bad Guy"),
        Track(singer: "The Weeknd", title: "Blinding Lights"),
        Track(singer: "Olivia Rodrigo", title: "Drivers license"),
        Track(singer: "Daft Punk", title: "Get Lucky"),
        Track(singer: "Queen", title: "Bohemian Rhapsody"),
        Track(singer: "Adele", title: "Rolling in the Deep"),
        Track(singer: "Ed Sheeran", title: "Shape of You"),
        Track(singer: "Nirvana", title: "Smells Like Teen Spirit"),
        Track(singer: "Taylor Swift", title: "Anti‑Hero"),
        Track(singer: "Michael Jackson", title: "Billie Jean"),
        Track(singer: "Doja Cat", title: "Say So"),
        Track(singer: "ABBA", title: "Dancing Queen"),
        Track(singer: "Harry Styles", title: "As It Was"),
        Track(singer: "Coldplay", title: "Viva la Vida"),
        Track(singer: "Pharrell Williams", title: "Happy")
    ]
}

// MARK: - Home tab with player controls
struct PlayerHomeView: View {
    @Binding var isPlaying: Bool
    @Binding var isPlayerVisible: Bool
    @Binding var currentTrack: Track
    
    var body: some View {
        NavigationStack {
            List(Track.tracks) { track in
                Button {
                    currentTrack = track
                    isPlaying = true
                    isPlayerVisible = true // show mini-player
                } label: {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(track.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(track.singer)
                                .font(.caption2)
                                .italic()
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        B001_WaveAsymmetrical()
                            .clipShape(.capsule)
                            .opacity(currentTrack.title == track.title && isPlaying ? 0.8 : 0)
                    }
                }
            }
            .navigationTitle("Player")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isPlayerVisible {
                        Button(isPlaying ? "Stop" : "Play") {
                            isPlaying.toggle()
                            if !isPlaying {
                                isPlayerVisible.toggle()// hide the mini-player
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Auxiliary tabs
struct PlayerSearchView: View {
    var body: some View {
        Text("Search Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
    }
}

struct PlayerLibraryView: View {
    var body: some View {
        Text("Your Library")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
    }
}

// MARK: - Mini player (the accessory itself)
@available(iOS 26.1, *)
struct MiniPlayerView: View {
    let track: Track
    let onPlayPause: (Bool) -> Void
    @State private var isLocallyPlaying = false
    
    // Environment for monitoring the accessory's state (collapsed or expanded)
    @Environment(\.tabViewBottomAccessoryPlacement) var placement
    
    init(
        track: Track,
        initialPlayingState: Bool = false,
        onPlayPause: @escaping (Bool) -> Void
    ) {
            self.track = track
            self.onPlayPause = onPlayPause
            _isLocallyPlaying = State(initialValue: initialPlayingState)
        }

    
    var body: some View {
        // Adapt the interface depending on the placement
        switch placement {
        case .expanded:
            // Expanded view (when the tab bar is at normal size)
            HStack {
                B001_PulsingCircle()
                
                VStack(alignment: .leading) {
                    Text(track.title)
                        .font(.headline)
                    Text(track.singer)
                        .font(.caption2)
                        .italic()

                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        // Action "Back"
                    } label: {
                        Image(systemName: "backward.fill")
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isLocallyPlaying.toggle()
                            onPlayPause(isLocallyPlaying)
                        }
                    } label: {
                        Image(systemName: isLocallyPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                    }
                    
                    Button {
                        // Action "Forward"
                    } label: {
                        Image(systemName: "forward.fill")
                    }
                }
            }
            .padding(.horizontal)
            
        default:
            // Collapsed view (when the tab bar is hidden when scrolling)
            HStack {
                Image(systemName: "music.note")
                Text(track.title)
                    .lineLimit(1)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLocallyPlaying.toggle()
                        onPlayPause(isLocallyPlaying)
                    }
                } label: {
                    Image(systemName: isLocallyPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                    
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }
            .padding(.horizontal)
        }
    }
}

struct B001_WaveAsymmetrical: View {
    private let barCount = 11
    private let maxHeight: CGFloat = 30
    private let minHeight: CGFloat = 3
    
    @State private var phase: CGFloat = 0
    @State private var cancellable: AnyCancellable? = nil
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.blue)
                    .frame(width: 3, height: barHeight(for: index))
                    .frame(height: maxHeight)
                    .animation(.easeInOut(duration: 0.3), value: phase)
            }
        }
        .onAppear {
            cancellable = Timer
                .publish(every: 0.08, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    phase += 0.4
                }
        }
        .onDisappear {
            // cancel the timer publisher to prevent memory leak
            cancellable?.cancel()
            cancellable = nil
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let angle = (CGFloat(index) - phase) * (.pi / 3)
        let normalized = (sin(angle) + 1) / 2  // 0...1
        return minHeight + normalized * (maxHeight - minHeight)
    }
}

struct B001_PulsingCircle: View {
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 16, height: 16)
            .scaleEffect(scale)
            .opacity((1.4 - min(scale, 1)))
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.5
                }
            }
    }
}

#Preview {
    if #available(iOS 26.1, *) {
        B001_AlbumPlayerDemo()
    }
}
