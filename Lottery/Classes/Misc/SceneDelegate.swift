//
//  SceneDelegate.swift
//  Soccer
//
//  Created by Андрей Чернышев on 13.09.2022.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
      
        let gamesManager = GamesManager()
        gamesManager.fetchNextGames(stateId: nil, forceUpdate: true) { [weak self] result in
 
        }
        gamesManager.fetchPastGames(stateId: nil, forceUpdate: true) { [weak self] result in
            
        }
      
        let contentManager = ContentManager()
        contentManager.fetchLotteries(forceUpdate: true)  { [weak self] result in
        }
        contentManager.fetchLotteriesPattern(forceUpdate: true) { [weak self] result in
            
        }
        
        let ticketsManager = TicketsManager()
        ticketsManager.listTickets(forceUpdate: true) {
            [weak self] result in
           
        }
          
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplashViewController.make()
        window?.makeKeyAndVisible()
        
        
        // Check if the app was launched by a notification
//        if let notificationResponse = connectionOptions.notificationResponse {
//                   let userInfo = notificationResponse.notification.request.content.userInfo
//                   PushNotificationsManager.shared.received(userInfo: userInfo)
//               }
    }
    private func handleNotification(userInfo: [AnyHashable: Any]) {
           // Extract the notification data
           guard let customData = userInfo["customData"] as? [String: Any],
                 let screen = customData["screen"] as? String else {
               print("Invalid notification payload structure.")
               return
           }

           // Perform navigation or show an alert based on the notification data
           DispatchQueue.main.async {
               if screen == "ticket_details" {
                   self.navigateToTicketDetails()
                   
               } else {
                   self.showAlert(message: "Unhandled screen: \(screen)")
               }
           }
       }

       private func navigateToTicketDetails() {
           let rootViewController = getRootViewController()
           self.showAlert(message: "Unhandled screen: \(rootViewController)")
           
       }

       private func showAlert(message: String) {
           // Show an alert if you want to notify the user of something specific
           guard let rootVC = window?.rootViewController else { return }

           let alertController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

           rootVC.present(alertController, animated: true, completion: nil)
       }
    
}

