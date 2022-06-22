//
//  LobbyView.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/20.
//

import Foundation
import SwiftUI

struct HomeView:View{
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    @StateObject var gameViewModel=GameViewModel()
    @State private var isCreateLobby = false
    //設定navigation bar的背景顏色
    func configureBackground() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor(uiColor1)
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
    }
    
    init() {
        configureBackground()
    }
    var body:some View{
        NavigationView{
            VStack{
                
                HStack(spacing:0){
                    Spacer().frame(width:20)
                    ZStack{
                        Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/2-30, height:  UIScreen.main.bounds.height-100)
                    }.overlay{
                        ZStack{
                            Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width/2-50, height:  UIScreen.main.bounds.height-120)
                            NavigationLink(destination:LobbyView(gameViewModel:gameViewModel),isActive: $isCreateLobby, label:{
                                Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width)/2-70 , height:35 ).overlay(){
                                    Text("創建房間").foregroundColor(.black).font(.system( size: 30))
                                }
                            }).onChange(of: isCreateLobby){(new_value) in
                                if new_value{
                                    
                                    gameViewModel.createLobby()
                                }
                                
                            }
                        }
                    }
                    Spacer().frame(width:20)
                    ZStack{
                        Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/2-30, height:  UIScreen.main.bounds.height-100)
                    }
                    Spacer().frame(width:20)
                }
                
            }.edgesIgnoringSafeArea(.all)
                .background(Image("background"))
                .toolbar{
                    ToolbarItem(placement: .cancellationAction) {
                        NavigationLink{UserView()} label:{
                            Image(systemName: "person.fill").foregroundColor(uiColor2)
                        }
                        
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        NavigationLink{SettingView()} label:{
                            Image(systemName: "gearshape.fill").foregroundColor(uiColor2)
                        }
                        
                    }
                }
            
        }
    }
}
