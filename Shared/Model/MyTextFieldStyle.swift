//
//  MyTextFieldStyle.swift
//  TEST
//
//  Created by  Erwin on 2022/6/1.
//

import Foundation
import SwiftUI
struct MyTextFieldStyle: TextFieldStyle {
    var BurlyWood = Color(red: 222/255, green: 184/255, blue: 135/255)
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .foregroundColor(.black)
        .padding(10)
        .background(BurlyWood)
            .opacity(0.8)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color(red: 0, green: 0, blue: 0), lineWidth: 2)
        ).padding()
    }
}
