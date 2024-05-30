//
//  Game.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct Game: Codable {
    let id: Int
    let lotteryId: Int
    let date: TimeInterval
    let jackpot: String
    let cashValue: String?
    let winningNumbers: [[Int]]?
    let myLuckyNumbers: [[Int]]?

    init?(response: Any) {
        guard let dict = response as? [String: Any],
              let id = dict["id"] as? Int,
              let lotteryId = dict["lottery_id"] as? Int,
              let date = dict["date"] as? TimeInterval,
              let jackpot = dict["jackpot"] as? String else {
            return nil
        }
        self.id = id
        self.lotteryId = lotteryId
        self.date = date
        self.jackpot = jackpot
        self.cashValue = dict["cash_value"] as? String
        self.winningNumbers = dict["winning_numbers"] as? [[Int]]
        self.myLuckyNumbers = dict["my_lucky_numbers"] as? [[Int]]
    }
}
