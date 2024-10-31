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
        //window?.rootViewController = OnboardingViewController.make()
        window?.rootViewController = SplashViewController.make()
        //window?.rootViewController = MainViewController.make()
        //window?.rootViewController = NavigationController(rootViewController: TicketsViewController())
        window?.makeKeyAndVisible()
    }
    
}

