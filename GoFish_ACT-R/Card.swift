//Card struct.


//Equatable: A type that can be compared for value equality.
struct Card: Equatable {
    enum Suit: String, CaseIterable {
        case hearts = "Hearts"
        case diamonds = "Diamonds"
        case clubs = "Clubs"
        case spades = "Spades"
    }
    enum Rank: Int, CaseIterable {
        case two = 2, three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace

    }
    let suit: Suit
    let rank: Rank
}