//
//  UserView.swift
//  TEST
//
//  Created by  Erwin on 2022/5/31.
import Foundation
import SwiftUI
import NukeUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestoreSwift
struct UserView: View {
    let userViewModel=UserViewModel()
    @State private var currentUser = Auth.auth().currentUser
    @State private var userPhotoURL = URL(string: "")
    @State private var currentUserData = UserData(id: "", userNickName: "", userGender: "", userBD: "", userFirstLogin: "")
    
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Text("個人資料")
                        .font(.system(size: 27))
                        .bold()
                    HStack{
                        Spacer()
                        LazyImage(source:userPhotoURL)
                            .frame(width: 100, height: 150)
                        Spacer()
                    }
                    Group{
                        HStack{
                            Image(systemName: "person.crop.circle")
                            if currentUser?.displayName != nil {
                                Text("暱稱: " + (currentUser?.displayName)!)
                            } else {
                                Text("暱稱錯誤")
                            }
                        }
                        HStack{
                            Image(systemName: "g.circle")
                            Text("性別" + currentUserData.userGender)
                            
                        }
                        HStack{
                            Image(systemName: "calendar")
                            Text("生日"+currentUserData.userBD)
                            
                        }
                        HStack{
                            Image(systemName: "clock")
                            Text("首次登入: " + currentUserData.userFirstLogin)
                        }
                        HStack{
                            Image(systemName: "face.smiling")
                            Text("UID: " + currentUser!.uid)
                        }
                    }
//                    Button(action: {
//                        userViewModel.userSingOut()
//                    }, label: {
//                        ZStack{
//                            Image("button")
//                            Text("登出")
//                        }
//                    })
                }
                
                
            }.onAppear(){
                userPhotoURL = (currentUser?.photoURL)
                
                userViewModel.fetchUsers(){
                    (result) in
                    switch result {
                    case .success(let udArray):
                        print("使用者資料抓取成功")
                        for u in udArray {
                            
                            if u.id == currentUser?.uid {
                                currentUserData = u
                                break
                            }
                        }
                        
                        
                    case .failure(_):
                        print("使用者資料抓取失敗")
                        //showView = true
                    }
                    
                }
                   
            }
        }
    }
}
