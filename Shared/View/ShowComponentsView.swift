//
//  ShowComponentsView.swift
//  TEST
//
//  Created by  Erwin on 2022/5/31.
//

import Foundation
import SwiftUI
struct ShowComponentsView:View{
    @Binding var character:Character
    let style_name:Style
    let hair_num=2
    let shirt_num=2
    let pants_num=2
    let shoes_num=1
    var body: some View{
        ZStack{
            Image("show_style_board(big)")
            ScrollView(.vertical){
                
                switch style_name {
                case .hair:
                    VStack{
                        ForEach(Range(1...hair_num).indices){
                            i in
                            Button(action: {
                                if i<10{
                                    character.hair="0"+String(i)
                                }else{
                                    character.hair=String(i)
                                }
                                
                            }, label: {
                                if i < 10{
                                    Image("hair0\(i)-0-0").resizable().scaledToFit().frame(width: 108, height: 108)
                                }else{
                                    Image("hair\(i)-0-0").resizable().scaledToFit().frame(width: 108, height: 108)
                                }
                            })
                        }
                    }
                case .shirt:
                    VStack{
                        ForEach(Range(1...shirt_num).indices){
                            i in
                            Button(action: {
                                if i<10{
                                    character.shirt="0"+String(i)
                                }else{
                                    character.shirt=String(i)
                                }
                            }, label: {
                                if i < 10{
                                    Image("shirt0\(i)-0-0").resizable().scaledToFit().frame(width: 108, height: 108)
                                }else{
                                    Image("shirt\(i)-0-0").resizable().scaledToFit().frame(width: 108, height: 108)
                                }
                            })
                        }
                    }
                case .pants:
                    VStack{
                        ForEach(Range(1...pants_num).indices){
                            i in
                            Button(action: {
                                if i<10{
                                    character.pants="0"+String(i)
                                }else{
                                    character.pants=String(i)
                                }
                            }, label: {
                                if i < 10{
                                    Image("pants0\(i)-0-0").resizable().scaledToFit().frame(width: 108, height: 108)
                                }else{
                                    Image("pant\(i)-0-0").resizable().scaledToFit().frame(width: 108, height: 108)
                                }
                            })
                        }
                    }
                case .shoes:
                    VStack{
                        ForEach(Range(1...shoes_num).indices){
                            i in
                            Button(action: {
                                if i<10{
                                    character.shoes="0"+String(i)
                                }else{
                                    character.shoes=String(i)
                                }
                            }, label: {
                                if i < 10{
                                    Image("shoes0\(i)-0-0").resizable().scaledToFit().frame(width: 108, height: 108)
                                }else{
                                    Image("shoes\(i)-0-0").resizable().scaledToFit().frame(width: 108, height: 108)
                                }
                            })
                        }
                    }
                default:
                    Text("")
                }
                
            }
        }
    }
}
