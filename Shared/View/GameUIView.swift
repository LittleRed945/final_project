import SwiftUI
struct GameUIView:View{
    @ObservedObject var gameViewModel:GameViewModel
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    var body: some View{
        VStack{
            PlayerStatusView(gameViewModel: gameViewModel,uiColor1: uiColor1,uiColor2: uiColor2)
            Spacer()
            PlayerActionView(gameViewModel: gameViewModel,uiColor1: uiColor1,uiColor2: uiColor2)
        }
    }
}
struct PlayerStatusView:View{
    @ObservedObject var gameViewModel:GameViewModel
    let uiColor1:Color
    let uiColor2:Color
    @State var show_ui=true
    var body: some View{
        VStack(spacing:0){
            if show_ui{
                ZStack{
                    Text("").onChange(of: gameViewModel.currentGameData.turn, perform: {newValue in
                        gameViewModel.now_index=gameViewModel.currentGameData.turn%gameViewModel.currentGameData.players_order.endIndex
                        gameViewModel.now_order=gameViewModel.currentGameData.players_order[gameViewModel.now_index]
                    })
                    Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width-40, height: 50)
                    Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width-60, height: 30)
                    HStack{
                        Text("Name:\(gameViewModel.userDatas[gameViewModel.now_index].userNickName)").foregroundColor(.black).font(.custom("JackeyFont", size: 20))
                        Spacer()
                        Text("HP:\(gameViewModel.currentGameData.players_hp[gameViewModel.now_index])").foregroundColor(.black).font(.custom("JackeyFont", size: 20))
                        Spacer()
                        Text("SP:\(gameViewModel.currentGameData.players_sp[gameViewModel.now_index])").foregroundColor(.black).font(.custom("JackeyFont", size: 20))
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width-80, height: 30)
                }
                
            }
            Button(action: {
                show_ui.toggle()
                
            }, label: {
                Rectangle().fill(uiColor1).frame(width: 60, height: 10).overlay(){
                    if show_ui{
                        Image(systemName: "triangle.fill").resizable().frame(width: 10,height: 8 ).foregroundColor(.black)
                    }else{
                        Image(systemName: "arrowtriangle.down.fill").resizable().frame(width: 10,height: 8 ).foregroundColor(.black)
                    }
                }
            })
        }
    }
}
struct PlayerActionView:View{
    var a=0
    
    @ObservedObject var gameViewModel:GameViewModel
    let uiColor1:Color
    let uiColor2:Color
    @State var show_ui=true
    @State var moveing=false
    var body: some View{
        VStack(spacing:0){
            Button(action: {
                show_ui.toggle()
            }, label: {
                Rectangle().fill(uiColor1).frame(width: 60, height: 10).overlay(){
                    if show_ui{
                        Image(systemName: "arrowtriangle.down.fill").resizable().frame(width: 10,height: 8 ).foregroundColor(.black)
                    }else{
                        Image(systemName: "triangle.fill").resizable().frame(width: 10,height: 8 ).foregroundColor(.black)
                    }
                }
            })
            if show_ui{
                ZStack{
                    Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width, height: 140)
                    Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width-20, height: 120)
                    //if moveing{
                    HStack{
                        VStack(spacing:0){
                            Button(action: {
                                gameViewModel.move_up()
                            }, label: {
                                Image(systemName:"arrowtriangle.up.circle" ).resizable().foregroundColor(.black).opacity(0.8).frame(width:30 , height: 30)
                            }).disabled(!gameViewModel.can_action)
                            HStack(spacing:0){
                                Button(action: {
                                    gameViewModel.move_left()
                                }, label: {
                                    Image(systemName:"arrowtriangle.left.circle" ).resizable().foregroundColor(.black).opacity(0.8).frame(width:30 , height: 30)
                                }).disabled(!gameViewModel.can_action)
                                Spacer().frame(width: 30, height: 30)
                                Button(action: {
                                    gameViewModel.move_right()
                                }, label: {
                                    Image(systemName:"arrowtriangle.right.circle" ).resizable().foregroundColor(.black).opacity(0.8).frame(width:30, height: 30)
                                }).disabled(!gameViewModel.can_action)
                            }
                            Button(action: {
                                gameViewModel.move_down()
                            }, label: {
                                Image(systemName:"arrowtriangle.down.circle" ).resizable().foregroundColor(.black).opacity(0.8).frame(width:30, height: 30)
                            }).disabled(!gameViewModel.can_action)
                        }.frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 120)
                        VStack(spacing:0){
                        Button(action: {
                            gameViewModel.attack()
                        }, label: {
                            Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 35).overlay(){
                                Text("攻擊").foregroundColor(.black).font(.system( size: 30))
                            }
                        }).disabled(!gameViewModel.can_action)
//                        Button(action: {
//                            gameViewModel.use_item()
//                        }, label: {
//                            Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 35).overlay(){
//                                Text("使用道具").foregroundColor(.black).font(.system( size: 30))
//                            }
//                        }).disabled(!gameViewModel.can_action)
                        Button(action: {
                            gameViewModel.rest()
                        }, label: {
                            Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height:35).overlay(){
                                Text("休息").foregroundColor(.black).font(.system( size: 30))
                            }
                        }).disabled(!gameViewModel.can_action)
                        }
                    }
                    // }else{
                    //                        VStack{
                    //                            HStack{
                    //                                Button(action: {
                    //                                    gameViewModel.attack()
                    //                                }, label: {
                    //                                    Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45).overlay(){
                    //                                        Text("攻擊").foregroundColor(.black).font(.system( size: 30))
                    //                                    }
                    //                                })
                    //                                Button(action: {
                    //                                    moveing.toggle()
                    //                                    gameViewModel.move()
                    //                                }, label: {
                    //                                    Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45).overlay(){
                    //                                        Text("移動").foregroundColor(.black).font(.system( size: 30))
                    //                                    }
                    //                                }).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45)
                    //
                    //                            }
                    //                            HStack{
                    //                                Button(action: {
                    //                                    gameViewModel.use_item()
                    //                                }, label: {
                    //                                    Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45).overlay(){
                    //                                        Text("使用道具").foregroundColor(.black).font(.system( size: 30))
                    //                                    }
                    //                                }).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45)
                    //                                Button(action: {
                    //                                    gameViewModel.rest()
                    //                                }, label: {
                    //                                    Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45).overlay(){
                    //                                        Text("休息").foregroundColor(.black).font(.system( size: 30))
                    //                                    }
                    //                                }).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45)
                    //                            }
                    //                        }
                    //                    }
                    //}
                    
                }//if show_ui end
                
            }
        }
    }
}

