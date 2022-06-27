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
    @Published var characters=[Character]()
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
    @Published var can_action=false
    var can_attack=true
    var last_pos=Int()
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
    func checkGameChange() {
        db.collection("games").document(self.invite_code).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let game = try? snapshot.data(as: GameData.self) else { return }
            
            
            
            self.currentGameData=game
            if self.currentGameData.players_id.endIndex != self.userDatas.endIndex{
                self.CatchUserData()
            }
            
            
            if self.currentGameData.is_started{
                self.now_order=self.currentGameData.turn%self.currentGameData.players_id.endIndex
                for i in self.currentGameData.players_order.indices{
                    if self.currentGameData.players_order[i] == self.now_order{
                        self.now_index=i
                        break
                    }
                }
                if self.now_order != self.my_order{
                    self.can_action=false
                }else if self.now_order == self.my_order{
                    self.can_action=true
                }
                if self.currentGameData.attacking[self.now_index],self.my_order != self.now_order{
                    self.attack()
                    
                }
                if self.currentGameData.players_last_pos[self.now_index] != self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16{
                    self.move()
                }
            }
            if self.currentGameData.players_id==[]{
                self.leaveLobby()
            }
           
        }
    }
    func CatchUserData(){
        let users_sum=self.currentGameData.players_id.endIndex
        self.userDatas=Array(repeating: UserData(id: "", userNickName: "", userGender: "", userBD: "", userFirstLogin: ""),count:users_sum)
        var is_exist=false
        print("I m IN")
        let userViewModel=UserViewModel()
        userViewModel.fetchUsers(){
            (result) in
            
            switch result {
            case .success(let udArray):
                print("使用者資料抓取成功")
                
                    
                    for i in self.currentGameData.players_id.indices{
                        for u in udArray {
                        if u.id == self.currentGameData.players_id[i]{
                            self.userDatas[i]=u
                            break
                        }
                        
                        }
                    }
                    
                    
                
                print(self.userDatas)
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
            
            print("UPdateing")
            print(self.currentGameData)
            game=self.currentGameData
            do {
                try documentReference.setData(from: game)
            } catch {
                print(error)
            }
            
        }
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
    func startGame(){
        self.currentGameData.is_started=true
        let count=currentGameData.players_id.endIndex
        self.currentGameData.players_hp=Array(repeating: 0, count: count)
        self.currentGameData.players_sp=Array(repeating: 0, count: count)
        self.currentGameData.players_atk=Array(repeating: 0, count: count)
        self.currentGameData.players_role=Array(repeating: "", count: count)
        self.currentGameData.attacking=Array(repeating: false, count: count)
        self.currentGameData.moving=Array(repeating: false, count: count)
        self.currentGameData.players_last_pos=Array(repeating: 0, count: count)
        self.currentGameData.players_x=Array(repeating: 0, count: count)
        self.currentGameData.players_y=Array(repeating: 0, count: count)
        for i in 0..<count{
            self.currentGameData.players_order.append(i)
        }
        
        self.currentGameData.players_order.shuffle()
        
            let pos_x_array=[0,0,0,15]
            let pos_y_array=[0,15,15,0]
            for i in self.currentGameData.players_id.indices{
                self.currentGameData.players_x[i]=pos_x_array[self.currentGameData.players_order[i]]
                self.currentGameData.players_y[i]=pos_y_array[self.currentGameData.players_order[i]]
                self.currentGameData.players_last_pos[i]=self.currentGameData.players_x[i]+self.currentGameData.players_y[i]*16
                print("\(self.currentGameData.players_y[i]):\(i):FUCK")
            }
            
        
        self.UpdateGame()
        print(currentGameData.players_order)
        
    }
    func setRole(role:String){
        var ready_count=0
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
        
        for i in self.currentGameData.players_role.indices{
            if self.currentGameData.players_role[i] != ""{
                ready_count+=1
            }
        }
        if ready_count==self.currentGameData.players_role.endIndex{
            self.currentGameData.allReady=true
        }
        self.UpdateGame()
    }
    
    func setTheSpawn(){
        for i in self.currentGameData.players_id.indices{
            self.object_board[self.currentGameData.players_x[i]+self.currentGameData.players_y[i]*16]=object_tile(object:.player,index:i)
            self.characters.append(Character(char: self.userDatas[i].char, hair: self.userDatas[i].hair, shirt: self.userDatas[i].shirt, pants: self.userDatas[i].pants, shoes: self.userDatas[i].shoes))
            
            print("NONONO")
            print(object_board[self.currentGameData.players_x[i]+self.currentGameData.players_y[i]*16].index)
        }
        
    }
    func generateMap(){
        for _ in Range(0...16*16-1){
            object_board.append(object_tile())
        }
        for i in self.currentGameData.players_id.indices{
            print("MyIndex:\(Auth.auth().currentUser!.uid):\(i)")
            if Auth.auth().currentUser!.uid == self.currentGameData.players_id[i]{
                self.my_order=self.currentGameData.players_order[i]
                self.my_index=i
                print(self.my_index)
            }
        }
        self.tile_size=CGSize(width:32,height: 32)
        
        
        
    }
//    func demo(){
//        
//        for _ in Range(0...16*16-1){
//            board.append(tile())
//                        object_board.append(object_tile())
//        }
//        //        object_board[0].object = .player
//        //        object_board[15].object = .player
//        //        object_board[16*15].object = .player
//        //        object_board[16*15+15].object = .player
//        players .append(player())
//        players .append(player())
//        players[0].name="P01"
//        players[1].board_pos=15
//        players[1].name="P02"
//        players[1].hp=100
//        tile_size.width=32
//        tile_size.height=32
//    }
    func attack(){
        if self.my_order==self.now_order{
            self.currentGameData.attacking[self.my_index]=true
            if self.player_is_front(){
                if self.characters[self.now_index].action%4==1{
                    print(self.object_board[self.currentGameData.players_x[now_index]+self.currentGameData.players_y[now_index]*16-16])
                }
            }
            self.UpdateGame()
        }
        self.characters[self.now_index].action+=4
        self.can_action=false
        for i in 0..<self.attack_image-1{
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)*0.1) {
                self.characters[self.now_index].animation_id+=1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.attack_image-1)*0.1) {
            self.characters[self.now_index].action-=4
            self.characters[self.now_index].animation_id=0
            self.can_action=true
        }
        self.currentGameData.attacking[self.now_index]=false
        
    }
    func player_is_front()->Bool{
        
        for i in 0..<self.currentGameData.players_order.endIndex{
            if i != self.now_index{
                if self.characters[self.now_index].action%4==1,self.currentGameData.players_x[now_index]==self.currentGameData.players_x[i],self.currentGameData.players_y[now_index]==self.currentGameData.players_y[i]-16{
                    return true
                }
                else if self.characters[self.now_index].action%4==0,self.currentGameData.players_x[now_index]==self.currentGameData.players_x[i],self.currentGameData.players_y[now_index]==self.currentGameData.players_y[i]+16{
                    return true
                }
                else if self.characters[self.now_index].action%4==3,self.currentGameData.players_x[now_index]==self.currentGameData.players_x[i]-1,self.currentGameData.players_y[now_index]==self.currentGameData.players_y[i]{
                    return true
                }
                else if self.characters[self.now_index].action%4==2,self.currentGameData.players_x[now_index]==self.currentGameData.players_x[i]+1,self.currentGameData.players_y[now_index]==self.currentGameData.players_y[i]{
                    return true
                }
            }
        }
        return false
    }
    func move(){
        let now_player_board_pos=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
        if  self.object_board[now_player_board_pos].object != .player{
            withAnimation(){
                self.object_board.swapAt(now_player_board_pos,self.currentGameData.players_last_pos[self.now_index])
            }
            let direction=now_player_board_pos-self.currentGameData.players_last_pos[self.now_index]
            if direction==16{//down
                self.characters[self.now_index].action=0
            }else if direction == -16{//up
                self.characters[self.now_index].action=1
            }else if direction==1{//right
                self.characters[self.now_index].action=2
            }else if direction==1{//left
                self.characters[self.now_index].action=3
            }
        }
//        if  self.object_board[now_player_board_pos].object != .player{
//
//            withAnimation(){
//
//                if !self.player_is_front(){
//                    //move up, and  because the player is already move,you should swap the not updated player object to  the object that  is now player at
//                    print(now_player_board_pos)
//                    if self.characters[self.now_index].action==1,self.currentGameData.players_y[self.now_index]>=0{
//                        self.object_board.swapAt(now_player_board_pos, now_player_board_pos+16)
//                    }
//                    //move down
//                    else if self.characters[self.now_index].action==0,self.currentGameData.players_y[self.now_index]<=16-1{
//                        self.object_board.swapAt(now_player_board_pos, now_player_board_pos-16)
//                    }
//                    //move left
//                    else if self.characters[self.now_index].action==3,self.currentGameData.players_x[self.now_index]>=0{
//                        self.object_board.swapAt(now_player_board_pos, now_player_board_pos+1)
//                    }
//                    //move right
//                    else if self.characters[self.now_index].action==2,self.currentGameData.players_x[self.now_index]<=16-1{
//                        self.object_board.swapAt(now_player_board_pos, now_player_board_pos-1)
//                    }
//                }
//            }
//        }
//        if self.players[self.turn].is_moveing{
//            if self.players[self.turn].action==1{
//                self.move_up()
//            }
//            else if self.players[self.turn].action==0{
//                self.move_down()
//            }
//            else if self.players[self.turn].action==3{
//                self.move_left()
//            }
//            else if self.players[self.turn].action==2{
//                self.move_right()
//            }
//            self.players[self.turn].is_moveing=false
//        }
//        for i in object_board.indices{
//            if
//        }
    }
    func move_up(){
        self.characters[self.now_index].action=1
        if self.currentGameData.players_y[now_index]>0,!self.player_is_front(){
            
                self.currentGameData.players_last_pos[self.now_index]=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
                self.currentGameData.players_y[now_index]-=1
                self.currentGameData.players_sp[now_index]-=1
                self.UpdateGame()
            
//            self.move()
        }
        
    }
    func move_down(){
        self.characters[self.now_index].action=0
        if self.currentGameData.players_y[now_index]<16-1,!self.player_is_front(){
            
           
                self.currentGameData.players_last_pos[self.now_index]=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
                self.currentGameData.players_y[now_index]+=1
                self.currentGameData.players_sp[now_index]-=1
                self.UpdateGame()
            
//            self.move()
        }
        
    }
    func move_left(){
        self.characters[self.now_index].action=3
       
        if self.currentGameData.players_x[now_index]>0,!self.player_is_front(){
            
                self.currentGameData.players_last_pos[self.now_index]=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
                self.currentGameData.players_x[now_index]-=1
                self.currentGameData.players_sp[now_index]-=1
                self.UpdateGame()
            
//            self.move()
            
        }
//        self.move()
        
    }
    func move_right(){
        self.characters[self.now_index].action=2
        if self.currentGameData.players_x[now_index]<16-1,!self.player_is_front(){
           
                self.currentGameData.players_last_pos[self.now_index]=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
                self.currentGameData.players_x[now_index]+=1
                self.currentGameData.players_sp[now_index]-=1
                self.UpdateGame()
            
//            self.move()
        }
        
        
    }
    func use_item(){
        print("HI")
    }
    func rest(){
        self.currentGameData.turn+=1
//        for i in self.currentGameData.players_order.indices{
//            if self.currentGameData.turn%self.currentGameData.players_order.endIndex==self.currentGameData.players_order[i]{
//                self.now_index=i
//                self.now_order=self.currentGameData.players_order[i]
//
//            }
//        }
        self.currentGameData.players_sp[self.my_index]+=2
        if self.currentGameData.turn%self.currentGameData.players_order.endIndex == self.my_order{
            self.UpdateGame()
        }
        
    }
    
}
