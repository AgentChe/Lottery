//
//  Ticket.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//
import Foundation

struct Ticket: Codable {
    let id: Int
    let lotteryId: Int
    let pictureUrl: URL?
    let date: TimeInterval
    var numbers: [[Int]]

    init?(response: Any) {
        guard let dict = response as? [String: Any],
              let id = dict["id"] as? Int,
              let lotteryId = dict["lotteryId"] as? Int,
              let date = dict["date"] as? TimeInterval,
              let numbers = dict["numbers"] as? [[Int]] else {
            return nil
        }
        self.id = id
        self.lotteryId = lotteryId
        self.pictureUrl = URL(string: dict["pictureUrl"] as? String ?? "")
        self.date = date
        self.numbers = numbers
    }
}
