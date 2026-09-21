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
    }

    private var addressBar: some View {
        HStack(spacing: 12) {
            Button {
                goBack()
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(page.backForwardList.backList.isEmpty)

            Button {
                goForward()
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(page.backForwardList.forwardList.isEmpty)

            TextField("Enter URL", text: $urlText)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit {
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

    // WebPage has no built-in goBack()/goForward() — navigation history is
    // exposed as backForwardList.backList/forwardList (nearest page is the
    // last item going back, the first item going forward), and moving
    // through it just means loading that item's URL again.
    private func goBack() {
        guard let item = page.backForwardList.backList.last else { return }
        page.load(URLRequest(url: item.url))
    }

    private func goForward() {
        guard let item = page.backForwardList.forwardList.first else { return }
        page.load(URLRequest(url: item.url))
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        B004_MiniBrowserDemo()
    }
}
