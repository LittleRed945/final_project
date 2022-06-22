//
//  Player.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/7.
//
import SwiftUI
import Foundation
struct player:Identifiable{
    var id = UUID()
    var name = ""
    var board_pos=0
    var hp = 50
    var atk = 1
    var sp = 6
    var animation_id=0 //etc. move letf-0 move left-1 ...
    var action=0 //move left,move right,move up,move down, attack and mine
    var is_moveing=false
    var is_attacking=false
}
