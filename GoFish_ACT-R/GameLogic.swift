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
    var selectedPlayer = -1
    var sortedPlayers: [Player] = []

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
                    checkGameEndConditions()
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
            checkGameEndConditions()
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
        var ranksInHand = players[currentPlayerIndex].returnRankList()
        ranksInHand.shuffle()
        var selected_player_id = -1
        var selectedRank = ranksInHand[0]
        var selectedCard = players[currentPlayerIndex].giveOneCard(ofRank: selectedRank)
        if repeatPlayer == 1 && previousRank != "zero"{
           selectedRank = Rank.from(string: previousRank)
           selectedCard = players[currentPlayerIndex].giveOneCard(ofRank: selectedRank)
           players[currentPlayerIndex].gfModel?.getCard(selectedRank)
           let string_player_id = players[currentPlayerIndex].gfModel?.findPlayerMemory()
           if string_player_id != "no"{
                selected_player_id = Int(string_player_id!)!
            }
        }
        if selected_player_id == -1{
            for rank in ranksInHand{
                if previousRank != "zero" && rank == Rank.from(string: previousRank){
                    continue
                }
                selectedCard = players[currentPlayerIndex].giveOneCard(ofRank: selectedRank)
                let string_player_id = players[currentPlayerIndex].gfModel?.findPlayerMemory()
                if string_player_id != "no"{
                    selected_player_id = Int(string_player_id!)!
                    selectedRank = rank
                    break
                }
            }
        }
        
        if selected_player_id == -1{
            players[currentPlayerIndex].gfModel?.goRandom()
            if selected_player_id == ids.randomElement() &&
                selectedCard == players[currentPlayerIndex].hand.randomElement() {
                playerAsked = selected_player_id
                selectedRank = selectedCard.rank
                }
                players[currentPlayerIndex].gfModel?.askRandom(selected_player_id, selectedRank)
        }else{
            
            playerAsked = selected_player_id
            
            
        }
            addAskAction(card: selectedCard)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [self] in
            let playerAskingId = removeIndex
            for player in players{
                if player.id != 1 && player.id != playerAskingId {
                    if player.id == playerAsked {
                        players[playerAsked-1].gfModel?.playerAskedModel(playerAskingId, selectedRank)
                        if players[playerAsked-1].hasCard(ofRank: selectedRank) {
                            players[playerAsked-1].gfModel?.hasCard(selectedRank)
                            players[currentPlayerIndex].gfModel?.answeredYes(playerAsked, selectedRank)
                            let cards = players[playerAsked-1].giveAllCards(ofRank: selectedRank)
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
                                let numR = players[currentPlayerIndex].giveNoCards(ofRank: selectedRank)
                                players[currentPlayerIndex].gfModel?.checkSet(selectedRank, numR)
                                if numR == 4 {
                                    players[currentPlayerIndex].gfModel?.makeSet(selectedRank)
                                    players[currentPlayerIndex].makeSets()
                                    checkGameEndConditions()
                                    previousRank = "zero"
                                }else{
                                    previousRank = selectedRank.description
                                }
                                repeatPlayer = 1
                            }
                            
                        } else {
                            players[playerAsked-1].gfModel?.noCard(selectedRank)
                            players[currentPlayerIndex].gfModel?.answeredFish(playerAsked, selectedRank)
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
                                    checkGameEndConditions()
                                }
                            }
                            repeatPlayer = 0
                            previousRank = "zero"
                            
                        }

                    }
                    else {
                        player.gfModel?.playerAskingRank(playerAskingId, selectedRank)
                        player.gfModel?.playerAskedRank(playerAsked)
                    }
                }
                    
            }
        }
    }
      
    

    func processAskAction(player: Player) {
        selectedPlayer = player.id
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
                                checkGameEndConditions()
                                objectWillChange.send()
                            }
                        }
                    } else {
                        players[0].addCardPlayer(card: askPile.removeCard())
                        checkGameEndConditions()
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
        selectedPlayer = -1
        objectWillChange.send()
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
        var cardsInPlay = 0
        for player in players {
            cardsInPlay += player.hand.count
        }
        if cardsInPlay == 0 {
            if deck.cards.count > 0 {
                print("ERROR: game end while deck not empty!")
            }
            running.toggle()
            sortPlayers()
        }
    }
    
    // Sort players based on score in sortedPlayers array (highest to lowest)
    private func sortPlayers() {
        sortedPlayers = players.sorted { (lhs, rhs) in
            if lhs.score == rhs.score { // <1>
                return lhs.id > rhs.id
            }
            
            return lhs.score > rhs.score // <2>
        }
    }
}

