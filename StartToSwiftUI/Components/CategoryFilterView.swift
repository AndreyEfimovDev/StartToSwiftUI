//
//  CategoryFilterView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.11.2025.
//

import SwiftUI
import SwiftData

struct CategoryFilterView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("All") {
                    vm.selectedCategory = nil
                }
                .buttonStyle(
                    CategoryButtonStyle(
                        isSelected: vm.selectedCategory == nil
                    )
                )
                
                if let categories = vm.allCategories {
                    ForEach(categories, id: \.self) { category in
                            Button(category) {
                                vm.selectedCategory = category
                            }
                            .buttonStyle(
                                CategoryButtonStyle(
                                    isSelected: vm.selectedCategory == category
                                )
                            )
                    }
                }
            }
        }
    }
}

struct CategoryButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
    }
}


#Preview {
    
    let container = try! ModelContainer(for: Post.self, Notice.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    let vm = PostsViewModel(modelContext: context)
    
    CategoryFilterView()
        .environmentObject(vm)
    
}
