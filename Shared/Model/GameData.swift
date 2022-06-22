
import Foundation
import SwiftUI
import FirebaseFirestoreSwift
struct GameData: Codable, Identifiable {
    @DocumentID var id: String?
    let player1_id : String
    let player2_id : String
    let player3_id : String
    let player4_id : String
    //let invite_code:String
    var player1_hp=0
    var player1_sp=0
    var player2_hp=0
    var player2_sp=0
    var player3_hp=0
    var player3_sp=0
    var player4_hp=0
    var player4_sp=0
}
