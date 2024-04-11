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
    //Helps with productions remember-player-asking-diff, remember-player-asked
    mutating func playerAskedRank(_ playerID: Int,  _ playerAskedID: Int, _ rank: Card.Rank) {
        //self.hasRank[playerID] = rank
        model.modifyLastAction(slot: "playerAsking", value: playerID.description)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: playerAskedID.description)


    }

    //Production: remember-player-asking-model
    mutating func playerAskedModel(_ playerID: Int, _ rank: Card.Rank){
       // self.hasRank[playerID] = rank
        print("PlayerAskedModel called")
        model.modifyLastAction(slot: "playerAsking", value: playerID.description)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: "model_turn")

    }

    //model-is-asked-has
    mutating func hasCard(_ rank: Card.Rank){
        model.modifyLastAction(slot: "rank", value : rank.description)
        model.modifyLastAction(slot: "isThere", value : "yes")
    }

    //model-is-asked-has-no
    mutating func noCard(_ rank: Card.Rank){
        model.modifyLastAction(slot: "rank", value : rank.description)
        model.modifyLastAction(slot: "isThere", value : "no")
    }

    //checkTurn-DiffP
    mutating func notMyTurn(){
        model.modifyLastAction(slot:"player", value: "opponent_turn")
        model.run()

    }

    //checkTurn-M
    mutating func myTurn(){
        if let modelActionString = model.lastAction(slot: "status") {
            print(modelActionString)
        }
        model.modifyLastAction(slot:"player", value: "model_turn")
        model.run()
    }

    //no-player-has
    mutating func goRandom(){
        print("goRandom fired")
        print(model.actionChunk())
        if let modelActionString = model.lastAction(slot: "isThere") {
            print(modelActionString)
        }
        model.modifyLastAction(slot: "players", value: "none")
        model.run()
    }

    //random-pick
    mutating func askRandom(_ randomPlayerID: Int, _ randomRank: Card.Rank){
        if model.lastAction(slot: "status") == "waiting"{
            print("Model awaits for random rank and random player")
        }
        model.modifyLastAction(slot: "rank", value: randomRank.description )
        model.modifyLastAction(slot: "player", value: String(randomPlayerID))

    }

    //check-hand
    //Need way to get some response from the model on whether it remembers something about the card it inspected
    mutating func tryRemember(_ rank: Card.Rank){
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "isThere", value: "yes")
    }

    //TODO:
    // -asking for the card
    // -handling the response -- taking the card / drawing a card
    // - check-set and no-need which are about making a set i presume
    // - tie these to the GameLogic
}
