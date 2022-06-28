//
//  LobbyView.swift
//  final_project (iOS)
//
//  Created by  Erwin on 2022/6/20.
//

import Foundation
import AVFoundation
import SwiftUI
import FirebaseAuth
import GoogleMobileAds
import UIKit
import NukeUI
extension UIViewController {
    static func getLastPresentedViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first { $0 is UIWindowScene } as? UIWindowScene
        let window = scene?.windows.first { $0.isKeyWindow }
        var presentedViewController = window?.rootViewController
        while presentedViewController?.presentedViewController != nil {
            presentedViewController = presentedViewController?.presentedViewController
        }
        return presentedViewController
    }
}
struct HomeView:View{
    @State private var ad: GADRewardedAd?
    var uiColor1=Color(red: 0.5, green: 101/256, blue: 65/256)
    var uiColor2=Color(red: 199/256, green: 184/256, blue: 143/256)
    @StateObject var gameViewModel=GameViewModel()
    @State private var invite_code=""
    @State private var isCreateLobby = false
    @State private var isJoinLobby = false
    @State private var lobbyExist=false
    @State private var userData=UserData(id: "", userNickName: "", userGender: "", userBD: "", userFirstLogin: "")
    @State private var show_instructions=false
    let userViewModel=UserViewModel()
    //設定navigation bar的背景顏色
    func configureBackground() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor(uiColor1)
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
    }
    func joinTheLobby()->AnyView{
        
        if lobbyExist{
            return AnyView(LobbyView(gameViewModel:gameViewModel))
        }else{
            return AnyView(Text("找不到房間"))
        }
    }
    //ad
    func loadAd() {
        let request = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request) {ad, error in
            
            if let error = error {
                print(error)
                return
            }
            self.ad = ad
        }
    }
    func showAd() {
        if let ad = ad,
           let controller = UIViewController.getLastPresentedViewController() {
            
            ad.present(fromRootViewController: controller) {
                // 影片播放一段時間後觸發
                print("獲得獎勵")
                self.userData.coin+=100
                self.userViewModel.updataUserData(ud: self.userData, uid: Auth.auth().currentUser!.uid)
            }
            
            print("吉掰\(self.userData.id)")
        }
    }
    init() {
        configureBackground()
        
            
    }
    var body:some View{
        NavigationView{
            VStack{
                
                HStack(spacing:0){
                    Spacer().frame(width:20)
                    ZStack{
                        Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/2-30, height:  UIScreen.main.bounds.height-100)
                    }.overlay{
                        ZStack{
                            Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width/2-50, height:  UIScreen.main.bounds.height-120)
                            NavigationLink(destination:LobbyView(gameViewModel:gameViewModel),isActive: $isCreateLobby, label:{
                                Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width)/2-70 , height:35 ).overlay(){
                                    Text("創建房間").foregroundColor(.black).font(.system( size: 30))
                                }
                            }).onChange(of: isCreateLobby){(new_value) in
                                if new_value{
                                    
                                    gameViewModel.createLobby()
                                }
                                
                            }
                        }
                    }
                    Spacer().frame(width:20).onAppear{
                        userViewModel.fetchUsers(){(result) in
                                    switch result {
                                    case .success(let udArray):
                                        print("使用者資料抓取成功")
                                        for u in udArray {
                                            
                                            if u.id == Auth.auth().currentUser?.uid {
                                                userData = u
                                                break
                                            }
                                        }
                                        
                                        
                                    case .failure(_):
                                        print("使用者資料抓取失敗")
                                        //showView = true
                                    }
                                    
                                }
                    }
                    ZStack{
                        Rectangle().fill(uiColor1).frame(width: UIScreen.main.bounds.width/2-30, height:  UIScreen.main.bounds.height-100)
                    }.overlay{
                        ZStack{
                            Rectangle().fill(uiColor2).frame(width: UIScreen.main.bounds.width/2-50, height:  UIScreen.main.bounds.height-120)
                            VStack{
                                TextField("邀請碼",text:$invite_code).textFieldStyle(MyTextFieldStyle())
                            NavigationLink(destination:joinTheLobby(),isActive: $isJoinLobby, label:{
                                
                            
                                Rectangle().stroke(.black,lineWidth: 7).frame(width:(UIScreen.main.bounds.width)/2-70 , height:35 ).overlay(){
                                    Text("加入房間").foregroundColor(.black).font(.system( size: 30))
                                }
                                
                            }).onChange(of: isJoinLobby){(new_value) in
                                if new_value{
                                    
                                    gameViewModel.joinLobby(invite_code: invite_code){
                                        (result) in
                                        switch result{
                                        case .success(_):
                                            print("遊戲資料抓取成功")
                                            lobbyExist=true
                                            
                                        case .failure(_):
                                            print("使用者資料抓取失敗")
                                            lobbyExist=false
                                            
                                        }
                                    }
                                }
                                
                            }
                            }
                        }
                    }
                    Spacer().frame(width:20)
                }
                
            }.edgesIgnoringSafeArea(.all)
                .background(Image("background"))
                .toolbar{
                ToolbarItemGroup(placement: .cancellationAction) {
                        
                    HStack{
                        NavigationLink{RankView()} label:{
                            Image(systemName: "chart.bar.fill").foregroundColor(uiColor2)
                        }
                        
                        NavigationLink{UserView()} label:{
                            Image(systemName: "person.fill").foregroundColor(uiColor2)
                        }
                        NavigationLink{InstructionView()} label:{
                            Image(systemName:"questionmark.circle.fill").foregroundColor(uiColor2)
                        }
                    }
                        
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        HStack{
                            Text("硬幣數量：\(userData.coin)").foregroundColor(uiColor2)
                            Button(action: {
                                loadAd()
                                
                                showAd()
                                
                            }, label: {
                                Image(systemName: "plus").foregroundColor(uiColor2)
                            })
                        }
                        NavigationLink{SettingView(gameViewModel: gameViewModel)} label:{
                            Image(systemName: "gearshape.fill").foregroundColor(uiColor2)
                        }
                        
                    }
                }
                
            
        }
    }
}
