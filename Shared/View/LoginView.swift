//
//  LoginView.swift
//  TEST
//
//  Created by  Erwin on 2022/5/17.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage

import FirebaseFirestoreSwift
struct LoginView:View{
    let userViewModel=UserViewModel()
    @Binding var mail:String
    @Binding var password:String
    @State private var alertMsg = ""
    @State private var showAlert = false
    @State private var showView = false
    @State private var not_first_login = false
    @FirestoreQuery(collectionPath: "users") var users: [UserData]
    var body: some View{
        NavigationView {
            VStack(spacing:5){
                TextField("Email",text:$mail).textFieldStyle(MyTextFieldStyle())
                    .padding(.leading)
                TextField("Password",text:$password).textFieldStyle(MyTextFieldStyle())
                    .padding(.leading)
                
                HStack{
                    Button(action: {
                        userViewModel.userSingIn(userEmail: mail, password: password){
                            (result) in
                            switch result {
                            case .success( _):
                                
                                if let user = Auth.auth().currentUser {
                                    print("\(user.uid) 登入成功")
                                    //                                    for u in users{
                                    //                                        if u.id == user.uid{
                                    //                                            print("DD")
                                    //                                            not_first_login=true
                                    //                                        }
                                    //                                        print(u.userNickName)
                                    //                                        print(u.userBD)
                                    //                                    }
                                    userViewModel.fetchUsers(){
                                        (result) in
                                        switch result {
                                        case .success(let udArray):
                                            print("使用者資料抓取成功")
                                            for u in udArray {
                                                
                                                if u.id == user.uid {
                                                    not_first_login = true
                                                }
                                            }
                                            showView = true
                                            
                                        case .failure(_):
                                            print("使用者資料抓取失敗")
                                            not_first_login = false
                                            //showView = true
                                        }
                                        
                                    }
                                    showView=true
                                } else {
                                    print("登入失敗")
                                }
                            case .failure(let errormsg):
                                switch errormsg {
                                case .pwInvalid:
                                    alertMsg = "密碼錯誤"
                                    showAlert = true
                                case .noAccount:
                                    alertMsg = "帳號不存在，請註冊或使用其他帳號"
                                    showAlert = true
                                case .others:
                                    alertMsg = "不明原因錯誤，請重新登入"
                                    showAlert = true
                                }
                            }
                        }
                    }, label: {
                        ZStack{
                            Image("button")
                            Text("登入").foregroundColor(.black).font(.custom("JackyFont", size: 15))
                            
                        }
                    })
                    if not_first_login{
                        Text("").fullScreenCover(isPresented: $showView)
                        { UserView()}
                    }else{
                        Text("").fullScreenCover(isPresented: $showView)
                        { FirstLoginView(mail: mail, password: password)
                        }
                        
                        
                    }
                    NavigationLink{RegisterView()} label:{
                        ZStack{
                            Image("button")
                            Text("註冊").foregroundColor(.black).font(.custom("JackyFont", size: 15))
                        }
                    }
                }
            }.background(Image("background").edgesIgnoringSafeArea(.all))
                .alert(isPresented: $showAlert) { () -> Alert in
                    return Alert(title: Text("錯誤"), message: Text(alertMsg),  dismissButton: .default(Text("重新輸入")))
                }
        }
        
    }
    
}
