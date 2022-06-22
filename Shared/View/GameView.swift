
import Foundation
import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel:GameViewModel
    @State private var is_dead=false
    var body: some View{
        ZStack{
            GameView(gameViewModel: gameViewModel)
            GameUIView(gameViewModel: gameViewModel)
            if gameViewModel.currentGameData.players_role[gameViewModel.my_index]==""{
                ChooseRoleView(gameViewModel: gameViewModel)
            }
            if gameViewModel.currentGameData.players_hp[gameViewModel.my_index]<=0{
                Button(action: {
                    is_dead=true
                    gameViewModel.leaveLobby()
                }, label:{
                    Text("離開")
                }).fullScreenCover(isPresented: $is_dead,content:{HomeView()})
            }
        }
    }
    
}
