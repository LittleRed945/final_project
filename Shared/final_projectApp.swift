//
//  final_projectApp.swift
//  Shared
//
//  Created by  Erwin on 2022/6/1.
//
import SwiftUI
import Firebase
import GoogleMobileAds
import AVFoundation
@main
struct final_projectApp: App {
    init() {
    FirebaseApp.configure()
    GADMobileAds.sharedInstance().start()
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
