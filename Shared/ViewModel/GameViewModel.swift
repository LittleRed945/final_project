import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import AVFoundation
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
    @Published var my_role=""
    @Published var tile_size=CGSize.zero
    @Published var can_action=true
    @Published var can_rest=true
    @Published var is_gameover=false
    @Published var is_win=false
    @Published var rank_data=RankData()
    var can_attack=true
    var turn_start=true
    var last_pos=Int()
    var move_image=8
    var attack_image=4
    //SFX
    @Published var SFXvolume:Float=1
    var slashPlayer: AVPlayer { AVPlayer.sharedSlashPlayer }
    var winPlayer: AVPlayer { AVPlayer.sharedWinPlayer }
    var losePlayer: AVPlayer { AVPlayer.sharedLosePlayer }
    @Published var BGMvolume:Float=1
    init(){
        AVPlayer.setupBgMusic()
        AVPlayer.bgQueuePlayer.play()
    }
    func setMusic(){
        self.slashPlayer.volume=SFXvolume
        self.winPlayer.volume=SFXvolume
        self.losePlayer.volume=SFXvolume
        AVPlayer.bgQueuePlayer.volume=BGMvolume
    }
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
                
                self.is_gameover=true
                for id in self.currentGameData.players_id{
                    if id == Auth.auth().currentUser!.uid{
                        self.is_gameover=false
                        break
                    }
                }
            }
            
            if self.currentGameData.is_started, !self.currentGameData.allReady{
                var ready_count=0
                for i in self.currentGameData.players_role.indices{
                    if self.currentGameData.players_role[i] != ""{
                        ready_count+=1
                    }
                }
                if ready_count==self.currentGameData.players_role.endIndex{
                    self.currentGameData.allReady=true
                }
            }
            else if self.currentGameData.is_started {
                if !self.is_gameover,self.currentGameData.players_id.endIndex<=1{
                    print(self.currentGameData.players_id)
                    self.is_win=true
                }
                if self.my_index>=self.currentGameData.players_id.endIndex || self.currentGameData.players_id[self.my_index] != Auth.auth().currentUser!.uid{
                    self.refreshGame()
                }
                self.now_order=self.currentGameData.order
                for i in self.currentGameData.players_order.indices{
                    if self.currentGameData.players_order[i] == self.now_order{
                        self.now_index=i
                        break
                    }
                }
                print(self.can_action)
                print("\(self.my_order):\( self.now_order),啥")
                if self.can_action,self.currentGameData.players_sp[self.my_index]<=0{
                    self.can_action=false
                    print("CAN ACTION")
                    print(self.can_action)
                }
                if self.now_order != self.my_order{
                    print("1")
                    self.turn_start=true
                    self.can_action=false
                    self.can_rest=false
                }else if self.now_order==self.my_order,self.turn_start{
                    print("2")
                    self.turn_start=false
                    self.can_action=true
                    self.can_rest=true
                }
                
                if self.currentGameData.attacking_pos[self.now_index]>=0{
                    self.attack_animation()
                }
                if self.currentGameData.players_last_pos[self.now_index] != self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16{
                    self.move()
                }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1){
            if self.currentGameData.players_id.endIndex<=0{
                self.deletedLobby()
                
            }
            
            self.userDatas=[UserData]()
            self.currentGameData=GameData(players_id:[String]() )
            self.invite_code=""
        }
        
        
        //        if self.currentGameData.players_id.endIndex<=0{
        //            let documentReference=db.collection("games").document(self.invite_code)
        //            documentReference.delete()
        //            print("YEs")
        //        }
        
        //        self.invite_code=""
        
        //        self.currentGameData=GameData(players_id:[String]() )
        
    }
    func deletedLobby(){
        let documentReference=db.collection("games").document(self.invite_code)
        documentReference.delete()
    }
    func startGame(){
        self.currentGameData.is_started=true
        let count=currentGameData.players_id.endIndex
        self.currentGameData.players_hp=Array(repeating: 0, count: count)
        self.currentGameData.players_sp=Array(repeating: 0, count: count)
        self.currentGameData.players_atk=Array(repeating: 0, count: count)
        self.currentGameData.players_role=Array(repeating: "", count: count)
        self.currentGameData.attacking_pos=Array(repeating: -1, count: count)
        //        self.currentGameData.moving=Array(repeating: false, count: count)
        self.currentGameData.players_last_pos=Array(repeating: 0, count: count)
        self.currentGameData.players_x=Array(repeating: 0, count: count)
        self.currentGameData.players_y=Array(repeating: 0, count: count)
        for i in 0..<count{
            self.currentGameData.players_order.append(i)
        }
        
        self.currentGameData.players_order.shuffle()
        
        let pos_x_array=[0,0,15,15]
        let pos_y_array=[0,15,0,15]
        for i in self.currentGameData.players_id.indices{
            self.currentGameData.players_x[i]=pos_x_array[self.currentGameData.players_order[i]]
            self.currentGameData.players_y[i]=pos_y_array[self.currentGameData.players_order[i]]
            self.currentGameData.players_last_pos[i]=self.currentGameData.players_x[i]+self.currentGameData.players_y[i]*16
            print("\(self.currentGameData.players_y[i]):\(i):FUCK")
        }
        
        
        self.UpdateGame()
        print(currentGameData.players_order)
        
    }
    func refreshGame(){
        if self.currentGameData.players_id.endIndex != self.userDatas.endIndex{
            self.CatchUserData()
        }
        self.characters.removeAll()
        for i in self.userDatas.indices{
            self.characters.append(Character(char: self.userDatas[i].char, hair: self.userDatas[i].hair, shirt: self.userDatas[i].shirt, pants: self.userDatas[i].pants, shoes: self.userDatas[i].shoes))
        }
        for i in self.currentGameData.players_id.indices{
            print("MyIndex:\(Auth.auth().currentUser!.uid):\(i)")
            if Auth.auth().currentUser!.uid == self.currentGameData.players_id[i]{
                self.my_order=self.currentGameData.players_order[i]
                self.my_index=i
                print(self.my_index)
            }
        }
        var object_pos=[Int]()
        for i in self.currentGameData.players_id.indices{
            object_pos.append(self.currentGameData.players_x[i]+self.currentGameData.players_y[i]*16)
            self.object_board[object_pos[i]].index=i
        }
        
        
        for i in self.object_board.indices{
            if self.object_board[i].object == .player,!object_pos.contains(i){
                self.object_board[i]=object_tile()
            }
        }
        
        
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
        self.my_role=role
        
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
        self.rank_data=RankData(id: Auth.auth().currentUser!.uid, userName: self.userDatas[self.my_index].userNickName, total_damage: 0)
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
        if self.can_action,self.player_is_front(){
            self.can_action=false
            self.can_rest=false
            var attacking_pos = self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
            if self.characters[self.now_index].action==0{//down
                attacking_pos+=16
            }else if self.characters[self.now_index].action==1{//up
                attacking_pos-=16
            }else if self.characters[self.now_index].action==2{//right
                attacking_pos+=1
            }else if self.characters[self.now_index].action==3{//left
                attacking_pos-=1
            }
            self.currentGameData.attacking_pos[self.now_index]=attacking_pos
            self.currentGameData.players_hp[self.object_board[attacking_pos].index]-=self.currentGameData.players_atk[self.now_index]
            self.rank_data.total_damage+=self.currentGameData.players_atk[self.now_index]
            self.currentGameData.players_sp[self.now_index]-=1
            if self.currentGameData.players_hp[self.object_board[attacking_pos].index]<=0{
                self.kill_player(killed_index:self.object_board[attacking_pos].index,killed_board_index: attacking_pos)
            }
            self.refreshGame()
            self.UpdateGame()
        }
    }
    func kill_player(killed_index:Int,killed_board_index:Int){
        
        self.currentGameData.players_id.remove(at: killed_index)
        self.currentGameData.attacking_pos.remove(at: killed_index)
        self.currentGameData.players_hp.remove(at: killed_index)
        self.currentGameData.players_sp.remove(at: killed_index)
        self.currentGameData.players_atk.remove(at: killed_index)
        self.currentGameData.players_role.remove(at: killed_index)
        self.currentGameData.players_last_pos.remove(at: killed_index)
        self.currentGameData.players_x.remove(at: killed_index)
        self.currentGameData.players_y.remove(at: killed_index)
        let killed_order=self.currentGameData.players_order[killed_index]
        for i in self.currentGameData.players_order.indices{
            if i != killed_index,self.currentGameData.players_order[i]>killed_order{
                self.currentGameData.players_order[i]-=1
            }
        }
        self.currentGameData.players_order.remove(at: killed_index)
        
        self.characters.remove(at: killed_index)
        if self.currentGameData.order>killed_order{
            self.currentGameData.order-=1
        }
        self.now_order=self.currentGameData.order
        for i in self.currentGameData.players_order.indices{
            if self.currentGameData.players_order[i] == self.now_order{
                self.now_index=i
                break
            }
        }
    }
    func attack_animation(){
        let now_player_board_pos=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
        let direction=self.currentGameData.attacking_pos[self.now_index]-now_player_board_pos
        if direction==16{//down
            self.characters[self.now_index].action=0+4
        }else if direction == -16{//up
            self.characters[self.now_index].action=1+4
        }else if direction==1{//right
            self.characters[self.now_index].action=2+4
        }else if direction == -1{//left
            self.characters[self.now_index].action=3+4
        }
        self.currentGameData.attacking_pos[self.now_index] = -1
        self.slashPlayer.volume=self.SFXvolume
        self.slashPlayer.playFromStart()
        for i in 0..<self.attack_image-1{
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)*0.1) {
                self.characters[self.now_index].animation_id+=1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.attack_image-1)*0.1) {
            self.characters[self.now_index].action-=4
            self.characters[self.now_index].animation_id=0
            if self.now_order==self.my_order{
                if self.currentGameData.players_sp[self.my_index]>0{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    self.can_action=true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                self.can_rest=true
                }
                self.UpdateGame()
            }
        }
        
    }
    func player_is_front()->Bool{
        let now_player_board_pos=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
        if self.characters[self.now_index].action%4==0,now_player_board_pos+16<16*16,self.object_board[now_player_board_pos+16].object == .player{
            return true
        }else if self.characters[self.now_index].action%4==1,now_player_board_pos-16>=0,self.object_board[now_player_board_pos-16].object == .player{
            return true
        }else if self.characters[self.now_index].action%4==2,now_player_board_pos%16+1<16,self.object_board[now_player_board_pos+1].object == .player{
            return true
        }else if self.characters[self.now_index].action%4==3,now_player_board_pos%16-1>=0,self.object_board[now_player_board_pos-1].object == .player{
            return true
        }
        //        for i in 0..<self.currentGameData.players_order.endIndex{
        //            if i != self.now_index{
        //                if self.characters[self.now_index].action%4==1,self.currentGameData.players_x[now_index]==self.currentGameData.players_x[i],self.currentGameData.players_y[now_index]==self.currentGameData.players_y[i]-1{
        //                    print("UP")
        //                    return true
        //                }
        //                else if self.characters[self.now_index].action%4==0,self.currentGameData.players_x[now_index]==self.currentGameData.players_x[i],self.currentGameData.players_y[now_index]==self.currentGameData.players_y[i]+1{
        //                    print("DOWN")
        //                    return true
        //                }
        //                else if self.characters[self.now_index].action%4==3,self.currentGameData.players_x[now_index]==self.currentGameData.players_x[i]-1,self.currentGameData.players_y[now_index]==self.currentGameData.players_y[i]{
        //                    print("LEFT")
        //                    return true
        //                }
        //                else if self.characters[self.now_index].action%4==2,self.currentGameData.players_x[now_index]==self.currentGameData.players_x[i]+1,self.currentGameData.players_y[now_index]==self.currentGameData.players_y[i]{
        //                    print("LEFT")
        //                    return true
        //                }
        //            }
        //        }
        return false
    }
    func move(){
        let now_player_board_pos=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
        if  self.object_board[now_player_board_pos].object != .player{
            withAnimation(.linear(duration: Double(self.move_image)*0.1)){
                self.object_board.swapAt(now_player_board_pos,self.currentGameData.players_last_pos[self.now_index])
            }
            let direction=now_player_board_pos-self.currentGameData.players_last_pos[self.now_index]
            if direction==16{//down
                self.characters[self.now_index].action=0
            }else if direction == -16{//up
                self.characters[self.now_index].action=1
            }else if direction==1{//right
                self.characters[self.now_index].action=2
            }else if direction == -1{//left
                self.characters[self.now_index].action=3
            }
            for i in 0..<self.move_image-1{
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)*0.1) {
                    self.characters[self.now_index].animation_id+=1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.move_image-1)*0.1) {
                
                self.characters[self.now_index].animation_id=0
                if self.my_order==self.now_order{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    if self.currentGameData.players_sp[self.my_index]>0{
                        self.can_action=true
                    }
                    
                    self.can_rest=true
                    }
                }
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
        if self.can_action,self.currentGameData.players_y[self.now_index]>0,!self.player_is_front(){
            
            self.currentGameData.players_last_pos[self.now_index]=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
            self.currentGameData.players_y[self.now_index]-=1
            self.currentGameData.players_sp[self.now_index]-=1
            self.UpdateGame()
            self.can_action=false
            self.can_rest=false
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.move_image)*0.1) {
//                if self.currentGameData.players_sp[self.my_index]>0{
//                    self.can_action=true
//                }
//
//                self.can_rest=true
//            }
            //            self.move()
        }
        
    }
    func move_down(){
        self.characters[self.now_index].action=0
        if self.can_action,self.currentGameData.players_y[self.now_index]<16-1,!self.player_is_front(){
            
            self.currentGameData.players_last_pos[self.now_index]=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
            self.currentGameData.players_y[self.now_index]+=1
            self.currentGameData.players_sp[self.now_index]-=1
            self.UpdateGame()
            self.can_action=false
            print("ACTION")
            print(self.can_action)
            self.can_rest=false
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.move_image)*0.1) {
//                if self.currentGameData.players_sp[self.my_index]>0{
//                    self.can_action=true
//                }
//                print(self.can_action)
//                self.can_rest=true
//            }
            //            self.move()
        }
        
    }
    func move_left(){
        self.characters[self.now_index].action=3
        
        if self.can_action,self.currentGameData.players_x[self.now_index]>0,!self.player_is_front(){
            
            self.currentGameData.players_last_pos[self.now_index]=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
            self.currentGameData.players_x[self.now_index]-=1
            self.currentGameData.players_sp[self.now_index]-=1
            self.UpdateGame()
            self.can_action=false
            self.can_rest=false
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.move_image)*0.1) {
//                if self.currentGameData.players_sp[self.my_index]>0{
//                    self.can_action=true
//                }
//
//                self.can_rest=true
//            }
            //            self.move()
            
        }
        //        self.move()
        
    }
    func move_right(){
        self.characters[self.now_index].action=2
        if self.can_action,self.currentGameData.players_x[self.now_index]<16-1,!self.player_is_front(){
            
            self.currentGameData.players_last_pos[self.now_index]=self.currentGameData.players_x[self.now_index]+self.currentGameData.players_y[self.now_index]*16
            self.currentGameData.players_x[self.now_index]+=1
            self.currentGameData.players_sp[self.now_index]-=1
            self.UpdateGame()
            self.can_action=false
            self.can_rest=false
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.move_image)*0.1) {
//                if self.currentGameData.players_sp[self.my_index]>0{
//                    self.can_action=true
//                }
//
//                self.can_rest=true
//            }
            //            self.move()
        }
        
        
    }
    func use_item(){
        print("HI")
    }
    func rest(){
        self.currentGameData.turn+=1
        self.currentGameData.order+=1
        if self.currentGameData.order >= self.currentGameData.players_id.endIndex{
            self.currentGameData.order=0
        }
        //        for i in self.currentGameData.players_order.indices{
        //            if self.currentGameData.turn%self.currentGameData.players_order.endIndex==self.currentGameData.players_order[i]{
        //                self.now_index=i
        //                self.now_order=self.currentGameData.players_order[i]
        //
        //            }
        //        }
        if self.my_role=="探險家"{
            self.currentGameData.players_sp[self.my_index]+=5
        }else if self.my_role=="戰士"{
            self.currentGameData.players_sp[self.my_index]+=3
        }else{
            self.currentGameData.players_sp[self.my_index]+=4
        }
        
        self.UpdateGame()
        
    }
    
}
