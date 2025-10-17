//
//  ToolbarsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 12.09.2025.
//

import SwiftUI

struct ToolbarsView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    
    @State private var isFocusedOnSearchBar: Bool = false
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            //            Text("Hello, world!")
            //                .toolbar {
            //                    ToolbarItem(placement: .bottomBar) {
            //                        Button("action1", action: {})
            //                    }
            //                    ToolbarItem(placement: .bottomBar) {
            //                        Button("action2", action: {})
            //                    }
            //                }
            
            TextField(
                "Search here",
                text: $searchText
            )
            ScrollView {
                ForEach(1...50, id: \.self) { index in
                    Text("\(index)")
                        .font(.headline)
                        .frame(width: 300, height: 150)
                        .foregroundStyle(.red)
                        .background(.yellow.opacity(0.5))
                        .cornerRadius(30)
                }
            }
            .navigationTitle("Title")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    SearchBarView(
                        searchText: $vm.searchText
                    )
                }
            }
            
            
        }
    }
}

#Preview {
    ToolbarsView()
        .environmentObject(PostsViewModel())

}
