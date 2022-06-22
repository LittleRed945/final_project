//
//  GameView.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/6.
//

import Foundation
import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameViewModel:GameViewModel
    @State private var currentMagnification: CGFloat = 1
    @State private var firstAppear = true
    @State private var board=[String]()
    @GestureState private var pinchMagnification: CGFloat = 1
    @Namespace var topId
    var body: some View {
        //ScrollViewReader{proxy in
        ScrollView([.vertical,.horizontal], showsIndicators: false){
            ZStack{
                //Rectangle().fill(.blue).frame(width: 2160, height: 2160)
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(gameViewModel.tile_size.width), spacing:0), count: 16),spacing:0){
                    ForEach(board.indices,id:\.self){
                        t in
                        ZStack{
                            Rectangle().fill(.green).frame(width: 32, height: 32)
                            
                        }
                    }
                }
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(gameViewModel.tile_size.width), spacing:0), count: 16),spacing:0){
                    ForEach(gameViewModel.object_board){tile in
                        if tile.object == .player{
                            
                            CharacterView(character: gameViewModel.characters[tile.index], width: gameViewModel.tile_size.width, height: gameViewModel.tile_size.height)
                        }else{
                            Text("").frame(width: gameViewModel.tile_size.width, height: gameViewModel.tile_size.height)
                        }
                    }
//                    ForEach(gameViewModel.currentGameData.players_order.indices,id:\.self){i in
//                        if tile.object == {
//                        Image("char01-\(gameViewModel.players[i].action)-\(gameViewModel.players[i].animation_id)").resizable()
//                            .id(i).onAppear(){print("gameViewModel.turn")}
//
//                    }
//                    }
                }
                //.scaleEffect(currentMagnification * pinchMagnification)
                
            }
            //                Text("").onChange(of:gameViewModel.turn){ value in
            //                    proxy.scrollTo(gameViewModel.turn)
            //                }
            //            }.gesture(MagnificationGesture()
            //                        .updating($pinchMagnification, body: { (value, state, _) in
            //                            state = value
            //                        })
            //                        .onEnded{ self.currentMagnification *= $0
            //                if self.currentMagnification > 3 {
            //                    self.currentMagnification = 3.0
            //                }else if self.currentMagnification < 0.5 {
            //                    self.currentMagnification = 0.5
            //
            //                }
        }.onAppear{
            if firstAppear{
                for _ in Range(0...16*16-1){
                    board.append("")
                }
                gameViewModel.generateMap()
            }
            firstAppear=false
        }.background(Rectangle().fill(.blue))
        //                    )
        
        //}
    }
}
