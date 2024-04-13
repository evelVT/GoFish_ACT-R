import SwiftUI
//Card struct.

//Equatable: A type that can be compared for value equality.
struct Card: Equatable {
    enum Suit: String, CaseIterable {
        case hearts = "Hearts"
        case diamonds = "Diamonds"
        case clubs = "Clubs"
        case spades = "Spades"
    }
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

    let suit: Suit
    let rank: Rank
    var open: Bool
    var drag: Bool

    mutating func toggleOpen() {
        open.toggle()
    }
    mutating func toggleDrag() {
        drag.toggle()
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
}
