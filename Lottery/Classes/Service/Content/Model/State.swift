//
//  State.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct State: Codable {
    let id: Int
    let name: String

    init?(response: Any) {
        guard let dict = response as? [String: Any],
              let id = dict["id"] as? Int,
              let name = dict["name"] as? String else {
            return nil
        }
        self.id = id
        self.name = name
    }
}
