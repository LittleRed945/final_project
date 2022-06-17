//
//  CustomizeCharacterView.swift
//  TEST
//
//  Created by  Erwin on 2022/5/18.
//

import Foundation
import SwiftUI
import FirebaseAuth
struct CustomizedCharacterView:View{
    //character model
    @State private var character=Character()
    //
    @State private var show_style_all=false
    @State private var now_style:Style = .none
    @State private var hair_contrast:Double=1
    @State private var shirt_contrast:Double=1
    @State private var pants_contrast:Double=1
    @State private var shoes_contrast:Double=1
    //alert
    @State private var showAlert = false
    @State private var alertMsg = ""
    @State private var myAlert = Alert(title: Text(""))
    //
    //show user view
    @State private var showUView=false
    var characterView:some View{
        ZStack{
            Image("char\(character.char)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: 108, height: 108).offset(character.offset)
            Image("hair\(character.hair)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: 108, height: 108).offset(character.offset)
            Image("shirt\(character.shirt)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: 108, height: 108).offset(character.offset)
            Image("pants\(character.pants)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: 108, height: 108).offset(character.offset)
            Image("shoes\(character.shoes)-\(character.direction)-\(character.action)").resizable().scaledToFit().frame(width: 108, height: 108).offset(character.offset)
        }
    }
    var body: some View{
        HStack(spacing:0.0){
            ShowComponentsView(character: $character, style_name: now_style)
            VStack(spacing: 0.0){
                
                //                    Button("down"){
                //                        character.action=(character.action+1)%8
                //                        character.offset.height+=1
                //                    }.
                //
                //                    Button("change direction"){
                //                        character.direction=(character.direction+1)%4
                //                    }
                Button(action: {
                    show_style_all=true
                    now_style = .hair
                    hair_contrast=1
                    shirt_contrast=0.5
                    pants_contrast=0.5
                    shoes_contrast=0.5
                }, label: {
                    Image("hair_button").contrast(hair_contrast)
                    //.resizable().scaledToFit().frame(width: 108, height: 108)
                })
                Button(action: {
                    show_style_all=true
                    now_style = .shirt
                    hair_contrast=0.5
                    shirt_contrast=1
                    pants_contrast=0.5
                    shoes_contrast=0.5
                }, label: {
                    Image("hair_button").contrast(shirt_contrast)
                })
                Button(action: {
                    show_style_all=true
                    now_style = .pants
                    hair_contrast=0.5
                    shirt_contrast=0.5
                    pants_contrast=1
                    shoes_contrast=0.5
                }, label: {
                    Image("pants_button").contrast(pants_contrast)
                })
                Button(action: {
                    show_style_all=true
                    now_style = .shoes
                    hair_contrast=0.5
                    shirt_contrast=0.5
                    pants_contrast=0.5
                    shoes_contrast=1
                }, label: {
                    Image("shoes_button").contrast(shoes_contrast)
                })
                Button(action: {
                    character.hair="0"+String(Int.random(in: 1...2))
                    character.shirt="0"+String(Int.random(in: 1...2))
                    character.pants="0"+String(Int.random(in: 1...2))
                    character.shoes="0"+String(Int.random(in: 1...1))
                }, label: {
                    Image("random_button")
                })
                
            }
            Spacer()
            characterView
            Spacer()
            Button(action: {
                uploadCharacterPhoto(img: characterView.snapshot())
            }, label: {
                ZStack{
                    Image("button")
                    Text("送出").foregroundColor(.black)
                }
            })
        }.alert(isPresented: $showAlert) { () -> Alert in
            return myAlert
        }
        .background(Image("background").resizable().scaledToFill())
            .fullScreenCover(isPresented:$showUView){
                UserView()
            }
    }
    func go2UserView() -> Void {
        print(Auth.auth().currentUser!.uid)
//        self.presentationMode.wrappedValue.dismiss()
        self.showUView = true
        print("C8763")
        print(self.showUView)
    }
    func uploadCharacterPhoto(img:UIImage) -> Void {
        
        let userViewModel=UserViewModel()
        userViewModel.uploadPhoto(image: img) { result in
            
            switch result {
            case .success(let url):
                print("上傳照片成功")
                userViewModel.setUserPhoto(url: url) { result in
                    switch result {
                    case .success(let msg):
                        print(msg)
                        print("dDDDDDEPPRI")
                        self.showAlert=true
                        print(self.showAlert)
                        self.myAlert=Alert(title: Text("上傳圖片成功"), message: Text(alertMsg), dismissButton: .cancel(Text("確認"),action:go2UserView))
                case .failure(_):
                    print("設置頭像錯誤")
                }
                }
        case .failure(let error):
            print(error)
        }
    }
}
}
//convert a SwiftUI view to an image
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
