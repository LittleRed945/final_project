//
//  UserView.swift
//  TEST
//
//  Created by  Erwin on 2022/5/31.
//

import Foundation
import SwiftUI
import FirebaseAuth
struct FirstLoginView: View {
    let userViewModel=UserViewModel()
    @State private var currentUser = Auth.auth().currentUser
    var mail: String
    var password: String
    @State private var userNickName = ""
    @State private var userGenderSelect = 0
    @State private var userFirstLoginStr = ""
    @State private var userBD = Date()
    @State private var currentDate = Date()
    @State private var showAlert = false
    @State private var myAlert = Alert(title: Text(""))
    @State private var alertMsg = ""
    @State private var showCCView=false
    let myDateFormatter = DateFormatter()
    let flgFormatter = DateFormatter()
    var gender = ["男", "女"]
    var body: some View {
        NavigationView {
            
                VStack{
                    Form{
                        Text("設定個人資料")
                            .font(.system(size: 27))
                            .bold()
                        Group{
                            HStack{
                                Image(systemName: "person.crop.circle")
                                TextField("輸入暱稱", text: $userNickName)
                            }
                            HStack{
                                Image(systemName: "g.circle")
                                Text("性別")
                                Spacer()
                                Picker(selection: $userGenderSelect, label: Text("性別")) {
                                    Text(gender[0]).tag(0)
                                                                    Text(gender[1]).tag(1)
                                }.pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 100)
                                    .shadow(radius: 5)
                            }
                            HStack{
                                Image(systemName: "calendar")
                                Text("生日")
                                Spacer()
                                Text(myDateFormatter.string(from: userBD))
                            }
                            DatePicker("生日", selection: $userBD, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                            
                        }
                        
                    }
                    Button(action: {
                        if userNickName == "" {
                            showAlertMsg(msg:"請輸入暱稱（不可為空）")
                        }else{
                            userViewModel.setUserNickName(userDisplayName: userNickName)
                            let new_user=UserData( userNickName:userNickName, userGender: gender[userGenderSelect] , userBD: myDateFormatter.string(from: userBD), userFirstLogin: userFirstLoginStr)
                            userViewModel.createUserData(ud: new_user, uid:currentUser!.uid){
                                (result) in
                                switch result{
                                case .success(let sucmsg):
                                    showAlertMsg(msg:sucmsg)
                                case .failure(_):
                                    print("創建失敗")
                                    showAlertMsg(msg:"創建失敗，請重新嘗試")
                                }
                                
                            }
                        }
                    }, label: {Text("下一步")})
                        
                }.background(Image("background"))
                .alert(isPresented: $showAlert) { () -> Alert in
                                    return myAlert
                                }
                .fullScreenCover(isPresented:$showCCView){
                    CustomizedCharacterView()
                }
                .navigationBarHidden(true)
                    .onAppear(){
                        myDateFormatter.dateFormat = "y MMM dd"
                        flgFormatter.dateFormat = "y MMM dd HH:mm"
                                        //記錄第一次登入時間
                                        self.userFirstLoginStr = flgFormatter.string(from: currentDate)
                    }
            }
        
    }
    func go2CustomizedCharacterView() -> Void {
        print(Auth.auth().currentUser!.uid)
//        self.presentationMode.wrappedValue.dismiss()
        self.showCCView = true
    }
    func showAlertMsg(msg: String) -> Void {
        self.alertMsg = msg
        if alertMsg == "建立資料成功" {
            self.myAlert = Alert(title: Text("成功"), message: Text(alertMsg), dismissButton: .cancel(Text("前往設置角色外觀"), action:go2CustomizedCharacterView))
            //
            self.showAlert = true
        }
        else {
            self.myAlert = Alert(title: Text("錯誤"), message: Text(alertMsg), dismissButton: .cancel(Text("重新輸入")))
            self.showAlert = true
        }
    }
}
