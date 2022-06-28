
import Foundation
import SwiftUI
import FirebaseFirestoreSwift
struct RankData: Codable, Identifiable {
    @DocumentID var id: String?
    var userName=""
    var total_damage=0
}
