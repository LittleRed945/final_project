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
            Image("char\(character.char)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
            Image("hair\(character.hair)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
            Image("shirt\(character.shirt)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
            Image("pants\(character.pants)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
            Image("shoes\(character.shoes)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: width, height: height).offset(character.offset)
        }
    }
}
