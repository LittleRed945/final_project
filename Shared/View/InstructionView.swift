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
                Text("一開始必須選擇好職業,每種職業都擁有以下三種屬性").fontWeight(.bold)
                Group{
                    Text("Hp-一但歸零代表出局")
                    Text("Sp-一但歸零代表該回合無法再進行移動或是攻擊等操作")
                    Text("Atk-對其他玩家進行攻擊一次所造成的數值傷害")
                }
                Text("移動").fontWeight(.bold)
                Group{
                    Text("輪到自己的回合時,可以花費一點Sp按下方向鍵進行移動")
                    Text("只有前方沒有玩家時才可以進行移動")
                    Text("一回合可以移動多次")
                }
                Text("攻擊").fontWeight(.bold)
                Group{
                    Text("輪到自己的回合時,可以花費一點Sp對前方目標進行一次攻擊")
                    Text("只有前方有玩家時才可以進行攻擊")
                    Text("一回合可以攻擊多次")
                }
                Text("休息").fontWeight(.bold)
                Group{
                    Text("輪到自己的回合時,可以按下休息按鈕進行休息")
                    Text("恢復自身最大Sp的一半")
                    Text("使用後將直接進入下一回合")
                }
                Text("每場遊戲的玩家順序在一開場就決定好了,好好的在遊戲中成為最後的生還者吧！")
            }.background(Rectangle().fill(uiColor1))
            
        
    }
}
