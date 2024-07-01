//
//  Lottery.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct Lottery: Codable {
    let id: Int
    let name: String
    let logoUrl: URL
    let avaliable_states: [Int]

    init?(response: Any) {
        guard let dict = response as? [String: Any],
              let id = dict["id"] as? Int,
              let name = dict["name"] as? String,
              let logoUrlString = dict["logo_url"] as? String,
              let logoUrl = URL(string: logoUrlString),
              let avaliable_states = dict["available_states"] as? [Int] else {
            return nil
        }
        self.id = id
        self.name = name
        self.logoUrl = logoUrl
        self.avaliable_states = avaliable_states
    }
}

