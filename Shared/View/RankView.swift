
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
                Form{
                    Text("一場的總傷害排行榜")
                    Group{
                    ForEach(ranks.indices,id:\.self){i in
                        HStack{
                            Text("第\(i+1)名\(ranks[i].userName)")
                            Text("總傷害：\(ranks[i].total_damage)")
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

