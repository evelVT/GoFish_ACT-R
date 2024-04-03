//
//  ContentView.swift
//  GoFish_ACT-R
//
//  Created by Evelien van Tricht on 16/02/2024.
//

import SwiftUI


// Card View
struct CardView: View {
    @ObservedObject var game: Game
    let card: Card
    @State private var isHovered = false
    var cardScale = CGFloat(3.5)
    @State private var offset = CGSize.zero


    var body: some View {
        ZStack {
            Rectangle()
                .fill(card.open ? Color.white : Color.red)
                .frame(width: 12 * cardScale, height: 18 * cardScale)
                .cornerRadius(1.0)
                .shadow(color: .black.opacity(0.5), radius: 5, x: -5, y: 5)

            VStack {
                HStack {
                    Text(card.open ? card.rank.rawValue.description : "")
                            .font(.system(size: 3 * cardScale))
                            .foregroundColor(card.suit == .hearts || card.suit == .diamonds ? .red : .black)
                }
                HStack {
                    Text(card.open ? card.suit.rawValue.description : "")
                        .font(.system(size: 3 * cardScale))
                        .foregroundColor(card.suit == .hearts || card.suit == .diamonds ? .red : .black)
                }
            }
        }
        .scrollClipDisabled()
        .offset(y: offset.height)
        .offset(x: offset.width)
        .scaleEffect(isHovered && card.drag ? 1.2 : 1)
        .onTapGesture {
            isHovered.toggle()
            print("Mouse Click!")
            if (card.open) {
                game.addAskAction(card: card)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if (card.drag) {
                        offset = gesture.translation
                        print("offset (w, h) = (\(offset.width),\(offset.height))")
                    }
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

// Opponent View
struct OpponentView: View {
    @ObservedObject var game: Game
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color.red.opacity(game.currentPlayerIndex+1 == player.id ? 1.0 : 0.0), lineWidth: 3)
                .background(Color(red: 0.349, green: 0.416, blue: 1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(maxHeight:300)
            VStack {
                HStack {
                    Image(systemName:"faceid")
                    Text("\(player.name)")
                }
                .padding(.vertical)
                HStack(spacing:1) {
                    Image(systemName:"creditcard")
                        .rotationEffect(.degrees(90))
                    Text(" \(player.score)")
                }
                .padding(.vertical)
                HStack(spacing:1) {
                    if !player.hand.isEmpty {
                        ZStack {
                            CardView(game:game, card: Card.init(suit: .hearts, rank: .ace, open: false, drag: false))
                            Text("\(player.hand.count)")
                                .padding(.horizontal)
                        }
                    } else {
                        Text("no cards")
                    }
                }
            }
            .foregroundStyle(.black)
        }

    }
}


// Player View
struct PlayerView: View {
    // Variables
    @ObservedObject var game: Game
    @ObservedObject var player: Player
    var cardScale = CGFloat(3.5)
    var cardWidth = 25

    // Body
    var body: some View {
        ZStack(alignment:.bottom) {
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color.red.opacity(game.currentPlayerIndex+1 == player.id ? 1.0 : 0.0), lineWidth: 3)
                .background(Color(red: 0.349, green: 0.416, blue: 1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(maxHeight:200)
            VStack {
                // hand
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment:.top) {
                        ForEach(player.hand.indices, id: \.self) { index in
                            CardView(game:game, card: player.hand[index])
                                .offset(y: cardOffsetY(for: index))
                                .zIndex(1)
                        }
                    }
                }
                .scrollClipDisabled()

                Spacer()

                HStack {
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
            }
            .padding()
            .frame(maxHeight:200)
        }
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
    @State private var isDropTargeted = false
    @State private var droppedPayload: String = "No text dropped yet"
    @State private var myPayload: String = "I belong in a blue box"

    var body: some View {
        HStack {
            Button(action: pileAction) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color.red)
                        .background(Color.red.opacity(hoverEl1 ? 0.5 : 1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .frame(maxHeight:200)

                    Text(game.running ? (game.canFish ? "Go Fish!" : "Player \(game.currentPlayerIndex+1) \nplaying") : "New Game")
                        .foregroundStyle(.black)
                        .onHover { hover in
                            print("Mouse hover: \(hover)")
                            hoverEl1 = hover
                        }
                }

            }
            .padding()
            Button(action: nextPlayer) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(isDropTargeted ? Color.black : Color.red)
                        .background(Color.red.opacity(hoverEl1 ? 0.5 : 1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .frame(maxHeight:200)

                    Text(game.currentPlayerIndex == 0 ? "Ask Pile" : "X")
                        .foregroundStyle(.black)
                        .onHover { hover in
                            print("Mouse hover: \(hover)")
                            hoverEl1 = hover
                        }
                    VStack {
                        // hand
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment:.top) {
                                ForEach(game.askPile.cards.indices, id: \.self) { index in
                                    CardView(game:game, card: game.askPile.cards[index])
                                        .zIndex(1)
                                }
                            }
                        }
                        .scrollClipDisabled()
                    }
                }
                .padding()
            }
        }
    }
    func pileAction() {
        game.running ? (game.canFish ? game.goFish() : nil ) : game.startNew()
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
        VStack {
            HStack {
                ForEach(game.players.dropFirst().prefix(3)) { player in
                    Button(action: {processAsk(player: player)}) {
                        OpponentView(game:game, player:player)
                    }
                }
            }
            .padding(1.0)
            Spacer()
            HStack {
                DrawpileView(game: game)

            }
            .padding()
            Spacer()
            HStack {
                PlayerView(game:game, player:game.players[0])
            }
        }

    }
    func processAsk(player: Player) {
        game.processAskAction(player: player)
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
