
import Foundation
import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel:GameViewModel
    @State private var is_dead=false
    @State private var firstAppear=true
    var body: some View{
        ZStack{
            Text("").onAppear{
                print("DER")
            }
            if gameViewModel.currentGameData.players_role[gameViewModel.my_index]==""{
                ChooseRoleView(gameViewModel: gameViewModel)
            }else{
            GameBoardView(gameViewModel: gameViewModel)
            Text("").onAppear{
                print("DER2")
            }
            GameUIView(gameViewModel: gameViewModel)
            Text("").onAppear{
                print("DER3")
            }
            }
            if gameViewModel.currentGameData.players_hp[gameViewModel.my_index]<=0{
                Button(action: {
                    is_dead=true
                    gameViewModel.leaveLobby()
                }, label:{
                    Text("離開")
                }).fullScreenCover(isPresented: $is_dead,content:{HomeView()})
            }
        }.onAppear(perform: {
            
            
            print(gameViewModel.currentGameData)
            if firstAppear {
                gameViewModel.checkGameChange()
                
            }
            firstAppear = false
        })
    }
    
}
