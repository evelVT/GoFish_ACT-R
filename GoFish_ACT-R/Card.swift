import SwiftUI

enum Suit: String, CaseIterable {
    case hearts = "Hearts"
    case diamonds = "Diamonds"
    case clubs = "Clubs"
    case spades = "Spades"
}
enum Rank: Int, CaseIterable, CustomStringConvertible {
    // Represents the initial state where the rank is unknown
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace

    static func from(string: String) -> Rank {
           switch string.lowercased() {
           case "two": return .two
           case "three": return .three
           case "four": return .four
           case "five": return .five
           case "six": return .six
           case "seven": return .seven
           case "eight": return .eight
           case "nine": return .nine
           case "ten": return .ten
           case "jack": return .jack
           case "queen": return .queen
           case "king": return .king
           case "ace": return .ace
           default: return .ace
           }
       }


    var description: String {
        switch self {
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


//Card struct.

//Equatable: A type that can be compared for value equality.
struct Card: Equatable {

    let suit: Suit
    let rank: Rank
    var open: Bool
    var drag: Bool

    mutating func toggleOpen() {
        if !open {
            open.toggle()
            }
        }
    mutating func toggleClose() {
        if open {
            open.toggle()
            }
        }

    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
}
