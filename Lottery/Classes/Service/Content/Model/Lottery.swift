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
    let stateId: Int

    init?(response: Any) {
        guard let dict = response as? [String: Any],
              let id = dict["id"] as? Int,
              let name = dict["name"] as? String,
              let logoUrlString = dict["logo_url"] as? String,
              let logoUrl = URL(string: logoUrlString),
              let stateId = dict["state_id"] as? Int else {
            return nil
        }
        self.id = id
        self.name = name
        self.logoUrl = logoUrl
        self.stateId = stateId
    }
}
