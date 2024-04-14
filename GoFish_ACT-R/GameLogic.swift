import SwiftUI
// Game Logic class

class Game: ObservableObject {
    var deck = Deck()
    var askPile = AskPile()
    var players: [Player] = []
    var currentPlayerIndex = -1
    var running = false
    var canFish = false
    var repeatPlayer = 0
    var previousRank = ""

    init(playerIds: [Int]) {
        // Initialize players
        for id in playerIds {
            let player = Player(id: id, name: "Player \(id)")
            players.append(player)
        }
    }

    func startNew() {
        for player in players {
            player.emptyHand()
        }
        running.toggle()
        deck.initializeDeck()
        deck.shuffle()
        dealInitialCards()
        currentPlayerIndex = Int.random(in: 0..<players.count)
        repeatPlayer = 0
        previousRank = "zero"
        notifyModels()
    }


    func notifyModels() {
        var turnType = "model_turn"
        if repeatPlayer == 1{
            turnType = "model_turn_again"
        }
        for player in players {
            if player.id != 1{
                let currentPlayerId = currentPlayerIndex + 1
                if player.id == currentPlayerId {
                    player.gfModel?.myTurn(turnType)
                    print("Model \(player.id) is notified that it is their turn")
                    //player.gfModel?.goRandom()
                    //modelAsks(currentPlayerIndex)
                    // Additional strategy calls could be placed here if necessary
                } else {
                    player.gfModel?.notMyTurn()
                    //print("...")
                }
            }
        }
        if currentPlayerIndex != 0{
            players[currentPlayerIndex].gfModel?.goRandom()
            modelAsks(currentPlayerIndex)
        }
        
    }


    func handleModelTurn() {
        let currentPlayer = players[currentPlayerIndex]
        let rankList = currentPlayer.returnRankList()
        for rank in rankList {
            currentPlayer.gfModel?.getCard(rank)
        }
    }


    func dealInitialCards() {
        // Assuming 5 cards per player for the initial deal
        let initialCardsCount = 5

        for _ in 0..<initialCardsCount {
            for player in players {
                if var card = deck.dealCard() {
                    if player.id == 1 {
                        card.toggleOpen()
                        //card.toggleDrag()
                    }
                    player.addCardPlayer(card: card)
                    objectWillChange.send()
                }
            }
        }
    }

    func dealCard() {
        let currentPlayer = players[currentPlayerIndex]
        if var card = deck.dealCard() {
            print("dealcard() running!")
            if currentPlayerIndex == 0 {
                card.toggleOpen()
            }
            currentPlayer.addCardPlayer(card: card)
            objectWillChange.send()
        }
    }

