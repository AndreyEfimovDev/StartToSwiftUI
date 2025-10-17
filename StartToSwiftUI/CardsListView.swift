//
//  SwiftUIView.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 13.09.2025.
//

import SwiftUI

class Card: ObservableObject, Identifiable {
    @Published var id: String = UUID().uuidString
    @Published var en: String
    @Published var ru: String
    @Published var sample_en: String
    @Published var sample_ru: String
    @Published var pool: String
    
    init(en: String, ru: String, sample_en: String, sample_ru: String, pool: String) {
        self.en = en
        self.ru = ru
        self.sample_en = sample_en
        self.sample_ru = sample_ru
        self.pool = pool
    }
}

struct CardsListView: View {
    @State private var cards: [Card] = [
        Card(en: "Cat", ru: "Кошка", sample_en: "The cat is cute", sample_ru: "Кошка красивая", pool: "Animals"),
        Card(en: "Dog", ru: "Собака", sample_en: "The dog barks", sample_ru: "Собака лает", pool: "Animals")
    ]
    
    @State private var selectedCard: Card? = nil
    @State private var showDetails = false
    
    var sortedCards: [Card] {
        cards.sorted { $0.en < $1.en }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedCards) { card in
                    Button {
                        selectedCard = card     // редактируем существующую
                        showDetails = true
                    } label: {
                        VStack(alignment: .leading) {
                            Text(card.en).font(.headline)
                            Text(card.ru).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Cards")
            .toolbar {
                Button("Add") {
                    selectedCard = nil        // создаём новую
                    showDetails = true
                }
            }
            .sheet(isPresented: $showDetails) {
                CardDetailsView(cards: $cards, card: selectedCard)
            }
        }
    }
}

/// Детали карточки (создание или редактирование)
struct CardDetailsView: View {
    @Binding var cards: [Card]
    @ObservedObject var editingCard: Card
    
    // Инициализатор, который принимает либо существующую карту, либо nil
    init(cards: Binding<[Card]>, card: Card?) {
        self._cards = cards
        if let card = card {
            // редактируем существующую
            self.editingCard = card
        } else {
            // создаём новую
            self.editingCard = Card(en: "", ru: "", sample_en: "", sample_ru: "", pool: "")
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("English", text: $editingCard.en)
                TextField("Russian", text: $editingCard.ru)
                TextField("Sample EN", text: $editingCard.sample_en)
                TextField("Sample RU", text: $editingCard.sample_ru)
                TextField("Pool", text: $editingCard.pool)
            }
            .navigationTitle("Card Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !cards.contains(where: { $0.id == editingCard.id }) {
                            // новая — добавляем в массив
                            cards.append(editingCard)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CardsListView()
}
