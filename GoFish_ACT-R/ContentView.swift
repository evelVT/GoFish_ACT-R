//
//  ContentView.swift
//  GoFish_ACT-R
//
//  Created by Evelien van Tricht on 16/02/2024.
//

import SwiftUI


// Card Model
//struct Card: Identifiable, Equatable {
//    let id = UUID() //weird
//    let rank: Int
//    let suit: String
//    
//    var description: String {
//        return " \(rank) of \(suit)"
//    }
//    
//    static func ==(lhs: Card, rhs: Card) -> Bool {
//        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
//    }
//}
//
//// Deck Model
//class Deck: ObservableObject {
//    @Published private var cards: [Card] //published <- update views when change
//    
//    init() {
//        var deck = [Card]() //weird
//        let suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
//        for suit in suits {
//            for rank in 1...13 {
//                deck.append(Card(rank: rank, suit: suit))
//            }
//        }
//        cards = deck.shuffled()
//    }
//    
//    func drawCard() -> Card? {
//        print("Drawing from deck")
//        if !cards.isEmpty {
//            return cards.removeFirst()
//        }
//        return nil
//    }
//}
//
//// Player Model
//class Player: ObservableObject {
//    @Published var hand: [Card] = []
//    @Published var score: Int = 0
//    
//    let name: String
//    
//    init(name: String) {
//        self.name = name
//    }
//    
//    // _ is there so addCard(card) can be used instead of addCard(card: card)
//    func addCard(_ card: Card) {
//        hand.append(card)
//        print("Card \(card) added!")
//        print("Now holding \(hand.count) cards")
//    }
//    
//    func removeCard(_ card: Card) {
//        if let index = hand.firstIndex(of: card) {
//            hand.remove(at: index)
//        }
//    }
//}




//// Card View
//struct CardView: View {
//    let card: Card
//    @State private var isHovered = false
//    var cardScale = CGFloat(3.5)
//    @State private var offset = CGSize.zero
//    
//    
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(Color.white)
//                .frame(width:12*cardScale, height:18*cardScale)
//                .cornerRadius(1)
//                .shadow(color: .black, radius:4, x:-5, y:5)
//            Image(systemName:"creditcard")
//                .foregroundColor(Color.red)
//                .rotationEffect(.degrees(90))
//                .scaleEffect(cardScale)
//            Text("\(card.rank)")
//                .padding(.trailing, 5.5*cardScale)
//                .padding(.top, 5)
//        }
//        .scrollClipDisabled()
//        .offset(y: offset.height)
//        .offset(x: offset.width)
//        .scaleEffect(isHovered ? 1.2 : 1)
//        .onTapGesture {
//            isHovered.toggle()
//            print("Mouse click")
//        }
//        .gesture(
//            DragGesture()
//            .onChanged { gesture in
//                offset = gesture.translation
//                print("offset: \(offset.height)")
//            }
//            .onEnded{ _ in
//                if abs(offset.width) > 100 {
//                    //add the card to drawpile
//                    offset = .zero //temp
//                } else {
//                    offset = .zero
//                }
//            }
//        )
//    }
//}

// Card View
struct CardView: View {
    let card: Card
    @State private var isHovered = false
    var cardScale = CGFloat(3.5)
    @State private var offset = CGSize.zero
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 12 * cardScale, height: 18 * cardScale)
                .cornerRadius(1.0)
                .shadow(color: .black, radius: 4, x: -5, y: 5)
            
            VStack {
                HStack {
                    Text(card.rank.rawValue.description)
                        .font(.system(size: 3 * cardScale))
                        .foregroundColor(card.suit == .hearts || card.suit == .diamonds ? .red : .black)
                }
                HStack {
                    Text(card.suit.rawValue.description)
                        .font(.system(size: 3 * cardScale))
                        .foregroundColor(card.suit == .hearts || card.suit == .diamonds ? .red : .black)
                }
            }
        }
        .scrollClipDisabled()
        .offset(y: offset.height)
        .offset(x: offset.width)
        .scaleEffect(isHovered ? 1.2 : 1)
        .onTapGesture {
            isHovered.toggle()
            print("Mouse Click!")
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    print("offset (w, h) = (\(offset.width),\(offset.height))")
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        // Add the card to the draw pile
                        offset = .zero //Temporary
                    } else {
                        offset = .zero
                    }
                }
        )
    }
}



// Player View
struct PlayerView: View {
    // Variables
    @ObservedObject var player: Player
    var cardScale = CGFloat(3.5)
    var cardWidth = 25
    
    // Body
    var body: some View {
        VStack(alignment:.center, spacing: 0) {
            // Player's hand
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:-5) {
                        ForEach(player.hand.indices, id: \.self) { index in
                            CardView(card: player.hand[index])
                                .offset(y: cardOffsetY(for: index))
                                .zIndex(1)
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
    @ObservedObject var game: Game
    @State private var hoverEl1: Bool = false
    @State private var hoverEl2: Bool = false

    var body: some View {
        VStack {
            Button(action: dealCards) {
                Text("Deal Card")
                    .foregroundStyle(hoverEl1 ? .green : .red)
                    .onHover { hover in
                        print("Mouse hover: \(hover)")
                        hoverEl1 = hover
                    }
            }
            .padding()
            
            Button(action: nextPlayer) {
                Text("Next Player")
                    .foregroundStyle(hoverEl2 ? .green : .red)
                    .onHover { hover in
                        print("Mouse hover: \(hover)")
                        hoverEl2 = hover
                    }
            }
            .padding()
        }
        
    }
    func dealCards() {
        print("button pressed!")
        game.dealCard()
    }
    func nextPlayer() {
        print("next player!")
        game.nextPlayer()
    }
}

//NEED GAMEOBJECT TO HOLD GAME VARIABLES


// Game View
struct GameView: View {
    @StateObject private var game: Game
    
    init() {
        let playerIds = [1, 2, 3, 4] // assign unique IDs to each player
        _game = StateObject(wrappedValue: Game(playerIds: playerIds))
    }
    
    
    var body: some View {
        ZStack {
            DrawpileView(game: game)
            
            VStack {
                // top layer
                // Opponent 2
                PlayerView(player: game.players[2])
                    .frame(width: 350)
                
                Spacer()
                
                // mid layer
                HStack(alignment:.center, spacing: 0) {
                    // Opponent 1
                    ZStack {
                        PlayerView(player: game.players[1])
                            .rotationEffect(.degrees(90))
                            .frame(width: 350)
                            .offset(x: 44)
                    }
                    
                    
                    Button(action: startGame) {
                        Text("Start Game")
                    }
                    
                    // Opponent 3
                    ZStack {
                        PlayerView(player: game.players[3])
                            .rotationEffect(.degrees(-90))
                            .frame(width: 350)
                            .offset(x: -44)
                    }
                }
                
                Spacer()
                
                // bot layer
                // Player
                PlayerView(player: game.players[0])
                    .frame(width: 350)
                    .offset(y: 1)
                
            }
        }
        
    }
    func startGame() {
        game.playTurn()
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
