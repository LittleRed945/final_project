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
                    Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width-40, height: 50)
                    Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width-60, height: 30)
                    HStack{
                        Text("Name:\(gameViewModel.players[gameViewModel.turn].name)").foregroundColor(.black).font(.custom("JackeyFont", size: 20))
                        Spacer()
                        Text("HP:\(gameViewModel.players[gameViewModel.turn].hp)").foregroundColor(.black).font(.custom("JackeyFont", size: 20))
                        Spacer()
                        Text("SP:\(gameViewModel.players[gameViewModel.turn].sp)").foregroundColor(.black).font(.custom("JackeyFont", size: 20))
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width-80, height: 30)
                }
                
            }
            Button(action: {
                show_ui.toggle()
                print(gameViewModel.turn)
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
    @ObservedObject var gameViewModel:GameViewModel
    let uiColor1:Color
    let uiColor2:Color
    @State var show_ui=true
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
                    VStack{
                        HStack{
                            Button(action: {
                                gameViewModel.attack()
                            }, label: {
                                Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45).overlay(){
                                    Text("攻擊").foregroundColor(.black).font(.system( size: 30))
                                }
                            })
                            Button(action: {
                                show_ui.toggle()
                                gameViewModel.move()
                            }, label: {
                                Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45).overlay(){
                                    Text("移動").foregroundColor(.black).font(.system( size: 30))
                                }
                            }).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45)

                        }
                        HStack{
                            Button(action: {
                                gameViewModel.use_item()
                            }, label: {
                                Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45).overlay(){
                                    Text("使用道具").foregroundColor(.black).font(.system( size: 30))
                                }
                            }).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45)
                            Button(action: {
                                gameViewModel.rest()
                            }, label: {
                                Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45).overlay(){
                                    Text("休息").foregroundColor(.black).font(.system( size: 30))
                                }
                            }).frame(width:(UIScreen.main.bounds.width-20)/2-30 , height: 45)
                        }
                    }
                }
            }
            
        }
    }
}
