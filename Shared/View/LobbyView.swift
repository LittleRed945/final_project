//
//  LobbyView.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/20.
//

import Foundation
import SwiftUI
import NukeUI
import FirebaseAuth
struct LobbyView:View{
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    @State private var can_start=false
    @State private var firstAppear = true
    @ObservedObject  var gameViewModel:GameViewModel
    @State private var is_master=false
    //設定navigation bar的背景顏色
    func configureBackground() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor(uiColor1)
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
    }
    
    
    
    var body:some View{
        ZStack{
            Text("").frame(width: 0, height: 0).fullScreenCover(isPresented: $gameViewModel.currentGameData.is_started, content: {
                GameView(gameViewModel: gameViewModel)
            })
            
            NavigationView{
                VStack{
                    
                    HStack(spacing:20){
                        //players
                        ForEach(Range(0...3)){ i in
                            ZStack{
                                Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/4-30, height:  UIScreen.main.bounds.width/4-30)
                                Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width/4-50, height:  UIScreen.main.bounds.width/4-50)
                            }.overlay{
                                if i<gameViewModel.userDatas.endIndex{
                                    let character=Character(char:gameViewModel.userDatas[i].char, hair: gameViewModel.userDatas[i].hair, shirt: gameViewModel.userDatas[i].shirt, pants: gameViewModel.userDatas[i].pants, shoes: gameViewModel.userDatas[i].shoes)
                                    
                                    CharacterView(character: character,width:UIScreen.main.bounds.width/4-50,height: UIScreen.main.bounds.width/4-50).overlay(Text("\(gameViewModel.userDatas[i].userNickName)").foregroundColor(.black).frame(width:UIScreen.main.bounds.width/4-50).offset(y:-30))
                                        .onAppear{
                                            if is_master,gameViewModel.currentGameData.players_id.endIndex>=2{
                                                can_start=true
                                            }
                                        }
                                }else{
                                    Text("")
                                }
                                
                                
                            }
                        }
                        
                    }
                    //start button
                    
                    Button(action: {
                        gameViewModel.startGame()
                        
                    }, label: {
                        ZStack{
                            Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/2, height:  UIScreen.main.bounds.width/4-50)
                            Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width/2-20, height:  UIScreen.main.bounds.width/4-70)
                        }.overlay(
                            Text("開始")
                        )
                    }).accessibility(hidden: !is_master)
                        .disabled(!can_start)
                    
                    
                }.edgesIgnoringSafeArea(.all)
                    .background(Image("background"))
                
            }.onAppear(perform: {
                
                
                print("DD")
                if firstAppear {
                   
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                        gameViewModel.checkGameChange()
                        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute:{
                        if Auth.auth().currentUser!.uid == gameViewModel.currentGameData.players_id[0]{
                            is_master=true
                        }
                        })
                    })
                    
                    configureBackground()
                    
                }
                
                
               
                firstAppear = false
            }).onDisappear{
                gameViewModel.leaveLobby()
                print("deletelobby")
            }
            
        }
    }
}
