import SwiftUI
//Player class

class Player: ObservableObject, Identifiable {
    let id: Int
    @Published var name: String
    @Published var score = 0
    private(set) var hand: [Card] = []
    @Published var gfModel: GFModel?
    var strategy: String?

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        if id != 1  {
            self.gfModel = GFModel(id: id)

        }
        if id == 2 {
            strategy = "random"
        }
        if id == 3 {
            strategy = "risky"
        }
        if id == 4 {
            strategy = "careful"
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
        makeSets()
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

    func giveOneCard(ofRank rank: Rank) -> Card {
        let matchingCards = hand.filter { $0.rank == rank }
        let card = matchingCards.randomElement()!
        return card
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
    func hasCard(ofRank rank: Rank) -> Bool {
        return hand.contains { $0.rank == rank }
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
