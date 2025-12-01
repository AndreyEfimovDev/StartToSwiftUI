//
//  CategoryFilterView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 06.11.2025.
//

import SwiftUI

struct CategoryFilterView: View {
    
    @EnvironmentObject private var vm: PostsViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("All") {
                    vm.selectedCategory = nil
                }
                .buttonStyle(CategoryButtonStyle(isSelected: vm.selectedCategory == nil))
                
                let categories = [vm.mainCategory, "Other"]
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
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
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
    CategoryFilterView()
        .environmentObject(PostsViewModel())
    
}
