//
//  Ticket.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//
import Foundation

struct Ticket: Codable {
    var id: Int
    var lotteryId: Int
    var pictureUrl: URL?
    var date: TimeInterval
    var numbers: [[Int]]

    // Existing initializer
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

    // New initializer
    init(id: Int, lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]]) {
        self.id = id
        self.lotteryId = lotteryId
        self.pictureUrl = pictureUrl
        self.date = date
        self.numbers = numbers
    }
}
