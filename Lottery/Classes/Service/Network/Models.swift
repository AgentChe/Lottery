//
//  Models.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/28/24.
//

import Foundation

struct State: Codable {
    let id: Int
    let name: String
}

struct Lottery: Codable {
    let id: Int
    let name: String
    let logoUrl: String
    let stateId: Int
}

struct Game: Codable {
    let id: Int
    let lotteryId: Int
    let date: TimeInterval
    let jackpot: Double
    let cashValue: Double
    let winningNumbers: [[Int]]?
    let myLuckyNumbers: [[Int]]?
}

struct Ticket: Codable {
    let id: Int
    let lotteryId: Int
    let pictureUrl: String?
    let date: TimeInterval
    let numbers: [[Int]]
}
struct Profile: Codable {
    let lotteries: [Int]?
    let state: Int?
}
