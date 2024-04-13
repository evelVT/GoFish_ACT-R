import SwiftUI
//Player class

class Player: ObservableObject, Identifiable {
    let id: Int
    @Published var name: String
    @Published var score = 0
    private(set) var hand: [Card] = []
    @Published var gfModel: GFModel?

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        if id != 1  {
            self.gfModel = GFModel(id: id)

        }

    }
    func emptyHand() {
        hand.removeAll()
    }

    func addCardPlayer(card: Card) {
        print("\(name) receives card!")
        hand.append(card)
        sortHand()
        objectWillChange.send()
        print("\(name) now has \(hand.count) cards!")
        print("Check for books in \(name)'s hand!")
        score += checkForBooks()
    }

    func addCard(card: Card) {
        print("\(name) receives card!")
        hand.append(card)
        sortHand()
        objectWillChange.send()
        print("\(name) now has \(hand.count) cards!")
    }

    func makeSets() {
        print("Check for books in \(name)'s hand!")
        score += checkForBooks()
    }

    func giveNoCards(ofRank rank: Rank) -> Int {
        let matchingCards = hand.filter { $0.rank == rank }
        let num = matchingCards.count
        return num
    }

    func returnRankList() -> [Rank] {
        let uniqueRanks = Set(hand.map { $0.rank })
        return Array(uniqueRanks)
    }

    func removeCard(card: Card) {
        hand.removeAll(where: {$0 == card})
    }

    // Function that will be called when the player is asked for a specific rank
    // Returns all cards of the specified rank and removes them from the player's hand
    func giveAllCards(ofRank rank: Rank) -> [Card] {
        let matchingCards = hand.filter { $0.rank == rank }
        hand = hand.filter { $0.rank != rank }
        return matchingCards
    }

    // Check if the player has a card of the specified rank
    //$0 some weird shorthand for basically saying "for each card in hand, check if the rank is equal to the rank passed in"
    func hasCard(ofRank rank: Rank) -> Bool {
        return hand.contains { $0.rank == rank }
    }

    // Choose a rank to ask for from another player
    func chooseCardToAskFor() -> Rank? {
        // TODO: Implement logic to send the cards to the player who asked for them
       return nil
    }

    func sortHand() {
        hand = hand.sorted { (lhs, rhs) in
            if lhs.rank == rhs.rank { // <1>
                return lhs.suit.rawValue > rhs.suit.rawValue
            }

            return lhs.rank.rawValue > rhs.rank.rawValue // <2>
        }
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
