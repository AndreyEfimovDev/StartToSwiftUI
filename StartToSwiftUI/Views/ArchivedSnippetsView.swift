//
//  ArchivedSnippetsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 08.03.2026.
//
//  Place in Views/Snippets/ManagingSnippets/
//
//  Hidden snippets only — CodeSnippet has no .deleted status.

import SwiftUI

struct ArchivedSnippetsView: View {

    // MARK: - Dependencies
    @EnvironmentObject private var vm: SnippetsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    // MARK: - Computed Properties
    private var hiddenSnippets: [CodeSnippet] {
        vm.allSnippets.filter { $0.status == .hidden }
    }

    // MARK: - Body
    var body: some View {
        Group {
            if hiddenSnippets.isEmpty {
                emptyView
            } else {
                List {
                    ForEach(hiddenSnippets) { snippet in
                        SnippetRowView(snippet: snippet)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Restore", systemImage: "arrow.uturn.left") {
                                    vm.setSnippetActive(snippet)
                                }
                                .tint(Color.mycolor.myGreen)
                            }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(Color.mycolor.myAccent.opacity(0.35))
                    .listRowSeparator(.hidden, edges: [.top])
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.mycolor.myPurple.opacity(0.15))
        .navigationTitle("Archived Snippets")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbar }
        .onAppear { vm.loadSnippetsFromSwiftData() }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            BackButtonView { coordinator.pop() }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                coordinator.popToRoot()
            } label: {
                Image(systemName: "house")
                    .foregroundStyle(Color.mycolor.myAccent)
            }
        }
    }

    // MARK: - Empty State

    private var emptyView: some View {
        ContentUnavailableView(
            "No Hidden Snippets",
            systemImage: "archivebox",
            description: Text("Swipe left on a snippet to hide it.")
        )
    }
}

// MARK: - Preview

#Preview {
    let hiddenSnippet = PreviewData.sampleSnippet1
    hiddenSnippet.status = .hidden

    let vm = SnippetsViewModel(
        dataSource: MockSnippetsDataSource(snippets: [hiddenSnippet, PreviewData.sampleSnippet2]),
        fbSnippetsManager: MockFBSnippetsManager()
    )
    vm.loadSnippetsFromSwiftData()

    NavigationStack {
        ArchivedSnippetsView()
            .environmentObject(vm)
            .environmentObject(AppCoordinator())
    }
}
