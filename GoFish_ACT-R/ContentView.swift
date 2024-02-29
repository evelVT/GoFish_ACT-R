//
//  ContentView.swift
//  GoFish_ACT-R
//
//  Created by Evelien van Tricht on 16/02/2024.
//

import SwiftUI

struct Card: View {
    @State var rank: String
    @State var symbol: String
    @State var image: Image
    
    var body: some View {
        ZStack {
            image
                .rotationEffect(.degrees(90))
                .scaleEffect(2)
                .frame(height:36)
                .background(Color.white)
                Text("\(self.rank)")
                .padding(.trailing, 11.0)
                .padding(.top, 5)
        }
    }
}

struct HandView: View {
    @State var cards: [Card]
    var cardWidth = 25
    
    var body: some View {
        ZStack {
            ForEach(cards.indices, id: \.self) { index in
                cards[index]
                    .frame(height:50, alignment: .center)
                    .offset(x: cardOffsetX(for: index),
                            y: cardOffsetY(for: index))
            }
        }
        .offset(x: handOffset())
    }
    
    private func cardOffsetX(for index: Int) -> CGFloat {
        let offset = cardWidth * index
        return CGFloat(offset)
    }
    
    private func cardOffsetY(for index: Int) -> CGFloat {
        let offset = index
        return CGFloat(offset)
    }
    
    private func handOffset() -> CGFloat {
        let offset = -(cardWidth * (cards.count-1))/2
        return CGFloat(offset)
    }
    
    func cardCount(cards: [Card]) -> CGFloat {
        return CGFloat(cards.count)
    }
    
    func addCard(card: Card) {
        cards.append(card)
    }
    
    func removeCard(rank: String) -> [Card] {
        cards = cards.filter{$0.rank != rank}
        return cards
    }
}


struct PlayerView: View {
    @State var name: String
    @State var hand: HandView
    @State var score: String
    @State var icon: Image //Image(systemName: "faceid")
    @State var fishIcon: Bool //Image(systemName: "dog.fill")
    
    var body: some View {
        VStack(alignment:.center, spacing: 0) {
            // Player's hand
            HStack(spacing:0) {
                Spacer()
                hand
                Spacer()
            }
            .frame(height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).border(Color.red)
            .padding(5.0)
            .background(Color.orange)
            .alignmentGuide(HorizontalAlignment.center, computeValue:{d in d[HorizontalAlignment.center]})
            
            // Player Indicator and Fish
            HStack(alignment: .center) {
                Spacer()
                HStack(spacing:1) {
                    Image(systemName:"creditcard")
                        .rotationEffect(.degrees(90))
                    Text("\(score)")
                }
                Spacer()
                VStack {
                    icon
                    Text("\(name)")
                        
                }
                Spacer()
                if fishIcon {
                    Image(systemName: "dog.fill")
                }
                Spacer()
            }
            .padding(.bottom)
            .padding(.top, 5.0)
            .background(Color.blue)
            .frame(alignment: .center).border(Color.blue)
        }
        .background(Color.white)
        .frame(width: 300, alignment: .center).border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
    }
}


struct ContentView: View {
    @State var player1 = PlayerView(name: "you",
                                    hand: HandView(cards: [Card(rank: "2",
                                                                symbol: "hearts",
                                                                image: Image(systemName:"creditcard")),
                                                           Card(rank: "2",
                                                               symbol: "clubs",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "4",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "6",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "K",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard"))]),
                                    score: "0",
                                    icon: Image(systemName: "faceid"),
                                    fishIcon: true)
    @State var player2 = PlayerView(name: "Opponent1",
                                    hand: HandView(cards: [Card(rank: "2",
                                                                symbol: "hearts",
                                                                image: Image(systemName:"creditcard")),
                                                           Card(rank: "2",
                                                               symbol: "clubs",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "4",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "6",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "K",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard"))]),
                                    score: "0",
                                    icon: Image(systemName: "faceid"),
                                    fishIcon: true)
    @State var player3 = PlayerView(name: "Opponent2",
                                    hand: HandView(cards: [Card(rank: "2",
                                                                symbol: "hearts",
                                                                image: Image(systemName:"creditcard")),
                                                           Card(rank: "2",
                                                               symbol: "clubs",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "4",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "6",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "K",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard"))]),
                                    score: "0",
                                    icon: Image(systemName: "faceid"),
                                    fishIcon: true)
    @State var player4 = PlayerView(name: "Opponent3",
                                    hand: HandView(cards: [Card(rank: "2",
                                                                symbol: "hearts",
                                                                image: Image(systemName:"creditcard")),
                                                           Card(rank: "2",
                                                               symbol: "clubs",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "4",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "6",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard")),
                                                           Card(rank: "K",
                                                               symbol: "hearts",
                                                               image: Image(systemName:"creditcard"))]),
                                    score: "0",
                                    icon: Image(systemName: "faceid"),
                                    fishIcon: true)
    
    
    
    var body: some View {
        ZStack {
            // Card Pile
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Card Pile")
                        .padding()
                        .frame(alignment: .center).border(Color.red)
                    Spacer()
                }
                Spacer()
            }
            .background(Color.green)
            .frame(alignment: .center).border(Color.green)
            VStack {
                // Opponent 1
                player2
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/250.0/*@END_MENU_TOKEN@*/)
                    .rotationEffect(.degrees(180))
                
                Spacer()
                
                HStack {
                    // Opponent 2
                    player3
                        .frame(maxHeight: /*@START_MENU_TOKEN@*/250.0/*@END_MENU_TOKEN@*/)
                        .rotationEffect(.degrees(90))
                    Spacer()
                    // Opponent 3
                    player4
                        .frame(maxHeight: 250.0)
                        .rotationEffect(.degrees(-90))
                }
                
                Spacer()
                // Player
                player1
                    .frame(maxWidth: 250.0)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
