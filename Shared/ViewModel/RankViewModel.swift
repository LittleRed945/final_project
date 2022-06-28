import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import AVFoundation
class RankViewModel: ObservableObject {
    private let db = Firestore.firestore()
    func createRankData(rd:RankData, uid: String) {
        
        do {
            try db.collection("ranks").document(uid).setData(from: rd)
        } catch {

            print(error)
        }
    }
    func UpdateRank(rd:RankData, uid: String) {
        
        let documentReference =
        db.collection("ranks").document(uid)
        documentReference.getDocument { document, error in
            
            guard let document = document,
                  document.exists,
                  var rank = try? document.data(as: RankData.self)
            else {
                
                self.createRankData(rd:rd, uid: uid)
                return
            }
            
            if rank.total_damage < rd.total_damage{
                do {
                    try documentReference.setData(from: rd)
                } catch {
                    print(error)
                }
            }
            
            
        }
    }
    func fetchRanks(completion: @escaping((Result<[RankData], Error>) -> Void)) {
            
            db.collection("ranks").order(by: "total_damage", descending: true).getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                
                let ranks = snapshot.documents.compactMap { snapshot in
                    try? snapshot.data(as: RankData.self)
                }
                completion(.success(ranks))
                print(ranks)
            }
    }
}
