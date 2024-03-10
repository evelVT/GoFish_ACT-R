class Player {
    let id: Int
    private(set) var hand: [Card] = []

    init(name: String) {
        self.name = name
    }

    func receiveCard(card: Card) {
        hand.append(card)
    }

    // Function that will be called when the player is asked for a specific rank
    // Returns all cards of the specified rank and removes them from the player's hand
    func giveAllCards(ofRank: card.rank) -> [Card] {
        let matchingCards = hand.filter { $0.rank == rank }
        hand = hand.filter { $0.rank != rank }
        return matchingCards
    }

    // Check if the player has a card of the specified rank
    //$0 some weird shorthand for basically saying "for each card in hand, check if the rank is equal to the rank passed in"
    func hasCard(ofRank rank: Card.Rank) -> Bool {
        return hand.contains { $0.rank == rank }
    }

    // Choose a rank to ask for from another player
    func chooseCardToAskFor() -> Card.Rank? {
       pass
    }

    // Respond to another player's request for a specific rank
    // Returns true if the card(s) were found and given, false otherwise
    func respondToCardRequest(card: Card) -> Bool {
        let hasCard = hasCard(ofRank: card.rank)
        if hasCard {
            let cardsGiven = giveAllCards(ofRank: card.rank)
            // Call some function to send the cards to the player who asked for them. Maybe somehow notify the game
        }
        return hasCard
    }

    // Method to check for books and remove them from the player's hand
    // Returns the number of books found and removed
    //not sure when this would be called. Each time the player receives a card? So in receiveCard?
    func checkForBooks() -> Int {
        var booksCount = 0
        let ranks = hand.map { $0.rank }
        let uniqueRanks = Set(ranks)

        for rank in uniqueRanks {
            let count = ranks.filter { $0 == rank }.count
            if count == 4 {
                // Found a book
                booksCount += 1
                hand.removeAll { $0.rank == rank }
                // This then should be showed in the view
            }
        }

        return booksCount
    }
}
