//
//  Delay.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//

import UIKit

func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

func getRootViewController() -> UIViewController? {
    // Iterate through connected scenes
    for scene in UIApplication.shared.connectedScenes {
        // Check if the scene is a UIWindowScene
        if let windowScene = scene as? UIWindowScene {
            // Retrieve the SceneDelegate
            if let sceneDelegate = windowScene.delegate as? SceneDelegate {
                // Return the root view controller
                return sceneDelegate.window?.rootViewController
            }
        }
    }
    return nil
}
