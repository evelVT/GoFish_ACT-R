import SwiftUI
// Game Logic class

class Game: ObservableObject {
    var deck = Deck()
    var askPile = AskPile()
    var players: [Player] = []
    var currentPlayerIndex = -1
    var running = false
    var canFish = false

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
        notifyModels()
    }

    func notifyModels() {
            for player in players {
                if player.id != 1{
                    let currentPlayerId = currentPlayerIndex + 1
                    if player.id == currentPlayerId {
                        player.gfModel?.myTurn()
                        print("Model \(player.id) is notified that it is their turn")
                        player.gfModel?.myTurn()
                        player.gfModel?.goRandom()
                        modelAsks(currentPlayerIndex)
                        // Additional strategy calls could be placed here if necessary
                    } else {
                        player.gfModel?.notMyTurn()
                    }
                }
            }
        }

    func handleModelTurn() {
        //I was thinking to have this function for more complex behaviour when it comes to the model's turn
        let currentPlayer = players[currentPlayerIndex]
        for card in currentPlayer.hand {
            currentPlayer.gfModel?.tryRemember(card.rank)
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
                    player.addCard(card: card)
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
            currentPlayer.addCard(card: card)
            objectWillChange.send()
        }
    }

    func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex+1) % players.count
        objectWillChange.send()
        notifyModels()

    }

    func addAskAction(card: Card) {
        let currentPlayer = players[currentPlayerIndex]
        if (currentPlayerIndex == 0) {
            if !askPile.cards.isEmpty {
                currentPlayer.addCard(card: askPile.removeCard())
            }
            currentPlayer.removeCard(card: card)
            askPile.addCard(card: card)
            objectWillChange.send()
        }
    }


    func modelAsks(_ index: Int) {
        var ids = [1, 2, 3, 4] // List of player IDs

        let removeIndex = currentPlayerIndex + 1 // Calculate index to remove
        if removeIndex < ids.count {
            ids.remove(at: removeIndex)
        }

        if let random_player_id = ids.randomElement(),
           let randomCard = players[index].hand.randomElement() {
            let randomRank = randomCard.rank
            // Call the askRandom method with safely unwrapped ID and rank
            players[index].gfModel?.askRandom(random_player_id, randomRank)
        }
    }


    func processAskAction(player: Player) {
        if currentPlayerIndex == 0 && !askPile.cards.isEmpty {
            for index in players.indices {
                var player1 = players[index]

                if player1.id != 1 {
                    if player1.id != player.id {
                        player1.gfModel?.playerAskedRank(1, player.id, askPile.cards[0].rank)
                    } else {
                        player1.gfModel?.playerAskedModel(1, askPile.cards[0].rank)
                        // Assuming hasCard and noCard are methods of gfModel that mutate its state
                        if player1.hasCard(ofRank: askPile.cards[0].rank) {
                            player1.gfModel?.hasCard(askPile.cards[0].rank)
                        } else {
                            player1.gfModel?.noCard(askPile.cards[0].rank)
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
                if askPile.cards.count > 1 {
                    let seconds = 1.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
                        for _ in self.askPile.cards {
                            self.players[self.currentPlayerIndex].addCard(card: self.askPile.removeCard())
                            objectWillChange.send()
                        }
                    }
                } else {
                    players[currentPlayerIndex].addCard(card: askPile.removeCard())
                    ToggleFish()
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
        nextPlayer()
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

