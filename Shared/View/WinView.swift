import Foundation
import SwiftUI
import NukeUI
import FirebaseAuth
struct WinView:View{
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    let rank_data:RankData
    @StateObject var rankViewModel=RankViewModel()
    @State var to_home=false
    var body: some View{
        ZStack{
            Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width-60, height: 140)
        VStack{
            Text("Congratulations").foregroundColor(uiColor2).font(.custom("JackeyFont", size: 40))
            Button(action: {
                to_home=true
                rankViewModel.UpdateRank(rd: rank_data, uid: Auth.auth().currentUser!.uid)
            }, label: {
                Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width-100) , height:35).overlay(){
                    Text("回到大廳").foregroundColor(.black).font(.system( size: 30))
            }
            }).fullScreenCover(isPresented: $to_home,content:{HomeView()})
        }
        }.background(Image("background"))
    }
}
