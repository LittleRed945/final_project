import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
class GameViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var invite_code=""
    @Published var currentGameData=GameData(players_id:[String]() )
    
    //    @Published var userDatas=Array(repeating: UserData(id: "", userNickName: "", userGender: "", userBD: "", userFirstLogin: ""), count: 4)
    //    @Published var currentGameData=GameData(player1_id: "", player2_id: "", player3_id: "", player4_id: "")
    @Published var userDatas=[UserData]()
    @Published var board=[tile]()
    @Published var players=[player]()
    @Published var object_board=[object_tile]()
    @Published var now_order=0
    @Published var now_index=0
    @Published var my_order=0
    @Published var my_index=0
    @Published var tile_size=CGSize.zero
    
    var can_attack=false
    
    var move_image=8
    var attack_image=4
    func createLobby() {
        
        
        let game=GameData(players_id: [Auth.auth().currentUser!.uid])
        
        do {
            let documentReference = try db.collection("games").addDocument(from: game)
            self.invite_code=documentReference.documentID
            
        } catch {
            print(error)
        }
    }
    func fetchGames(completion: @escaping((Result<[GameData], Error>) -> Void)){
        db.collection("games").getDocuments { snapshot, error in
                    
                 guard let snapshot = snapshot else { return }
                
                 let games = snapshot.documents.compactMap { snapshot in
                     try? snapshot.data(as: GameData.self)
                 }
                 print(games)
                completion(.success(games))
             }
    }
    func joinLobby(invite_code:String,completion: @escaping((Result<String, Error>) -> Void)){
        print("invite_code:"+invite_code)
        self.invite_code=invite_code
        self.fetchGames(){
            (result) in
            switch result {
            case .success(let gdArray):
                print("遊戲資料抓取成功")
                for g in gdArray {
                    if g.id == self.invite_code ,!g.is_started{
                            
                            self.currentGameData=g
                            self.currentGameData.players_id.append(Auth.auth().currentUser!.uid)
                            self.UpdateGame()
                            completion(.success("成功"))
                            break
                        
                    }
                }
                
            case .failure(_):
                print("使用者資料抓取失敗")
            }
        }
        
    }
    func startGame(){
        self.currentGameData.is_started=true
        let count=currentGameData.players_id.endIndex
        self.currentGameData.players_hp=Array(repeating: 0, count: count)
        self.currentGameData.players_sp=Array(repeating: 0, count: count)
        self.currentGameData.players_atk=Array(repeating: 0, count: count)
        self.currentGameData.players_role=Array(repeating: "", count: count)
        self.currentGameData.players_x=Array(repeating: 0, count: count)
        self.currentGameData.players_y=Array(repeating: 0, count: count)
        for i in 0..<count{
            self.currentGameData.players_order.append(i)
        }
        self.currentGameData.players_order.shuffle()
        self.UpdateGame()
        for i in 0..<count{
            if Auth.auth().currentUser!.uid == self.currentGameData.players_id[i]{
                self.my_order=self.currentGameData.players_order[i]
                self.my_index=i
            }
        }
        self.tile_size=CGSize(width:32,height: 32)
    }
    func setRole(role:String){
        
        if role=="探險家"{
            self.currentGameData.players_hp[my_index]=30
            self.currentGameData.players_sp[my_index]=10
            self.currentGameData.players_atk[my_index]=3
            self.currentGameData.players_role[my_index]=role
        }else if role=="戰士"{
            self.currentGameData.players_hp[my_index]=50
            self.currentGameData.players_sp[my_index]=5
            self.currentGameData.players_atk[my_index]=5
            self.currentGameData.players_role[my_index]=role
        }else{
            self.currentGameData.players_hp[my_index]=40
            self.currentGameData.players_sp[my_index]=8
            self.currentGameData.players_atk[my_index]=4
            self.currentGameData.players_role[my_index]=role
        }
        self.UpdateGame()
    }
    func checkGameChange() {
        db.collection("games").document(self.invite_code).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let game = try? snapshot.data(as: GameData.self) else { return }
            
            self.currentGameData=game
            
            if self.currentGameData.players_id==[]{
                self.leaveLobby()
            }
            print(game)
        }
    }
    func CatchUserData(){
        print("I m IN")
        let userViewModel=UserViewModel()
        userViewModel.fetchUsers(){
            (result) in
            
            switch result {
            case .success(let udArray):
                print("使用者資料抓取成功")
                for u in udArray {
                    for p_id in self.currentGameData.players_id{
                        if u.id == p_id{
                            self.userDatas.append(u)
                        }
                        
                    
                    }                }
                
                
            case .failure(_):
                print("使用者資料抓取失敗")
                //showView = true
            }
            
        }
    }
    func UpdateGame() {
        
        let documentReference =
        db.collection("games").document(self.invite_code)
        documentReference.getDocument { document, error in
            
            guard let document = document,
                  document.exists,
                  var game = try? document.data(as: GameData.self)
            else {
                return
            }
            game=self.currentGameData
            do {
                try documentReference.setData(from: game)
            } catch {
                print(error)
            }
            
        }
    }
    func generateMap(){
        for _ in Range(0...16*16-1){
            object_board.append(object_tile())
        }
        let pos_x_array=[0,15,0,15].shuffled()
        let pos_y_array=[0,15,0,15].shuffled()
        for i in self.currentGameData.players_id.indices{
            self.currentGameData.players_x[i]=pos_x_array[i]
            self.currentGameData.players_y[i]=pos_y_array[i]
            self.object_board[self.currentGameData.players_x[i]+self.currentGameData.players_y[i]*16]=object_tile(object:.player,index:i)
        }
        self.UpdateGame()
    }
    func leaveLobby(){
        
            for i in self.currentGameData.players_id.indices{
                if self.currentGameData.players_id[i]==Auth.auth().currentUser!.uid{
                    self.currentGameData.players_id.remove(at: i)
                    print(self.currentGameData)
                    self.UpdateGame()
                    break
                }
            }
        print(self.currentGameData.players_id.endIndex)
        self.userDatas=[UserData]()
        self.currentGameData=GameData(players_id:[String]() )
        if self.currentGameData.players_id.endIndex<=0{
            let documentReference=db.collection("games").document(self.invite_code)
            documentReference.delete()
            print("YEs")
        }
        
//        self.invite_code=""
        
//        self.currentGameData=GameData(players_id:[String]() )
        
    }
    func demo(){
        
        for _ in Range(0...16*16-1){
            board.append(tile())
                        object_board.append(object_tile())
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
        self.currentGameData.play.action+=4
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
        self.currentGameData.turn+=1
        for i in self.currentGameData.players_id.indices{
            if self.currentGameData.turn%self.currentGameData.players_id.endIndex==self.currentGameData.players_order[i]{
                self.now_index=i
                self.now_order=self.currentGameData.players_order[i]
            }
        }
        
        
    }
    
}
