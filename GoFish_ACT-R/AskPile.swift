//
//  AskPile.swift
//  GoFish_ACT-R
//
//  Created by Evelien van Tricht on 03/04/2024.
//

import SwiftUI

class AskPile: ObservableObject {
    private(set) var cards: [Card] = []

    func addCard(card: Card) {
        print("askpile receives card!")
        cards.append(card)
        objectWillChange.send()
        print("askpile now has \(cards.count) cards!")
    }
    
    func removeCard() -> Card {
        return cards.removeFirst()
    }

    // Check if the pile has a card of the specified rank
    func hasCard(ofRank rank: Rank) -> Bool {
        return cards.contains { $0.rank == rank }
    }

    // Method to check for books and remove them from the player's hand
    func checkForBooks() -> Int {
        var booksCount = 0
        let ranks = cards.map { $0.rank }
        let uniqueRanks = Set(ranks)

        for rank in uniqueRanks {
            let count = ranks.filter { $0 == rank }.count
            if count == 4 {
                // Found a book
                booksCount += 1
                cards.removeAll { $0.rank == rank }
                // This then should be showed in the view
            }
        }

        return booksCount
    }
}
