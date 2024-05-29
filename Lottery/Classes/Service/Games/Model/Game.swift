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
}
