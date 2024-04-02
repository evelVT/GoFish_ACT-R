import Foundation



enum Rank: Int, CaseIterable, CustomStringConvertible {
    case none = 0 // Represents the initial state where the rank is unknown
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace
    
    var description: String {
        switch self {
        case .none: return "none"
        case .two: return "two"
        case .three: return "three"
        case .four: return "four"
        case .five: return "five"
        case .six: return "six"
        case .seven: return "seven"
        case .eight: return "eight"
        case .nine: return "nine"
        case .ten: return "ten"
        case .jack: return "jack"
        case .queen: return "queen"
        case .king: return "king"
        case .ace: return "ace"
        }
    }
}

struct GFModel: Identifiable {
    let model = Model()
    var hasRank: [Rank]
    var doesNotHaveRank: [Rank]
    @Published var name: String
    @Published var score = 0
    private(set) var hand: [Card] = []

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.hasRank = Array(repeating: .none, count: 3)
        self.doesNotHaveRank = Array(repeating: .none, count: 3)
        model.loadModel(fileName: "...")
        model.run()
    }

    mutating func emptyHand() {
        hand.removeAll()
    }

    mutating func receiveCard(card: Card) {
        print("\(name) receives card!")
        hand.append(card)
        objectWillChange.send()
        print("\(name) now has \(hand.count) cards!")
        checkForBooks()
    }

    // Function that will be called when the player is asked for a specific rank
    // Returns all cards of the specified rank and removes them from the player's hand
    mutating func giveAllCards(ofRank rank: Card.Rank) -> [Card] {
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
        // TODO: Implement logic to send the cards to the player who asked for them
       return nil
    }

    // Respond to another player's request for a specific rank
    // Changed this to actually return the cards.
    mutating func respondToCardRequest(card: Card) -> [Card] {
        let hasCard = hasCard(ofRank: card.rank)
        if hasCard {
            let cardsGiven = giveAllCards(ofRank: card.rank)
            // Call some function to send the cards to the player who asked for them. Maybe somehow notify the game
            // TODO: Implement logic to send the cards to the player who asked for them
            return cardsGiven
        }
        return []
    }

    // Method to check for books and remove them from the player's hand
    // Returns the number of books found and removed
    //not sure when this would be called. Each time the player receives a card? So in receiveCard?
    mutating func checkForBooks() -> Int {
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
    //function that checks what rank player of ID playerID asked for 
    mutating func playerAskedRank(_ playerID: Int,  _ playerAskedID: Int, _ rank: Rank) {
        self.hasRank[playerID] = rank
        model.modifyLastAction(slot: "playerAsking", value: playerID)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: playerAskedID)
    }

    mutating func playerAskedModel(_ playerID: Int, _ rank: Rank){
        self.hasRank[playerID] = rank
        model.modifyLastAction(slot: "playerAsking", value: playerID)
        model.modifyLastAction(slot: "rank", value: rank.description)

    }
}