    func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex+1) % players.count
        objectWillChange.send()
        print("Current player index: \(currentPlayerIndex)")
        notifyModels()

    }
    func samePlayer() {
       // currentPlayerIndex = (currentPlayerIndex+1) % players.count
       // objectWillChange.send()
        print("Current player index: \(currentPlayerIndex)")
        notifyModels()

    }

    func addAskAction(card: Card) {
            let currentPlayer = players[currentPlayerIndex]
            
            if !askPile.cards.isEmpty {
                var pileCard = askPile.removeCard()
                //if user, then card open otherwise card close
                if currentPlayer.id == 1 {
                    pileCard.toggleOpen()
                } else {
                    pileCard.toggleClose()
                }
                currentPlayer.addCard(card: pileCard)
            }
            currentPlayer.removeCard(card: card)
            var pileCard = card
            pileCard.toggleOpen()
            askPile.addCard(card: pileCard)
            objectWillChange.send()
        }


    func modelAsks(_ index: Int) {
       
        var ids = [1, 2, 3, 4]
        let removeIndex = currentPlayerIndex + 1
        if removeIndex < ids.count + 1 {
            ids.remove(at: removeIndex-1)
            ids.remove(at:0) //ADDED FOR DEBUGGING, REMOVE LATER
        }
        var playerAsked = -1
        var randomRank = Rank.five
        if let random_player_id = ids.randomElement(),
           var randomCard = players[currentPlayerIndex].hand.randomElement() {
            playerAsked = random_player_id
            if repeatPlayer == 1 && previousRank != "zero"{
                randomRank = Rank.from(string: previousRank)
                randomCard = players[currentPlayerIndex].giveOneCard(ofRank: randomRank)
            }else{
                randomRank = randomCard.rank
            }
            
            
            players[currentPlayerIndex].gfModel?.askRandom(random_player_id, randomRank)
            addAskAction(card: randomCard)
            
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [self] in
            let playerAskingId = removeIndex
            for player in players{
                if player.id != 1 && player.id != playerAskingId {
                    if player.id == playerAsked {
                        players[playerAsked-1].gfModel?.playerAskedModel(playerAskingId, randomRank)
                        if players[playerAsked-1].hasCard(ofRank: randomRank) {
                            players[playerAsked-1].gfModel?.hasCard(randomRank)
                            players[currentPlayerIndex].gfModel?.answeredYes(playerAsked, randomRank)
                            let cards = players[playerAsked-1].giveAllCards(ofRank: randomRank)
                            if !askPile.cards.isEmpty {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    [self] in
                                    for var card in cards {
                                        players[playerAsked-1].removeCard(card: card)
                                        card.toggleOpen()
                                        askPile.addCard(card: card)
                                        objectWillChange.send()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                                                for _ in askPile.cards {
                                                    players[currentPlayerIndex].addCard(card: askPile.removeCard())
                                                    objectWillChange.send()
                                                }
                                            }
                                    }
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
                                let numR = players[currentPlayerIndex].giveNoCards(ofRank: randomRank)
                                players[currentPlayerIndex].gfModel?.checkSet(randomRank, numR)
                                if numR == 4 {
                                    players[currentPlayerIndex].gfModel?.makeSet(randomRank)
                                    players[currentPlayerIndex].makeSets()
                                    previousRank = "zero"
                                }else{
                                    previousRank = randomRank.description
                                }
                                repeatPlayer = 1
                            }
                            
                        } else {
                            players[playerAsked-1].gfModel?.noCard(randomRank)
                            players[currentPlayerIndex].gfModel?.answeredFish(playerAsked, randomRank)
                            players[currentPlayerIndex].addCard(card: askPile.removeCard())
                            objectWillChange.send()
                            if let card = deck.dealCard(){
                                players[currentPlayerIndex].gfModel?.drawFromPile(card.rank)
                                players[currentPlayerIndex].addCard(card: card)
                                let numR = players[currentPlayerIndex].giveNoCards(ofRank: card.rank)
                                players[currentPlayerIndex].gfModel?.checkSet(card.rank, numR)
                                if numR == 4 {
                                    players[currentPlayerIndex].gfModel?.makeSet(card.rank)
                                    players[currentPlayerIndex].makeSets()
                                }
                            }
                            repeatPlayer = 0
                            previousRank = "zero"
                            
                        }

                    }
                    else {
                        player.gfModel?.playerAskingRank(playerAskingId, randomRank)
                        player.gfModel?.playerAskedRank(playerAsked)
                    }
                }
                    
            }
        }
    }
      
    

    func processAskAction(player: Player) {
        if !askPile.cards.isEmpty {
            for index in players.indices {
                if players[index].id != 1 {
                    if players[index].id != player.id {
                        players[index].gfModel?.playerAskingRank(1, askPile.cards[0].rank)
                        players[index].gfModel?.playerAskedRank(player.id)
                    } else {
                        players[index].gfModel?.playerAskedModel(1, askPile.cards[0].rank)
                        print("Player 1 asked \(players[index].name)")
                        if players[index].hasCard(ofRank: askPile.cards[0].rank) {
                            players[index].gfModel?.hasCard(askPile.cards[0].rank)
                            repeatPlayer = 1
                        } else {
                            players[index].gfModel?.noCard(askPile.cards[0].rank)
                            repeatPlayer = 0
                        }
                    }
                }
            }

            let cards = player.giveAllCards(ofRank: askPile.cards[0].rank)

            if !askPile.cards.isEmpty {
                for var card in cards {
                    player.removeCard(card: card)
                    card.toggleOpen()
                    askPile.addCard(card: card)
                    objectWillChange.send()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    if askPile.cards.count > 1{
                        notifyModels()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                            for _ in askPile.cards {
                                players[0].addCardPlayer(card: askPile.removeCard())
                                objectWillChange.send()
                            }
                        }
                    } else {
                        players[0].addCardPlayer(card: askPile.removeCard())
                        if currentPlayerIndex == 0 {
                            ToggleFish()
                        }
                        objectWillChange.send()
                    }
                }
            } else {
                print("ERROR NO CARD SELECTED IN ASKPILE")
            }
        }
    }
    
    func ToggleFish() {
        canFish.toggle()
    }
    
    func goFish() {
        dealCard()
        ToggleFish()
        nextPlayer()
    }
    
    func changeTurn(){
        if repeatPlayer == 1 {
            print("same player!")
            samePlayer()
        }else{
            print("next player!")
            nextPlayer()
        }
    }

    private func choosePlayerToAsk(targetedBy askingPlayer: Player) -> Player? {
        return players.first(where: { $0 !== askingPlayer })
    }

//    private func handleRequest(from targetPlayer: Player, to askingPlayer: Player, with card: Card) -> Bool {
//        
//        // TODO: Implement logic to handle the card request
//        // - If targetPlayer has the card, give it to askingPlayer and return true
//        // - Else, askingPlayer draws a card from the deck and return false
//        return false
//    }

    private func checkGameEndConditions() {
        // TODO: Implement logic to check if all players have no cards left
        // - If the game has ended, determine the winner or handle the end of the game
    }
}

