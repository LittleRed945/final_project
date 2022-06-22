//
//  board.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/6.
//

import Foundation

struct tile:Identifiable{
    var id = UUID()
    var type = "green"
}
struct object_tile:Identifiable{
    var id = UUID()
    var object=game_object.none
}
