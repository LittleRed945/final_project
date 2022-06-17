//
//  RegisterView.swift
//  TEST
//
//  Created by  Erwin on 2022/5/31.
//

import Foundation
import SwiftUI
import FirebaseAuth
struct RegisterView:View{
    let userViewModel=UserViewModel()
    @State private var mail = ""
    @State private var password = ""
    @State private var confirm_password = ""
    @State private var showAlert = false
    @State private var alertMsg = ""
    @State private var myAlert = Alert(title: Text(""))
    @State private var showFLView=false
    var body: some View{
        VStack(spacing:0){
            TextField("Email",text:$mail).textFieldStyle(MyTextFieldStyle())
                .padding(.leading)
            TextField("Password",text:$password).textFieldStyle(MyTextFieldStyle())
                .padding(.leading)
            HStack{
                TextField("Confirm Password",text:$confirm_password).textFieldStyle(MyTextFieldStyle())
                    .padding(.leading)
                
                if password != confirm_password {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                        .offset(x:-10)
                } else if password != "" {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.largeTitle)
                        .offset(x:-10)
                }
            }
            HStack{
                Button(action: {
                    if password != confirm_password {
                        showAlertMsg(msg: "兩次密碼不一致")
                    }else{
                        userViewModel.createUser(userEmail: mail, password: password){
                            (result) in
                            switch result {
                            case .success( _):
                                showAlertMsg(msg: "註冊成功")
                            case .failure(let errormsg):
                                print("註冊失敗")
                                switch errormsg {
                                case .emailFormat:
                                    showAlertMsg(msg: "電子郵件格式不正確")
                                case .emailUsed:
                                    showAlertMsg(msg: "電子郵件已被註冊")
                                case .pwtooShort:
                                    showAlertMsg(msg: "密碼長度需至少大於6")
                                case .others:
                                    showAlertMsg(msg: "不明原因錯誤，請重新註冊")
                                }
                                break
                            }
                        }
                    }
                }, label: {
                    ZStack{Image("button")
                        Text("送出").foregroundColor(.black)
                    }
                    })
            }
        }
        .navigationTitle("註冊")
        .background(Image("background").edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showAlert) { () -> Alert in
                            return myAlert
                        }
        .fullScreenCover(isPresented:$showFLView){
            FirstLoginView(mail:mail,password: password)
        }
    }
    func go2FirstLoginView() -> Void {
        print(Auth.auth().currentUser!.uid)
//        self.presentationMode.wrappedValue.dismiss()
        self.showFLView = true
    }
    
    func showAlertMsg(msg: String) -> Void {
        self.alertMsg = msg
        if alertMsg == "註冊成功" {
            self.myAlert = Alert(title: Text("成功"), message: Text(alertMsg), dismissButton: .cancel(Text("前往設置個人資料"), action:go2FirstLoginView))
            //
            self.showAlert = true
        }
        else {
            self.myAlert = Alert(title: Text("錯誤"), message: Text(alertMsg), dismissButton: .cancel(Text("重新輸入")))
            self.showAlert = true
        }
    }
}
