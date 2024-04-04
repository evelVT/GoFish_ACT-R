import SwiftUI



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

struct GFModel {
    let model = Model()
    var hasRank: [Rank]
    var doesNotHaveRank: [Rank]
//    var name: String
//    var id: Int
//    var score = 0
    private(set) var hand: [Card] = []

    init() {
        self.hasRank = Array(repeating: .none, count: 3)
        self.doesNotHaveRank = Array(repeating: .none, count: 3)
        model.loadModel(fileName: "goF_model")
        model.run()


    }
    //function that checks what rank player of ID playerID asked for
    mutating func playerAskedRank(_ playerID: Int,  _ playerAskedID: Int, _ rank: Card.Rank) {
        //self.hasRank[playerID] = rank
        model.modifyLastAction(slot: "playerAsking", value: playerID.description)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: playerAskedID.description)

    }

    mutating func playerAskedModel(_ playerID: Int, _ rank: Card.Rank){
       // self.hasRank[playerID] = rank
        model.modifyLastAction(slot: "playerAsking", value: playerID.description)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: "model_turn")

    }

    mutating func hasCard(_ rank: Card.Rank){
        model.modifyLastAction(slot: "rank", value : rank.description)
        model.modifyLastAction(slot: "isThere", value : "yes")
    }

    mutating func noCard(_ rank: Card.Rank){
        model.modifyLastAction(slot: "rank", value : rank.description)
        model.modifyLastAction(slot: "isThere", value : "no")
    }



    mutating func notMyTurn(){
        model.modifyLastAction(slot:"player", value: "opponent_turn")
    }

    mutating func myTurn(){
        model.modifyLastAction(slot:"player", value: "model_turn")
    }

    mutating func goRandom(){
        model.modifyLastAction(slot: "players", value: "none")
    }

    mutating func askRandom(_ randomPlayerID: Int, _ randomRank: Card.Rank){
        model.modifyLastAction(slot: "rank", value: randomRank.description )
        model.modifyLastAction(slot: "player", value: String(randomPlayerID))

    }
}
