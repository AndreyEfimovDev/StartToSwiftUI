//
//  ManagingPostsView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 09.09.2025.
//

import SwiftUI

struct ManagingPostsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostsViewModel
    private let fileManager = FileStorageManager.shared
    
    @State private var isShowingLoadPostView: Bool = false
    @State private var isShowingEraseAllPostsView: Bool = false
    @State private var isShowingBackupPostsView: Bool = false
    @State private var isShowingShareStorePostsView: Bool = false

    
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        
        ZStack (alignment: .topTrailing) {
            CircleStrokeButtonView(
                iconName: "xmark",
                isIconColorToChange: true,
                imageColorPrimary: Color.mycolor.blue,
                imageColorSecondary: Color.mycolor.red) {
                    action()
                }
                .padding(8)
                .padding(.trailing)
                .zIndex(1)
            
            NavigationStack {
                
                VStack {
                    
                    
                    Button {
                        isShowingLoadPostView.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Load Persisted Posts")
                                .foregroundColor(Color.mycolor.accent)
                            Spacer()
                            Image(systemName: "icloud.and.arrow.down")
                                .foregroundStyle(Color.mycolor.orange)
                        }
                        .padding()
                        .font(.headline)
                        .frame(height: 55)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.mycolor.blue, lineWidth: 1)
                        )
                    }
                    
                    Button {
                        isShowingShareStorePostsView.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Share/Store Posts")
                                .foregroundColor(Color.mycolor.accent)
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Color.mycolor.blue)
                        }
                        .padding()
                        .font(.headline)
                        .frame(height: 55)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.mycolor.blue, lineWidth: 1)
                        )
                    }
                    
//                    ShareStorePostsView()
                    
//                    if let fileURL = fileManager.getFileURL(fileName: fileManager.fileName) {
//                        ShareLink(item: fileURL) {
//                            HStack(spacing: 8) {
//                                Text("Share/Store Posts")
//                                    .foregroundColor(Color.mycolor.accent)
//                                Spacer()
//                                Image(systemName: "square.and.arrow.up")
//                                    .foregroundStyle(Color.mycolor.blue)
//                            }
//                            .padding()
//                            .font(.headline)
//                            .frame(height: 55)
//                            .background(.ultraThinMaterial)
//                            .clipShape(Capsule())
//                            .overlay(
//                                Capsule()
//                                    .stroke(Color.mycolor.blue, lineWidth: 1)
//                            )
//                        }
//                    }
//                    
//                    
                    
                    
                    Button {
                        isShowingBackupPostsView.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Restore Backup")
                                .foregroundColor(Color.mycolor.accent)
                            Spacer()
                            Image(systemName: "tray.and.arrow.up.fill")
                                .foregroundStyle(Color.mycolor.green)
                        }
                        .padding()
                        .font(.headline)
                        .frame(height: 55)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.mycolor.blue, lineWidth: 1)
                        )
                    }
                    
                    
                    
                    Button {
                        isShowingEraseAllPostsView.toggle()
                    } label: {
                        
                        HStack(spacing: 8) {
                            Text("Erase All Posts")
                                .foregroundColor(Color.mycolor.accent)
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundStyle(Color.mycolor.red)
                        }
                        .padding()
                        .font(.headline)
                        .frame(height: 55)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.mycolor.blue, lineWidth: 1)
                        )
                    }
                    
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Managing Posts")
                .sheet(isPresented: $isShowingLoadPostView) {
                    LoadPersistentPostsView()
                        .presentationDetents([.height(600)])
                        .presentationDragIndicator(.automatic)
                }
                .sheet(isPresented: $isShowingBackupPostsView) {
                    RestoreBackupView()
                        .presentationDetents([.height(600)])
                        .presentationDragIndicator(.automatic)
                }
                .sheet(isPresented: $isShowingEraseAllPostsView) {
                    EraseAllPostsView()
                        .presentationDetents([.height(600)])
                        .presentationDragIndicator(.automatic)
                }
                .sheet(isPresented: $isShowingShareStorePostsView) {
                    ShareStorePostsView()
                        .presentationDetents([.height(600)])
                        .presentationDragIndicator(.automatic)
                }
                
            } // NavigationStack
        } // ZStack
    }
}

#Preview {
    ManagingPostsView{
    }
    .environmentObject(PostsViewModel())
    
}
