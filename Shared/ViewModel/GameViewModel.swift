import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
class GameViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var invite_code=""
    @Published var currentGameData=GameData(player1_id: "", player2_id: "", player3_id: "", player4_id: "")
    @Published var userDatas=Array(repeating: UserData(id: "", userNickName: "", userGender: "", userBD: "", userFirstLogin: ""), count: 4)
    @Published var board=[tile]()
    @Published var players=[player]()
    //@Published var object_board=[object_tile]()
    @Published var turn=0
    @Published var my_turn=0
    @Published var tile_size=CGSize.zero
    
    var can_attack=false
    
    var move_image=8
    var attack_image=4
    func createLobby() {
                
                
                let game=GameData( player1_id:Auth.auth().currentUser!.uid, player2_id: "", player3_id: "", player4_id: "")
            
                do {
                    let documentReference = try db.collection("games").addDocument(from: game)
                    self.invite_code=documentReference.documentID
                    
                } catch {
                    print(error)
                }
    }
    func checkGameChange() {
        db.collection("games").document(self.invite_code).addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard let game = try? snapshot.data(as: GameData.self) else { return }
           
            self.currentGameData=game
            
                print(game)
            }
    }
    func CatchUserData(){
        let userViewModel=UserViewModel()
        userViewModel.fetchUsers(){
            (result) in
            switch result {
            case .success(let udArray):
                print("使用者資料抓取成功")
                for u in udArray {
                    
                    if u.id == self.currentGameData.player1_id {
                        self.userDatas[0]=u
                        
                    }else if u.id == self.currentGameData.player2_id {
                        self.userDatas[1]=u
                        
                    }
                    else if u.id == self.currentGameData.player3_id {
                        self.userDatas[2]=u
                        
                    }
                    else if u.id == self.currentGameData.player4_id {
                        self.userDatas[3]=u
                        
                    }
                }
                
                
            case .failure(_):
                print("使用者資料抓取失敗")
                //showView = true
            }
            
        }
    }
    func deleteLobby(){
        db.collection("games").document(self.invite_code).delete()
        
    }
    func demo(){
        
        for _ in Range(0...16*16-1){
            board.append(tile())
            //            object_board.append(object_tile())
        }
        //        object_board[0].object = .player
        //        object_board[15].object = .player
        //        object_board[16*15].object = .player
        //        object_board[16*15+15].object = .player
        players .append(player())
        players .append(player())
        players[0].name="P01"
        players[1].board_pos=15
        players[1].name="P02"
        players[1].hp=100
        tile_size.width=32
        tile_size.height=32
    }
    func attack(){
        self.players[self.turn].action+=4
        for i in 0..<self.attack_image-1{
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)*0.1) {
                self.players[self.turn].animation_id+=1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.attack_image-1)*0.1) {
            self.players[self.turn].action-=4
            self.players[self.turn].animation_id=0
        }
    }
    func player_is_front()->Bool{
        
        for i in 0..<players.endIndex{
            if i != self.turn{
                if self.players[self.turn].action==1,self.players[i].board_pos==self.players[self.turn].board_pos-16{
                return true
            }
            else if self.players[self.turn].action==0,self.players[i].board_pos==self.players[self.turn].board_pos+16{
                return true
            }
            else if self.players[self.turn].action==3,self.players[i].board_pos==self.players[self.turn].board_pos-1{
                return true
            }
            else if self.players[self.turn].action==2,self.players[i].board_pos==self.players[self.turn].board_pos+1{
                return true
            }
            }
        }
        return false
    }
    func move(){
        if self.players[self.turn].is_moveing{
            if self.players[self.turn].action==1{
                self.move_up()
            }
            else if self.players[self.turn].action==0{
                self.move_down()
            }
            else if self.players[self.turn].action==3{
                self.move_left()
            }
            else if self.players[self.turn].action==2{
                self.move_right()
            }
            self.players[self.turn].is_moveing=false
        }
    }
    func move_up(){
        self.players[self.turn].action=1
        if self.players[self.turn].board_pos/16>0,!self.player_is_front(){
            self.players[self.turn].board_pos-=16
        }
    }
    func move_down(){
        self.players[self.turn].action=0
        if self.players[self.turn].board_pos/16<16-1,!self.player_is_front(){
            self.players[self.turn].board_pos+=16
        }
    }
    func move_left(){
        self.players[self.turn].action=3
        if self.players[self.turn].board_pos%16>0,!self.player_is_front(){
            self.players[self.turn].board_pos-=1
        }
    }
    func move_right(){
        self.players[self.turn].action=2
        if self.players[self.turn].board_pos%16<16-1,!self.player_is_front(){
            self.players[self.turn].board_pos+=1
        }
        
    }
    func use_item(){
        print("HI")
    }
    func rest(){
        self.turn+=1
        if self.turn >= self.players.endIndex{
            self.turn=0
        }
        
    }
    
}
