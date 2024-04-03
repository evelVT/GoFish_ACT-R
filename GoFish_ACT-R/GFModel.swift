import SwiftUI



enum Action: CustomStringConvertible {
    case none // Represents the initial state where the rank is unknown
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace
    
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
        case .none: return "question"
        }
    }
    static func findAction(_ actionString: String) -> Action {
        switch actionString {
        case "two": return(.two)
        case "three": return(.three)
        case "four": return(.four)
        case "five": return(.five)
        case "six": return(.six)
        case "seven": return(.seven)
        case "eight": return(.eight)
        case "nine": return(.nine)
        case "ten": return(.ten)
        case "jack": return(.jack)
        case "queen": return(.queen)
        case "king": return(.king)
        case "ace": return(.ace)
        default: return(.none)
        }
    }
}

struct GFModel {
    let model = Model()
    var modelScore = 0
    private(set) var hand: [Card] = []

    init(id: Int, name: String) {
        model.loadModel(fileName: "goF_model")
        model.run()
    }
    
    //function that checks what rank player of ID playerID asked for
    mutating func playerAskedRank(_ player: Int,  _ asked: Int, _ card: Card) {
        model.modifyLastAction(slot: "player\(player)", value: card.rank.rawValue.description)
        model.modifyLastAction(slot: "rank", value: )
        model.modifyLastAction(slot: "playerAsked", value: asked.description)
    }

    mutating func playerAskedModel(_ playerID: Int, _ rank: Rank){
        model.modifyLastAction(slot: "playerAsking", value: playerID.description)
        model.modifyLastAction(slot: "rank", value: rank.description)

    }
}
