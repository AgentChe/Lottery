//
//  Delay.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//

import Foundation
func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}
