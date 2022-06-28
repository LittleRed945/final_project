//
//  InstructionView.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/28.
//

import Foundation
import SwiftUI
struct InstructionView:View{
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    
    var body: some View{
        
            List{
                Text("遊戲說明").foregroundColor(.black).font(.system( size: 30))
                Text("一開始必須選擇好職業,每種職業都擁有以下三種屬性")
                Group{
                    Text("血量Hp-一但歸零代表出局")
                    Text("耐力Sp-一但歸零代表該回合無法再進行移動或是攻擊等操作")
                    Text("攻擊力Atk-對其他玩家進行攻擊一次所造成的數值傷害")
                }
                Text("每場遊戲的玩家順序在一開場就決定好了,好好的在遊戲中成為最後的生還者吧！")
            }.background(Rectangle().fill(uiColor1))
            
        
    }
}
