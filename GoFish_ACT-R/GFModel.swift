import SwiftUI



struct GFModel {
    let model = Model()
    var id: Int
    private(set) var hand: [Card] = []

    init(id: Int) {
        self.id = id
        model.loadModel(fileName: "goF_model")
        model.run()


    }
    //function that checks what rank player of ID playerID asked for
    //production: remember-player-asking-diff
    mutating func playerAskingRank(_ playerID: Int, _ rank: Rank) {
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
    mutating func playerAskedModel(_ playerID: Int, _ rank: Rank){
       // self.hasRank[playerID] = rank
        print("Model \(self.id) was asked by player \(playerID)")
        model.modifyLastAction(slot: "playerAsking", value: playerID.description)
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "playerAsked", value: "model")
        model.run()

    }

    //model-is-asked-has
    mutating func hasCard(_ rank: Rank){
        print("Model \(self.id) checked and has a \(rank.description)")
        model.modifyLastAction(slot: "rank", value : rank.description)
        model.modifyLastAction(slot: "isThere", value : "yes")
        model.run()
    }

    //model-is-asked-has-no
    mutating func noCard(_ rank: Rank){
        print("Model \(self.id) checked and DOES NOT HAVE any cards of rank \(rank.description)")
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
    mutating func myTurn(_ turnType: String){
        print("It's model \(self.id)'s turn")
        if let modelActionString = model.lastAction(slot: "status") {
            print(modelActionString)
        }
        model.modifyLastAction(slot:"player", value: turnType)
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
        model.modifyLastAction(slot: "retrieved", value: "no")
        model.run()
    }

    //random-pick
    mutating func askRandom(_ randomPlayerID: Int, _ randomRank: Rank){
        print("Model \(self.id) asked randomly player \(randomPlayerID) for a \(randomRank.description)")
        model.modifyLastAction(slot: "rank", value: randomRank.description )
        model.modifyLastAction(slot: "player", value: String(randomPlayerID))
        model.run()

    }

    //cards-not-received
    mutating func answeredFish(_ askedPlayerID: Int, _ seenRank: Rank){
        print("Player \(askedPlayerID) told Model \(self.id) to Go Fish")
        model.modifyLastAction(slot: "rank", value: seenRank.description )
        model.modifyLastAction(slot: "player", value: String(askedPlayerID))
        model.modifyLastAction(slot: "answer", value: "Go-fish")
        model.modifyLastAction(slot: "retrieved", value: "yes")
        model.run()
    }

    //draw-card
    mutating func drawFromPile(_ drawnRank: Rank){
        print("Model \(self.id) draws from pile a card of rank \(drawnRank).")
        model.modifyLastAction(slot: "rank", value: drawnRank.description )
        model.run()
    }

    //cards-received
    mutating func answeredYes(_ askedPlayerID: Int, _ seenRank: Rank){
        print("Player \(askedPlayerID) gave Model \(self.id) cards of rank \(seenRank)")
        model.modifyLastAction(slot: "rank", value: seenRank.description )
        model.modifyLastAction(slot: "player", value: String(askedPlayerID))
        model.modifyLastAction(slot: "answer", value: "yes")
        model.modifyLastAction(slot: "retrieved", value: "yes")
        model.run()
    }

    //check-set
    mutating func checkSet( _ seenRank: Rank, _ numR: Int){
        print("Model \(self.id) is checking if they have a set of \(seenRank)")
        model.modifyLastAction(slot: "rank", value: seenRank.description )
        print(numR)
        let form = NumberFormatter()
        form.numberStyle = .spellOut
        let numberRank = form.string(from: NSNumber(value: numR))!
        print(numberRank)
        model.modifyLastAction(slot: "number", value: numberRank)
        model.run()
    }

    //make-set
    mutating func makeSet( _ seenRank: Rank){
        print("Model \(self.id) is making the set of \(seenRank)")
        model.modifyLastAction(slot: "rank", value: seenRank.description )
        model.run()
    }

    //check-hand
    mutating func getCard(_ rank: Rank){
        print("Model \(self.id) is checking for a memory of rank \(rank)")
        model.modifyLastAction(slot: "rank", value: rank.description)
        model.modifyLastAction(slot: "isThere", value: "yes")
        model.modifyLastAction(slot: "retrieved", value: "no")
        model.run()
    }

    func findPlayerMemory() -> String{
       print("Model \(self.id) tries to remember a player with the same rank.")
       //print(model.actionChunk())
        if let modelActionString = model.lastAction(slot: "retrieved"){
            print(modelActionString)
            if modelActionString == "yes" {
                return model.lastAction(slot: "player")!
            }else{
                return modelActionString
            }
        }
       return "noRetrieved"
   }

}
