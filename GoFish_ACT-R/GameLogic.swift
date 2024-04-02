import SwiftUI
import Foundation

// Game Logic class

class Game: ObservableObject {
    var deck = Deck()
    var players: [GFModel] = []
    var currentPlayerIndex = 1 //we start at 1 ig
    var running = false

    init(playerIds: [Int]) {
        // Initialize players. I was thinking that player 1 could just be the player and 2-3 the models
        if id == 1{
            continue
        }
        for id in playerIds {
            let player = GFModel(id: id, name: "Player \(id)")
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
    }

    func dealInitialCards() {
        // Assuming 5 cards per player for the initial deal
        let initialCardsCount = 5

        for _ in 0..<initialCardsCount {
            for player in players {
                if var card = deck.dealCard() {
                    if player.id == 1 {
                        card.toggleOpen()
                        card.toggleDrag()
                    }
                    player.receiveCard(card: card)
                    objectWillChange.send()
                }
            }
        }
    }

    func dealCard() {
        let currentplayer = players[currentPlayerIndex]
        if var card = deck.dealCard() {
            print("dealcard() running!")
            if currentPlayerIndex == 0 {
                card.toggleOpen()
            }
            currentplayer.receiveCard(card: card)
            objectWillChange.send()
        }
    }

    func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        objectWillChange.send()
    }

    func playTurn() {
        // what card does the player ask for and whom?

        // TODO: Implement logic for the current player's turn
        // - Choose a player to ask for a card
        // - Handle the card request (use handleRequest)
        let currentPlayer = players[currentPlayerIndex]

        checkGameEndConditions()
        nextPlayer()
    }

    private func choosePlayerToAsk(targetedBy askingPlayer: Player) -> Player? {
        return players.first(where: { $0 !== askingPlayer })
    }


    private func handleRequest(from targetPlayer: Player, to askingPlayer: Player, with card: Card) -> Bool {
    //if targetPlayer has the card, give it to askingPlayer
    //else, askingPlayer draws a card from the deck
    //maybe return a bool and then have other functions for handling the rest
        if targetPlayer.hasCard(ofRank: card.rank){
            let wonCards = targetPlayer.respondToCardRequest(card: card)
            for card in wonCards{
                askingPlayer.receiveCard(card: card)
            }
            return true

        }
        else{
            let card = deck.dealCard()
            askingPlayer.receiveCard(card:card)
            return false
        }
    }

    private func checkGameEndConditions() {
        // TODO: Implement logic to check if all players have no cards left
        // - If the game has ended, determine the winner or handle the end of the game
    }
}

