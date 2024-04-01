class ViewModel: ObservableObject {
    @Published private var model = GFModel()


    func playerasked(_ playerAskingID: Int, _ playerAskedID: Int, _ rank: Rank ){
        // idk how exactly it has to be modified. This function should be called somewhere
        // in the View I believe and then I can call model.askedRank. 
        // Also, we can maybe have this for anyone asking anyone and then see where we send information and how
        // since for most requests a model will have to answer the request
        // while the other models / player just 'listen'
        model.playerAskedRank(playerAskingID, playerAskedID, rank)
        //this should only be called for certain models not all depending on who's asked
    }

}