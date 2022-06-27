//
//  CharacterView.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/21.
//

import Foundation
import SwiftUI
struct CharacterView:View{
    let character:Character
    let width:CGFloat
    let height:CGFloat
    var body:some View{
        ZStack{
            Image("char\(character.char)-\(character.action)-\(character.animation_id)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
            Image("hair\(character.hair)-\(character.action)-\(character.animation_id)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
            Image("shirt\(character.shirt)-\(character.action)-\(character.animation_id)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
            Image("pants\(character.pants)-\(character.action)-\(character.animation_id)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
            Image("shoes\(character.shoes)-\(character.action)-\(character.animation_id)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
        }
    }
}
