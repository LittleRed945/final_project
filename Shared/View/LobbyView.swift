//
//  LobbyView.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/20.
//

import Foundation
import SwiftUI
import NukeUI
struct LobbyView:View{
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256) 
    @State private var firstAppear = true
    @ObservedObject  var gameViewModel:GameViewModel
    //設定navigation bar的背景顏色
    func configureBackground() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor(uiColor1)
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
    }
    
    
    
    var body:some View{
        NavigationView{
            VStack{
                
                HStack(spacing:20){
                    //player1
                    ZStack{
                        Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/4-30, height:  UIScreen.main.bounds.width/4-30)
                        Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width/4-50, height:  UIScreen.main.bounds.width/4-50)
                    }.overlay{
                        if gameViewModel.currentGameData.player1_id==""{
                            Text("")
                        }else{
                            let character=Character(char:gameViewModel.userDatas[0].char, hair: gameViewModel.userDatas[0].hair, shirt: gameViewModel.userDatas[0].shirt, pants: gameViewModel.userDatas[0].pants, shoes: gameViewModel.userDatas[0].shoes)
                            VStack{
                                Text("\(gameViewModel.userDatas[0].userNickName)").foregroundColor(.black).frame(width:UIScreen.main.bounds.width/4-50)
                            CharacterView(character: character,width:UIScreen.main.bounds.width/4-50,height: UIScreen.main.bounds.width/4-50)
                            }
                        }
                    }
                    
                    
                }
                
            }.edgesIgnoringSafeArea(.all)
                .background(Image("background"))
                            
        }.onAppear(perform: {
            
            if firstAppear {
                gameViewModel.checkGameChange()
                configureBackground()
            }
            firstAppear = false
        }).onDisappear{
            gameViewModel.deleteLobby()
            print("deletelobby")
        }
        
    }
}
