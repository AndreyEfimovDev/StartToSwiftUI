//
//  SheetView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 11.09.2025.
//

import SwiftUI

struct ContentSheetView: View {

    @State private var showSheet = false
        
        var body: some View {
            ZStack {
                // Фон HomeView
                LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                Button("Открыть Sheet") {
                    withAnimation(.spring()) {
                        showSheet.toggle()
                    }
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if showSheet {
                    // Полупрозрачный фон
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showSheet = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        SheetView(showSheet: $showSheet)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(1)
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
    }

    struct SheetView: View {
        @Binding var showSheet: Bool
        @State private var offset: CGFloat = 0
        
        var body: some View {
            VStack(spacing: 20) {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, 8)
                
                Text("\(offset)")
                    .font(.title)
                    .bold()
                Text("Свайпни вниз 👆")
                    .font(.title)
                    .bold()
                Text("Теперь можно закрыть лист жестом drag-to-dismiss 🚀")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 30)
            .background(
//                Group {
//                    if #available(iOS 15.0, *) {
                        ZStack {
                            Rectangle().fill(.ultraThinMaterial) // <-- правильное использование
                            LinearGradient(
                                colors: [.white.opacity(0.3), .blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .blendMode(.overlay)
                        }
//                    } else {
//                        Color(.systemBackground).opacity(0.95) // fallback
//                    }
//                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(radius: 10)
//            .padding(.horizontal)
            .offset(y: offset) // смещение при перетаскивании
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 { // тянем вниз
                            offset = gesture.translation.height
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > 150 { // достаточно тянули
                            withAnimation(.spring()) {
                                showSheet = false
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
        }
    }



#Preview {
    ContentSheetView()
}
