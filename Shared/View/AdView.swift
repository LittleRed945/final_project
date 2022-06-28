//import SwiftUI
//import GoogleMobileAds
//import UIKit
//extension UIViewController {
//    static func getLastPresentedViewController() -> UIViewController? {
//        let scene = UIApplication.shared.connectedScenes
//            .filter { $0.activationState == .foregroundActive }
//            .first { $0 is UIWindowScene } as? UIWindowScene
//        let window = scene?.windows.first { $0.isKeyWindow }
//        var presentedViewController = window?.rootViewController
//        while presentedViewController?.presentedViewController != nil {
//            presentedViewController = presentedViewController?.presentedViewController
//        }
//        return presentedViewController
//    }
//}
//struct AdView: View {
//    @State private var ad: GADRewardedAd?
//    
//    var body: some View {
//        VStack {
//            Button("Load Ad") {
//                loadAd()
//            }
//            Button("Show Ad") {
//                showAd()
//            }
//        }
//    }
//    func loadAd() {
//        let request = GADRequest()
//        
//        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request) {ad, error in
//            
//            if let error = error {
//                print(error)
//                return
//            }
//            self.ad = ad
//        }
//    }
//    func showAd() {
//        if let ad = ad,
//           let controller = UIViewController.getLastPresentedViewController() {
//            
//            ad.present(fromRootViewController: controller) {
//                // 影片播放一段時間後觸發
//                print("獲得獎勵")
//            }
//            
//        }
//    }
//    
//}
//
//
