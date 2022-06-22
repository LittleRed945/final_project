import Foundation
import SwiftUI

struct ChooseRoleView: View {
    @ObservedObject var gameViewModel:GameViewModel
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    let roles_array=["探險家","戰士","普通人"]
    var body: some View{
        HStack(spacing:20){
            //players
            ForEach(roles_array.indices){ i in
                Button(action: {
                    gameViewModel.setRole(role: roles_array[i])
                }, label: {
                    ZStack{
                        Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/4-30, height:  UIScreen.main.bounds.height/2)
                        Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width/4-50, height:  UIScreen.main.bounds.height/2-20)
                    }.overlay{
                        Text("\(roles_array[i])")
                    }
                })
            }
            
        }
    }
    
}
