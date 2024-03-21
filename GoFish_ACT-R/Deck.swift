import SwiftUI

struct Deck {
    var cards: [Card] = []

    init() {
        self.initializeDeck()
    }

    mutating func shuffle() {
        cards.shuffle()
    }

    //deals a card (if there is a card)
    //random comment for commit
    mutating func dealCard() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.removeFirst()
    }

    mutating func initializeDeck() {
        cards = [] // only keep this if we want it to reset the deck
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                cards.append(Card(suit: suit, rank: rank, open:false, drag:false))
            }
        }
    }
}
