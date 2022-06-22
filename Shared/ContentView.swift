//
//  ContentView.swift
//  Shared
//
//  Created by  Erwin on 2022/6/1.
//

import SwiftUI

struct ContentView: View {
    @StateObject var gameViewModel=GameViewModel()
    @State var mail = ""
    @State var password=""
    var body: some View {
        ZStack{
            LoginView(mail: $mail, password: $password)
//        GameView(gameViewModel: gameViewModel)
//            GameUIView(gameViewModel: gameViewModel)
        }
        //AdView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewInterfaceOrientation(.landscapeLeft)
    }
}
