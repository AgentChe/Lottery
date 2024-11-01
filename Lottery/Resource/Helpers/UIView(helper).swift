//
//  UIView(helper).swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/17/24.
//

import UIKit
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    var viewController: UIViewController? {
           var nextResponder: UIResponder? = self
           while let responder = nextResponder {
               if let viewController = responder as? UIViewController {
                   return viewController
               }
               nextResponder = responder.next
           }
           return nil
       }
}

