
import Foundation
import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel:GameViewModel
    @State private var is_dead=false
    @State private var firstAppear=true
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    var body: some View{
        ZStack{
            
            if gameViewModel.my_index<gameViewModel.currentGameData.players_role.endIndex,gameViewModel.currentGameData.players_role[gameViewModel.my_index]==""{
                ChooseRoleView(gameViewModel: gameViewModel)
            }else if gameViewModel.currentGameData.allReady{
                
                if !gameViewModel.is_gameover ,!gameViewModel.is_win{
                    GameBoardView(gameViewModel: gameViewModel)
                    
                GameUIView(gameViewModel: gameViewModel)
                
                }else if gameViewModel.is_win{
                    Text("HI").onAppear{
                        gameViewModel.winPlayer.volume=gameViewModel.SFXvolume
                        gameViewModel.winPlayer.playFromStart()
                        DispatchQueue.main.asyncAfter(deadline: .now()+1){
                            gameViewModel.deletedLobby()
                        }
                        
                    }.fullScreenCover(isPresented: $gameViewModel.is_win,content:{WinView(rank_data: gameViewModel.rank_data)})
                }
                else {
                    Text("HI").onAppear{
                        gameViewModel.winPlayer.volume=gameViewModel.SFXvolume
                        gameViewModel.losePlayer.playFromStart()
                    }.fullScreenCover(isPresented: $gameViewModel.is_gameover,content:{GameOverView(rank_data: gameViewModel.rank_data)})
                }
//                if gameViewModel.currentGameData.players_hp[gameViewModel.my_index]<=0{
//                    Button(action: {
//                        is_dead=true
//
//                    }, label:{
//                        Text("離開")
//                    }).fullScreenCover(isPresented: $is_dead,content:{HomeView()})
//                }
            }else{
                ZStack{
                    Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/2, height:  UIScreen.main.bounds.height/2)
                    Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width/2-20, height:  UIScreen.main.bounds.height/2-20)
                }.overlay(
                
                    Text("等待其他玩家")
                )
            }
            
        }.onAppear(perform: {
            
            if firstAppear {
                gameViewModel.generateMap()
                
                gameViewModel.setTheSpawn()
            }
            firstAppear = false
        })
    }
    
}
