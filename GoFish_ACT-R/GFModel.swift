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
    var id: Int
//    var name: String
//    var id: Int
//    var score = 0
    private(set) var hand: [Card] = []

    init(id: Int) {
        self.id = id
        self.hasRank = Array(repeating: .none, count: 3)
        self.doesNotHaveRank = Array(repeating: .none, count: 3)
        model.loadModel(fileName: "goF_model")
        model.run()


    }
    //function that checks what rank player of ID playerID asked for
    //production: remember-player-asking-diff
    mutating func playerAskingRank(_ playerID: Int, _ rank: Card.Rank) {
        //self.hasRank[playerID] = rank
        print("Model \(self.id) listened that player \(playerID) asked.")
        model.modifyLastAction(slot: "playerAsking", value: playerID.description)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: "other_model")
        model.run()


    }
    //production: remember-player-asked
    mutating func playerAskedRank(_ playerAskedID: Int) {
        //self.hasRank[playerID] = rank
        print("Model \(self.id) listened that player \(playerAskedID) was asked.")
        model.modifyLastAction(slot: "playerAsked", value: playerAskedID.description)
        model.run()
    }

    //Production: remember-player-asking-model
    mutating func playerAskedModel(_ playerID: Int, _ rank: Card.Rank){
       // self.hasRank[playerID] = rank
        print("Model \(self.id) was asked by player \(playerID)")
        model.modifyLastAction(slot: "playerAsking", value: playerID.description)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: "model")
        model.run()

    }

    //model-is-asked-has
    mutating func hasCard(_ rank: Card.Rank){
        print("Model \(self.id) checked and has a \(rank.description)")
        model.modifyLastAction(slot: "rank", value : rank.description)
        model.modifyLastAction(slot: "isThere", value : "yes")
        model.run()
    }

    //model-is-asked-has-no
    mutating func noCard(_ rank: Card.Rank){
        print("Model \(self.id) checked and DOES NOT HAVE a \(rank.description)")
        model.modifyLastAction(slot: "rank", value : rank.description)
        model.modifyLastAction(slot: "isThere", value : "no")
        model.run()
    }

    //checkTurn-DiffP
    mutating func notMyTurn(){
        print("Model \(self.id) is listening")
        model.modifyLastAction(slot:"player", value: "opponent_turn")
        model.run()
        
    }

    //checkTurn-M and checkTurn-M-Again
    mutating func myTurn(){
        print("It's model \(self.id)'s turn")
        if let modelActionString = model.lastAction(slot: "status") {
            print(modelActionString)
        }
        model.modifyLastAction(slot:"player", value: "model_turn")
        model.run()
    }
    

    //no-player-has
    mutating func goRandom(){
        print("Model \(self.id) goes random")
        //print(model.actionChunk())
        if let modelActionString = model.lastAction(slot: "isThere") {
            print(modelActionString)
        }
        model.modifyLastAction(slot: "player", value: "none")
        model.run()
    }

    //random-pick
    mutating func askRandom(_ randomPlayerID: Int, _ randomRank: Card.Rank){
        print("Model \(self.id) asked randomly player \(randomPlayerID) for a \(randomRank.description)")
        model.modifyLastAction(slot: "rank", value: randomRank.description )
        model.modifyLastAction(slot: "player", value: String(randomPlayerID))
        model.run()

    }
    
    //cards-not-received
    mutating func answeredFish(_ askedPlayerID: Int, _ seenRank: Card.Rank){
        print("Player \(askedPlayerID) told Model \(self.id) to Go Fish")
        model.modifyLastAction(slot: "rank", value: seenRank.description )
        model.modifyLastAction(slot: "player", value: String(askedPlayerID))
        model.modifyLastAction(slot: "receive", value: "Go-fish")
        model.run()
    }
    
    //draw-card
    mutating func drawFromPile(_ drawnRank: Card.Rank){
        print("Model \(self.id) draws from pile a card of rank \(drawnRank).")
        model.modifyLastAction(slot: "rank", value: drawnRank.description )
        model.run()
    }
    
    //cards-received
    mutating func answeredYes(_ askedPlayerID: Int, _ seenRank: Card.Rank){
        print("Player \(askedPlayerID) gave Model \(self.id) cards of rank \(seenRank)")
        model.modifyLastAction(slot: "rank", value: seenRank.description )
        model.modifyLastAction(slot: "player", value: String(askedPlayerID))
        model.modifyLastAction(slot: "receive", value: "yes")
        model.run()
    }
    
    //check-set
    mutating func checkSet( _ seenRank: Card.Rank, _ numberRank: Int){
        print("Model \(self.id) is checking if they have a set of \(seenRank)")
        model.modifyLastAction(slot: "rank", value: seenRank.description )
        model.modifyLastAction(slot: "number", value: String(numberRank))
        model.run()
    }
    
    //make-set
    mutating func makeSet( _ seenRank: Card.Rank){
        print("Model \(self.id) is making the set of \(seenRank)")
        model.modifyLastAction(slot: "rank", value: seenRank.description )
        model.run()
    }

    //check-hand
    //Need way to get some response from the model on whether it remembers something about the card it inspected
    mutating func getCard(_ rank: Card.Rank){
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "isThere", value: "yes")
        model.run()
    }

    //TODO:
    // -asking for the card
    // -handling the response -- taking the card / drawing a card
    // - check-set and no-need which are about making a set i presume
    // - tie these to the GameLogic
}
