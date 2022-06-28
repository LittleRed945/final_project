//
//  UserData.swift
//  TEST
//
//  Created by  Erwin on 2022/5/31.
//
import Foundation
import SwiftUI
import FirebaseFirestoreSwift
struct UserData: Codable, Identifiable {
    @DocumentID var id: String?
    let userNickName:String
    let userGender: String
    let userBD: String
    let userFirstLogin: String
    var coin=0
    var char="01"
    var hair="01"
    var shirt="01"
    var pants="01"
    var shoes="01"
}
