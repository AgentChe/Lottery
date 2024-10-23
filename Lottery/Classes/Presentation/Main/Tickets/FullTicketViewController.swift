//
//  FullTicketViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/23/24.
//

import UIKit

class FullTicketViewController: UIViewController {
    
    let customTransitionManager = FullTicketCustomTransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white  // Customize your background
        
        // Setup custom transition manager
        transitioningDelegate = customTransitionManager
        modalPresentationStyle = .overFullScreen
        
        // Setup the swipe gesture
        customTransitionManager.setupGestureRecognizer(in: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  view.backgroundColor = UIColor.black.withAlphaComponent(0.5)  // Optional dimming
    }
}
