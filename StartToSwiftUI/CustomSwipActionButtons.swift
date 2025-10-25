//
//  CustomSwipActionButtons.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 25.10.2025.
//

import SwiftUI

struct CustomSwipeView: View {
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var containerWidth: CGFloat = 0
    
    var body: some View {
//        GeometryReader { _ in
//            let containerWidth = geometry.size.width
            
            ZStack(alignment: .trailing) {
                // Фон действий при свайпе - теперь слева от контента
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            resetPosition()
                        }
                        print("Like tapped")
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.red))
                    }
                    
                    Button(action: {
                        withAnimation {
                            resetPosition()
                        }
                        print("Trash tapped")
                    }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.gray))
                    }
                }
                .padding(.horizontal, 16)
                .opacity(offset < 0 ? 1 : 0) // Показываем кнопки только при свайпе влево
                
                // Основной контент
                HStack {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 60)
                        .overlay(
                            Text("Свайпните влево или вправо")
                                .foregroundColor(.white)
                        )
                    
                    Spacer()
                }
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Разрешаем свайп в обе стороны
                            let newOffset = value.translation.width
                            
                            // Ограничиваем максимальный свайп
                            if newOffset > 100 {
                                offset = 100
                            } else if newOffset < -150 {
                                offset = -150
                            } else {
                                offset = newOffset
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                // Определяем направление и силу свайпа
                                if value.translation.width < -80 {
                                    // Свайп влево - показываем кнопки справа
                                    offset = -120
                                    isSwiped = true
                                } else if value.translation.width > 80 {
                                    // Свайп вправо - показываем кнопки слева
                                    offset = 100
                                    isSwiped = true
                                } else {
                                    // Возвращаем на место
                                    resetPosition()
                                }
                            }
                        }
                )
            }
//        }
        .frame(height: 60)
        .onChange(of: isSwiped) { _, newValue in
            if !newValue {
                resetPosition()
            }
        }
    }
    
    private func resetPosition() {
        withAnimation(.spring()) {
            offset = 0
            isSwiped = false
        }
    }
}

// Пример использования в списке
struct CustomSwipActionButtons: View {
    var body: some View {
        List {
            ForEach(0..<10, id: \.self) { index in
                CustomSwipeView()
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
    }
}


#Preview {
    CustomSwipActionButtons()
}
