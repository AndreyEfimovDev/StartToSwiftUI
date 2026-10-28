//
//  B009_GlassComposer.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 28.10.2026.
//

import SwiftUI

struct B009_Message: Identifiable {
    let id = UUID()
    let text: String
    let isMine: Bool

    static let samples: [B009_Message] = [
        .init(text: "Hey! Have you tried the new Liquid Glass APIs?", isMine: false),
        .init(text: "Yes — safeAreaBar is my favorite so far.", isMine: true),
        .init(text: "What does it do differently from safeAreaInset?", isMine: false),
        .init(text: "It insets the safe area too, but also extends the scroll edge effect under the bar.", isMine: true),
        .init(text: "So messages fade out softly behind the composer?", isMine: false),
        .init(text: "Exactly. Scroll up and watch the top and bottom edges.", isMine: true),
        .init(text: "And the Soft / Hard switch?", isMine: false),
        .init(text: "That's scrollEdgeEffectStyle — a gentle blur or a crisp divider.", isMine: true)
    ]

    static let replies = [
        "Nice! 👍",
        "Tell me more.",
        "Liquid Glass looks great here.",
        "Try switching to Hard and scroll again."
    ]
}

@available(iOS 26.0, *)
struct B009_GlassComposerDemo: View {

    private enum EdgeStyle: CaseIterable, Identifiable {
        case soft
        case hard

        var id: Self { self }

        var title: String {
            switch self {
            case .soft: "Soft"
            case .hard: "Hard"
            }
        }

        var value: ScrollEdgeEffectStyle {
            switch self {
            case .soft: .soft
            case .hard: .hard
            }
        }
    }

    @State private var messages = B009_Message.samples
    @State private var draft = ""
    @State private var edgeStyle: EdgeStyle = .soft
    // Each send gets a new token; .task(id:) cancels the previous pending reply.
    @State private var replyToken: UUID?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(messages) { message in
                    bubble(message)
                }
            }
            .padding()
        }
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
        .scrollEdgeEffectStyle(edgeStyle.value, for: .all)
        // Unlike safeAreaInset, safeAreaBar also extends the scroll edge effect under the bar.
        .safeAreaBar(edge: .top) { header }
        .safeAreaBar(edge: .bottom) { composer }
        .background(Color.mycolor.mySectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .task(id: replyToken) { await sendReply() }
    }

    // MARK: - Bubble

    private func bubble(_ message: B009_Message) -> some View {
        Text(message.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundStyle(message.isMine ? .white : .primary)
            .background(
                message.isMine ? AnyShapeStyle(Color.mycolor.myBlue) : AnyShapeStyle(.background),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .frame(maxWidth: 280, alignment: message.isMine ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: message.isMine ? .trailing : .leading)
    }

    // MARK: - Header

    private var header: some View {
        Picker("Edge effect", selection: $edgeStyle) {
            ForEach(EdgeStyle.allCases) { Text($0.title).tag($0) }
        }
        .pickerStyle(.segmented)
        .frame(width: 200)
        .padding(.top, 8)
    }

    // MARK: - Composer

    private var composer: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(alignment: .bottom, spacing: 12) {
                // Fills the field with a suggested message.
                Button {
                    draft = B009_Message.replies.randomElement() ?? ""
                } label: {
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }
                .glassEffect(.regular.interactive(), in: Circle())

                TextField("Message", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22))

                Button(action: send) {
                    Image(systemName: "arrow.up")
                        .font(.title3.bold())
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .tint(Color.mycolor.myBlue)
                .disabled(trimmedDraft.isEmpty)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Appends the draft as an outgoing message and schedules an auto-reply.
    private func send() {
        guard !trimmedDraft.isEmpty else { return }
        withAnimation(.smooth) {
            messages.append(B009_Message(text: trimmedDraft, isMine: true))
        }
        draft = ""
        replyToken = UUID()
    }

    /// Posts a canned reply after a short pause; cancelled if another message is sent first.
    private func sendReply() async {
        guard replyToken != nil else { return }
        do {
            try await Task.sleep(for: .seconds(1.2))
        } catch {
            return
        }
        withAnimation(.smooth) {
            messages.append(B009_Message(text: B009_Message.replies.randomElement() ?? "👍", isMine: false))
        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B009_GlassComposerDemo()
            .padding()
    }
}
