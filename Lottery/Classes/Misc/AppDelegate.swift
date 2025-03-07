//
//  AppDelegate.swift
//  Soccer
//
//  Created by Андрей Чернышев on 13.09.2022.
//

import UIKit
import OtterScaleiOS

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NumberLaunches().launch()
        
        FacebookManager.shared.initialize(app: application, launchOptions: launchOptions)
        AmplitudeManager.shared.initialize()
        FirebaseManager.shared.initialize()
        OtterScale.shared.initialize(host: GlobalDefinitions.otterScaleHost, apiKey: GlobalDefinitions.otterScaleApiKey)
        
        PurchaseValidationObserver.shared.startObserve()
        IAPManager.initialize()
        
        _ = PushNotificationsManager.shared
        
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        FacebookManager.shared.application(app, open: url, options: options)
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationsManager.shared.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationsManager.shared.application(didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        //PushNotificationsManager.shared.application(didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
//    }
}

extension UIImage {
    func cropByPercentage(xPercent: CGFloat, yPercent: CGFloat, widthPercent: CGFloat, heightPercent: CGFloat) -> UIImage? {
        let imageWidth = self.size.width
        let imageHeight = self.size.height
        
        let x = imageWidth * xPercent
        let y = imageHeight * yPercent
        let width = imageWidth * widthPercent
        let height = imageHeight * heightPercent
        
        let cropRect = CGRect(x: x, y: y, width: width, height: height)
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
