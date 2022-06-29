
import Foundation
import SwiftUI
import NukeUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestoreSwift
struct RankView: View {
    let rankViewModel=RankViewModel()
    @State var ranks=[RankData]()
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    Text("一場的總傷害排行榜").font(.title)
                    HStack{
                        Text("Rank").frame(width:60)
                        Text("Name").frame(width:120)
                        Text("Total Damage").frame(minWidth: 0, maxWidth: .infinity)
                    }
                    Group{
                    ForEach(ranks.indices,id:\.self){i in
                        HStack{
                            Text("\(i+1)").frame(width:60)
                            Text("\(ranks[i].userName)").frame(width:120)
                            Text("\(ranks[i].total_damage)").frame(minWidth: 0, maxWidth: .infinity)
                        }
                    }
                    }
                }
                
                
            }.onAppear(){
                                
                rankViewModel.fetchRanks(){
                    (result) in
                    switch result {
                    case .success(let rdArray):
                        print("排行榜資料抓取成功")
                        ranks=rdArray
                        
                        
                    case .failure(_):
                        print("使用者資料抓取失敗")
                        //showView = true
                    }
                    
                }
                   
            }
        }
    }
}

