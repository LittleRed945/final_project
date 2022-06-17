//
//  GameViewModel.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/7.
//

import Foundation
import SwiftUI
class GameViewModel: ObservableObject {
    @Published var board=[tile]()
    @Published var players=[player]()
    @Published var turn=0
    @Published var tile_size=CGSize.zero
    var move_image=8
    var attack_image=4
    init(){
        self.demo()
    }
    func demo(){
        
        for _ in Range(0...16*16-1){
            board.append(tile())
        }
        board[0].object="trash"
        board[15].object="trash"
        board[16*15].object="trash"
        board[16*15+15].object="trash"
        players .append(player())
        players .append(player())
        players[0].name="P01"
        players[1].board_pos=15
        players[1].name="P02"
        players[1].hp=100
        tile_size.width=32
        tile_size.height=32
    }
    func attack(){
        self.players[self.turn].action+=4
        for i in 0..<self.attack_image-1{
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)*0.1) {
                self.players[self.turn].animation_id+=1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.attack_image-1)*0.1) {
            self.players[self.turn].action-=4
            self.players[self.turn].animation_id=0
        }
    }
    func move(){
        self.players[self.turn].action=0
        
    }
    func use_item(){
        print("HI")
    }
    func rest(){
        self.turn+=1
        if self.turn >= self.players.endIndex{
            self.turn=0
        }
        
    }
    
}
