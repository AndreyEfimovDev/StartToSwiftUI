//
//  B004_MiniBrowser.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 21.09.2026.
//

import SwiftUI
import WebKit

@available(iOS 26.0, *)
struct B004_MiniBrowserDemo: View {
    // WebPage is the new Observable model that owns navigation state
    // (url, title, isLoading, backForwardList) — WebView just renders it.
    // Before iOS 26 this meant wrapping WKWebView in a UIViewRepresentable.
    @State private var page = WebPage()
    @State private var urlText = "https://developer.apple.com"
    @FocusState private var isAddressFocused: Bool
    // backForwardList isn't observed by SwiftUI, so back/forward availability
    // is kept in state and refreshed on every navigation event (see body).
    @State private var canGoBack = false
    @State private var canGoForward = false

    var body: some View {
        VStack(spacing: 0) {
            addressBar

            if page.isLoading {
                ProgressView(value: page.estimatedProgress)
                    .progressViewStyle(.linear)
            }

            WebView(page)
        }
        .onAppear {
            load(urlText)
        }
        // Keep the address bar in sync with navigation (back/forward, links,
        // redirects) — but don't overwrite what the user is typing right now.
        .onChange(of: page.url) { _, newURL in
            guard let newURL, !isAddressFocused else { return }
            urlText = newURL.absoluteString
        }
        // `navigations` streams every navigation event — address bar,
        // back/forward and links tapped inside the page. By the time a
        // navigation commits, backForwardList is up to date.
        .task {
            while !Task.isCancelled {
                do {
                    for try await _ in page.navigations {
                        updateHistoryButtons()
                    }
                    break
                } catch {
                    // A failed navigation (e.g. cancelled by a newer one) —
                    // refresh and keep listening.
                    updateHistoryButtons()
                }
            }
        }
    }

    private var addressBar: some View {
        HStack(spacing: 12) {
            Button {
                goBack()
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!canGoBack)

            Button {
                goForward()
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!canGoForward)

            TextField("Enter URL", text: $urlText)
                .focused($isAddressFocused)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit {
                    isAddressFocused = false // hand the bar back to navigation sync
                    load(urlText)
                }

            Button {
                page.reload()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .padding()
    }

    private func load(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        page.load(URLRequest(url: url))
    }

    // WebPage has no goBack()/goForward() — navigation history is exposed as
    // backForwardList.backList/forwardList (nearest page is the last item
    // going back, the first item going forward). Load the history item
    // itself: that moves the current position through the history. Loading
    // its URL as a new request would push a new entry instead — clearing
    // forward history and making "back" loop between the last two pages.
    private func goBack() {
        guard let item = page.backForwardList.backList.last else { return }
        page.load(item)
    }

    private func goForward() {
        guard let item = page.backForwardList.forwardList.first else { return }
        page.load(item)
    }

    /// Reads back/forward availability from the current history.
    private func updateHistoryButtons() {
        canGoBack = !page.backForwardList.backList.isEmpty
        canGoForward = !page.backForwardList.forwardList.isEmpty
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B004_MiniBrowserDemo()
    }
}
