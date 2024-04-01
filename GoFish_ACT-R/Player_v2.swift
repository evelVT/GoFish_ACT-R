
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

struct RPSModel {
    let model = Model()
    var hasRank: [Rank]
    var doesNotHaveRank: [Rank]

    init() {
        self.hasRank = Array(repeating: .none, count: 3)
        self.doesNotHaveRank = Array(repeating: .none, count: 3)
        model.loadModel(fileName: "...")
        model.run()
    }

    //function that checks what rank player of ID playerID asked for 
    mutating func playerAskedRank(_ action: Action, _ playerID: Int, _ rank: Rank, _ playerAskedID: Int) {
        self.hasRank[0] = rank
        model.modifyLastAction(slot: "playerAsking", value: playerID)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: playerAskedID)

    
    }
}