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
        for player in players {
            if player.id != 1{
                let currentPlayerId = currentPlayerIndex + 1
                if player.id == currentPlayerId {
                    player.gfModel?.myTurn()
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
                currentPlayer.addCardPlayer(card: pileCard)
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
        //var card = Card(suit:Card.Suit.hearts, rank:Card.Rank.five, open:false, drag:false)
        var randomRank = Rank.five
        if let random_player_id = ids.randomElement(),
           let randomCard = players[index].hand.randomElement() {
            playerAsked = random_player_id
            if repeatPlayer == 1 && previousRank != "zero"{
                //card = getRankFromStr(rankStr: previousRank)
                //randomRank = card.rank
                randomRank = Rank.from(string: previousRank)
            }else{
                randomRank = randomCard.rank
            }


            //players[index].gfModel?.askRandom(random_player_id, randomRank)
            addAskAction(card: randomCard)
            //processAskActionModel(playerId: random_player_id)
            //processAskAction(player: random_player_id-1)

        }
        let playerAskingId = removeIndex
        for player in players{
            if player.id != 1 && player.id != playerAskingId {
                if player.id == playerAsked {
                    player.gfModel?.playerAskedModel(playerAskingId, randomRank)
                    if players[playerAsked-1].hasCard(ofRank: randomRank) {
                        players[playerAsked-1].gfModel?.hasCard(randomRank)
                        players[index].gfModel?.answeredYes(playerAsked-1, randomRank)
                        let cards = players[playerAsked-1].giveAllCards(ofRank: randomRank)
                        if !askPile.cards.isEmpty {
                            for var card in cards {
                                players[playerAsked-1].removeCard(card: card)
                                card.toggleOpen()
                                askPile.addCard(card: card)
                                objectWillChange.send()
                            }
                            if askPile.cards.count > 1 {
                                let seconds = 1.5
                                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
                                    for _ in self.askPile.cards {

                                        self.players[index].addCardPlayer(card: self.askPile.removeCard())
                                        objectWillChange.send()
                                    }
                                }

                            }
                        }


//                        for card in cards {
//
//                            players[index].addCard(card: card)
//                        }
                        let numR = players[index].giveNoCards(ofRank: randomRank)
                        players[index].gfModel?.checkSet(randomRank, numR)
                        if numR == 4 {
                            players[index].gfModel?.makeSet(randomRank)
                            players[index].makeSets()
                            previousRank = "zero"
                        }else{
                            previousRank = randomRank.description
                        }
                        repeatPlayer = 1

                    } else {
                        players[playerAsked-1].gfModel?.noCard(randomRank)
                        players[index].gfModel?.answeredFish(playerAsked, randomRank)
                        players[index].addCardPlayer(card: askPile.removeCard())
                        objectWillChange.send()
                        //players[index].gfModel?.drawFromPile(randomRank) //HAVE TO CHANGE
                        if let card = deck.dealCard(){
                            players[index].gfModel?.drawFromPile(card.rank)
                            players[index].addCard(card: card)
                            let numR = players[index].giveNoCards(ofRank: card.rank)
                            players[index].gfModel?.checkSet(card.rank, numR)
                            if numR == 4 {
                                players[index].gfModel?.makeSet(card.rank)
                                players[index].makeSets()
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

//     func processAskActionModel(playerId: Int) {
//         let targetPlayer = players[playerId-1]
//         let cards = targetPlayer.giveAllCards(ofRank: askPile.cards[0].rank)
//
//         if !askPile.cards.isEmpty {
//             for var card in cards {
//                 targetPlayer.removeCard(card: card)
//                 card.toggleOpen()
//                 askPile.addCard(card: card)
//                 objectWillChange.send()
//             }
//             if askPile.cards.count > 1  || currentPlayerIndex != 0 {
//                 notifyModels()
//                 let seconds = 1.5
//                 DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
//                     for _ in self.askPile.cards {
//
//                         self.players[self.currentPlayerIndex].addCardPlayer(card: self.askPile.removeCard())
//                         objectWillChange.send()
//                     }
//                 }
//             } else {
//                 players[currentPlayerIndex].addCardPlayer(card: askPile.removeCard())
//                 if currentPlayerIndex == 0 {
//                                         ToggleFish()
//                                     }
//                 objectWillChange.send()
//             }
//         } else {
//             print("ERROR NO CARD SELECTED IN ASKPILE")
//         }
//     }




    func processAskAction(player: Player) {
        if !askPile.cards.isEmpty {
            for index in players.indices {
                let player1 = players[index]

                if player1.id != 1 {
                    if player1.id != player.id {
                        player1.gfModel?.playerAskingRank(1, askPile.cards[0].rank)
                        player1.gfModel?.playerAskedRank(player.id)
                    } else {
                        player1.gfModel?.playerAskedModel(1, askPile.cards[0].rank)
                        print("Player 1 asked \(player1.name)")
                        // Assuming hasCard and noCard are methods of gfModel that mutate its state
                        if player1.hasCard(ofRank: askPile.cards[0].rank) {
                            player1.gfModel?.hasCard(askPile.cards[0].rank)
                            repeatPlayer = 1


                        } else {
                            player1.gfModel?.noCard(askPile.cards[0].rank)
                            repeatPlayer = 0

                        }
                    }
                    players[index] = player1 // Re-assign player1 back to the array to apply the changes
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
                if askPile.cards.count > 1  || currentPlayerIndex != 0{
                    notifyModels()
                    let seconds = 1.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
                        for _ in self.askPile.cards {

                            self.players[self.currentPlayerIndex].addCardPlayer(card: self.askPile.removeCard())
                            objectWillChange.send()
                        }
                    }
                } else {
                    players[currentPlayerIndex].addCardPlayer(card: askPile.removeCard())
                    if currentPlayerIndex == 0 {
                        ToggleFish()
                    }

                    objectWillChange.send()
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
        if repeatPlayer == 1 {
            samePlayer()
        }else{
            nextPlayer()
        }

    }

    private func choosePlayerToAsk(targetedBy askingPlayer: Player) -> Player? {
        return players.first(where: { $0 !== askingPlayer })
    }

    private func handleRequest(from targetPlayer: Player, to askingPlayer: Player, with card: Card) -> Bool {

        // TODO: Implement logic to handle the card request
        // - If targetPlayer has the card, give it to askingPlayer and return true
        // - Else, askingPlayer draws a card from the deck and return false
        return false
    }

    private func checkGameEndConditions() {
        // TODO: Implement logic to check if all players have no cards left
        // - If the game has ended, determine the winner or handle the end of the game
    }
}

