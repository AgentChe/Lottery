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
              let lotteryId = dict["lotteryId"] as? Int,
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
    
    // Convenience initializer
       init(id: Int, lotteryId: Int, date: TimeInterval, jackpot: String, cashValue: String?, winningNumbers: [[Int]]?, myLuckyNumbers: [[Int]]?) {
           self.id = id
           self.lotteryId = lotteryId
           self.date = date
           self.jackpot = jackpot
           self.cashValue = cashValue
           self.winningNumbers = winningNumbers
           self.myLuckyNumbers = myLuckyNumbers
       }
    
}
