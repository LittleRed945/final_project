//
//  SettingView.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/20.
//

import Foundation
import SwiftUI
struct SettingView:View{
    @ObservedObject  var gameViewModel:GameViewModel
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    var body: some View {
        ZStack{
            Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height-20)
            VStack{
        HStack{
            Text("音效：")
            Slider(value: $gameViewModel.SFXvolume, in: 0...1){edited in
                print(edited)
                gameViewModel.setMusic()
            }
        }
                HStack{
                    Text("音樂：")
                    Slider(value: $gameViewModel.BGMvolume, in: 0...1){edited in
                        print(edited)
                        gameViewModel.setMusic()
                    }
                }
            }.frame(width: UIScreen.main.bounds.width-40, height: UIScreen.main.bounds.height-40)
        }.background(Image("background"))
            
    }
}
