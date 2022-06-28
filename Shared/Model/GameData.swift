
import Foundation
import SwiftUI
import FirebaseFirestoreSwift
struct GameData: Codable, Identifiable {
    @DocumentID var id: String?
    var players_id = [String]()
    var players_hp = [Int]()
    var players_sp = [Int]()
    var players_atk = [Int]()
    var players_role=[String]()
    var attacking_pos=[Int]()
    var players_last_pos=[Int]()
    var players_x = [Int]()
    var players_y = [Int]()
    var players_order=[Int]()
    var turn=0
    var order=0
    var allReady=false
//    let player1_id : String
//    let player2_id : String
//    let player3_id : String
//    let player4_id : String
    //let invite_code:String
    var is_started=false
}
