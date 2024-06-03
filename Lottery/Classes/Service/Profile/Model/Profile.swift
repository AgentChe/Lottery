//
//  Profile.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct Profile: Codable {
    let lotteries: [Int]?
    let state: Int?
    
    init?(response: Any) {
        guard let response = response as? [String: Any] else {
            return nil
        }
        
        self.lotteries = response["lotteries"] as? [Int]
        self.state = response["state"] as? Int
    }
    
    init(lotteries: [Int]?, state: Int?) {
        self.lotteries = lotteries
        self.state = state
    }
}
