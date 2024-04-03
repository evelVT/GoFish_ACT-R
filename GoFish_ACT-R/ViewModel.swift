import Combine
import Foundation


class ViewModel: ObservableObject {
    @Published private var players: [GFModel] = Array(repeating: GFModel(), count: 3)


    func playerasked(_ playerAskingID: Int, _ playerAskedID: Int, _ rank: Rank ){
        //Managed to modify this to be called for all models whether they have to listen / answer
        // Evelien maybe you know better how this could fit in the View :)
        for i in 0..<3 {
            if playerAskedID == i {
                players[playerAskedID].playerAskedModel(playerAskingID, rank)
            }
            else{
                players[i].playerAskedRank(playerAskingID, playerAskedID, rank)
            }
        }
    }

}
