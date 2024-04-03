import SwiftUI
// Game Logic class

class Game: ObservableObject {
    var deck = Deck()
    var askPile = AskPile()
    //Using Any for now; I think I will be able to make a protocol later to make it cleaner
    var players: [Any] = []
    var currentPlayerIndex = -1
    var running = false
    var canFish = false

    init(playerIds: [Int]) {
        for id in playerIds {
            if id == 1 {
                players.append(Player(id: id, name: "Player \(id)"))
            } else {
                players.append(GFModel(id: id, name: "Player \(id)"))
        }
    }
    
    func startNew() {
        for index in players.indices {
            players[index].emptyHand()
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
            for index in players.indices {
                if var card = deck.dealCard() {
                    if players[index].id == 1 {
                        card.toggleOpen()
                        card.toggleDrag()
                    }
                    players[index].addCard(card: card)
                    objectWillChange.send()
                }
            }
        }
    }
    
    func dealCard() {
        //let currentPlayer = players[currentPlayerIndex]
        if var card = deck.dealCard() {
            print("dealcard() running!")
            if currentPlayerIndex == 0 {
                card.toggleOpen()
            }
            players[currentPlayerIndex].addCard(card: card)
            objectWillChange.send()
        }
    }
    
    func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex+1) % players.count
        objectWillChange.send()
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
    
    func processAskAction(player: Player) {
        if currentPlayerIndex == 0 && !askPile.cards.isEmpty {
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
