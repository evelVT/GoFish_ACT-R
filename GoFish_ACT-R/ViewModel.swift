import Combine
import Foundation


class ViewModel: ObservableObject {
    //@Published private var model = GFModel()
    @Published private var game

    init() {
        let playerIds = [1, 2, 3, 4] // assign unique IDs to each player
        game = Game(playerIds: playerIds)
    }

    func addAskAction(card: Card) {
        game.addAskAction(card: card)
    }

    func playerasked(_ playerAskingID: Int, _ playerAskedID: Int, _ rank: Rank ){
        //Managed to modify this to be called for all models whether they have to listen / answer
        // Evelien maybe you know better how this could fit in the View :)
        model.playerAskedModel(playerAskingID, rank)
//         for i in 0..<3 {
//             if playerAskedID == i {
//                 players[playerAskedID].playerAskedModel(playerAskingID, rank)
//             }
//             else{
//                 players[i].playerAskedRank(playerAskingID, playerAskedID, rank)
//             }
//         }
//     }
    }

}
