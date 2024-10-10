//
//  LotteryPattern.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/1/24.
//

struct LotteryPattern: Codable {
    let id: Int
    let name: String
    let bonusExists: Bool
    let bonusIdx: [Int]
    let itemCount: Int

    init?(response: Any) {
        guard let dict = response as? [String: Any],
              let id = dict["id"] as? Int,
              let name = dict["name"] as? String,
              let bonusExists = dict["bonus_exists"] as? Bool,
              let bonusIdx = dict["bonus_idx"] as? [Int],
              let itemCount = dict["item_count"] as? Int else {
            return nil
        }
        self.id = id
        self.name = name
        self.bonusExists = bonusExists
        self.bonusIdx = bonusIdx
        self.itemCount = itemCount
    }
}
