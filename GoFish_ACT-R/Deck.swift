

struct Deck {
    private var cards: [Card] = []

    init() {
        self.initializeDeck()
    }

    mutating func shuffle() {
        cards.shuffle()
    }

    //deals a card (if there is a card)
    mutating func dealCard() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.removeFirst()
    }

    private mutating func initializeDeck() {
        cards = []
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
    }
}
