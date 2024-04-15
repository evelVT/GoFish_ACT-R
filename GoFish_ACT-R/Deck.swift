import SwiftUI

struct Deck {
    var cards: [Card] = []

    init() {
        self.initializeDeck()
    }

    mutating func shuffle() {
        cards.shuffle()
    }


    mutating func dealCard() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.removeFirst()
    }

    mutating func initializeDeck() {
        cards = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(suit: suit, rank: rank, open:false, drag:false))
            }
        }
    }
}
