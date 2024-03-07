//
//  ContentView.swift
//  GoFish_ACT-R
//
//  Created by Evelien van Tricht on 16/02/2024.
//

import SwiftUI


// Card Model
struct Card: Identifiable, Equatable {
    let id = UUID() //weird
    let rank: Int
    let suit: String
    
    var description: String {
        return " \(rank) of \(suit)"
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
}

// Deck Model
class Deck: ObservableObject {
    @Published private var cards: [Card] //published <- update views when change
    
    init() {
        var deck = [Card]() //weird
        let suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
        for suit in suits {
            for rank in 1...13 {
                deck.append(Card(rank: rank, suit: suit))
            }
        }
        cards = deck.shuffled()
    }
    
    func drawCard() -> Card? {
        print("Drawing from deck")
        if !cards.isEmpty {
            return cards.removeFirst()
        }
        return nil
    }
}

// Player Model
class Player: ObservableObject {
    @Published var hand: [Card] = []
    @Published var score: Int = 0
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    // _ is there so addCard(card) can be used instead of addCard(card: card)
    func addCard(_ card: Card) {
        hand.append(card)
        print("Card \(card) added!")
        print("Now holding \(hand.count) cards")
    }
    
    func removeCard(_ card: Card) {
        if let index = hand.firstIndex(of: card) {
            hand.remove(at: index)
        }
    }
}




// Card View
struct CardView: View {
    let card: Card
    @State private var isHovered = false
    var cardScale = CGFloat(3.5)
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width:12*cardScale, height:18*cardScale)
                .cornerRadius(1)
                .shadow(color: .black, radius:4, x:-5, y:5)
            Image(systemName:"creditcard")
                .foregroundColor(Color.red)
                .rotationEffect(.degrees(90))
                .scaleEffect(cardScale)
            Text("\(card.rank)")
                .padding(.trailing, 5.5*cardScale)
                .padding(.top, 5)
        }
        .scaleEffect(isHovered ? 1.2 : 1)
        .onTapGesture {
            isHovered.toggle()
            print("Mouse click")
        }
    }
}


// Player View
struct PlayerView: View {
    // Variables
    @StateObject var player: Player
    var cardScale = CGFloat(3.5)
    var cardWidth = 25
    
    // Body
    var body: some View {
        VStack(alignment:.center, spacing: 0) {
            // Player's hand
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:-5) {
                        ForEach(Array(player.hand.enumerated()), id: \.offset) { index, card in
                            CardView(card: card)
                                .offset(y: cardOffsetY(for: index))
                        }
                    }
                }
                .scrollClipDisabled()
            }
            .padding(5)
            .frame(height: 100)
            .background(Color.orange)
            
            HStack(alignment:.center) {
                Spacer()
                HStack(spacing:1) {
                    Image(systemName:"creditcard")
                        .rotationEffect(.degrees(90))
                    Text(" \(player.score)")
                }
                Spacer()
                HStack {
                    Image(systemName:"faceid")
                    Text("\(player.name)")
                }
                Spacer()
                Image(systemName:"dog.fill")
                Spacer()
            }
            .padding(8)
            .background(Color.blue)
        }
        .background(Color.white)
        .cornerRadius(10)
    }
    private func cardOffsetX(for index: Int) -> CGFloat {
        let offset = -cardWidth * index
        return CGFloat(offset)
    }
    private func cardOffsetY(for index: Int) -> CGFloat {
        let offset = index
        return CGFloat(offset)
    }
    private func handOffset() -> CGFloat {
        let offset = -(cardWidth * (player.hand.count-1))/2
        return CGFloat(offset)
    }
}

// PileView
struct DrawpileView: View {
    @StateObject var playerturn: Player
    @StateObject var deck: Deck
    @State private var hoverEl: Bool = false

    var body: some View {
        Button(action: dealCards) {
            Text("Deal Cards")
                .foregroundStyle(hoverEl ? .green : .red)
                .onHover { hover in
                    print("Mouse hover: \(hover)")
                    hoverEl = hover
                }
        }
    }
    func dealCards() {
        for _ in 0..<7 {
            if let card = deck.drawCard() {
                playerturn.addCard(card)
            }
        }
    }
}

//NEED GAMEOBJECT TO HOLD GAME VARIABLES


// Game View
struct GameView: View {
    @StateObject private var deck = Deck()
    @StateObject private var player1 = Player(name: "User")
    @StateObject private var opponent1 = Player(name: "Opponent1")
    @StateObject private var opponent2 = Player(name: "Opponent2")
    @StateObject private var opponent3 = Player(name: "Opponent3")
    
    var body: some View {
        ZStack {
            DrawpileView(playerturn: player1, deck: deck)
            
            VStack {
                // top layer
                // Opponent 1
                PlayerView(player: opponent1)
                    .frame(width: 350)
                
                Spacer()
                
                // mid layer
                HStack(alignment:.center, spacing: 0) {
                    // Opponent 2
                    ZStack {
                        PlayerView(player: opponent2)
                            .rotationEffect(.degrees(90))
                            .frame(width: 350)
                            .offset(x: 44)
                    }
                    
                    
                    Button(action: dealCards) {
                        Text("Deal Cards")
                    }
                    
                    // Opponent 3
                    ZStack {
                        PlayerView(player: opponent3)
                            .rotationEffect(.degrees(-90))
                            .frame(width: 350)
                            .offset(x: -44)
                    }
                }
                
                Spacer()
                
                // bot layer
                // Player
                PlayerView(player: player1)
                    .frame(width: 350)
                    .offset(y: 1)
                
            }
        }
        
    }
    func dealCards() {
        for _ in 0..<7 {
            if let card = deck.drawCard() {
                player1.addCard(card)
            }
            if let card = deck.drawCard() {
                opponent1.addCard(card)
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

struct ContentView: View {
    // Variables
    
    // Body
    var body: some View{
        VStack {
            GameView()
        }
    }
}

#Preview {
    ContentView()
}
