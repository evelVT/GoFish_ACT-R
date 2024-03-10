

class Game {
    var deck = Deck()
    //var players: [Player] = []
    var currentPlayerIndex = 0

    init(playerIds: [Int]) {
        // Initialize players
        for id in playerIds {
            let player = Player(id: id)
            players.append(player)
        }
        deck.initializeDeck()
        deck.shuffle()
        dealInitialCards()
    }

    func dealInitialCards() {
        // Assuming 5 cards per player for the initial deal
        let initialCardsCount = 5

        for i in 0..<initialCardsCount {
            for player in players {
                if let card = deck.dealCard() {
                    player.receiveCard(card: card)
                }
            }
        }
    }

    func playTurn(player: Player) {
        // what card does the player ask for and whom?
        //call function that handles the request handleRequest
        checkGameEndConditions()
    }

    private func choosePlayerToAsk(targetedBy askingPlayer: Player) -> Player? {
        return players.first(where: { $0 !== askingPlayer })
    }

    private func handleRequest(from targetPlayer: Player, to askingPlayer: Player, with card: Card) {
    //if targetPlayer has the card, give it to askingPlayer
    //else, askingPlayer draws a card from the deck
    //maybe return a bool and then have other functions for handling the rest
    }

    private func checkGameEndConditions() {
        //should end when all players have no cards left
    }
}

