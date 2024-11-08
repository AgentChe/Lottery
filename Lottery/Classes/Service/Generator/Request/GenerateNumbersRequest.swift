//
//  GenerateNumbersRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/8/24.
//

import Foundation

struct GenerateNumbersRequest: EndPoint {
    var path: String { return "/generator" }
    var method: HTTPMethod { return .post }
    var headers: [String: String] { return ["Content-Type": "application/json"] }
    var parameters: [String: Any] {
        return [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken,
            "lotteryId": lotteryId,
            "lines": lines
        ]
    }

    let userToken: String
    let lotteryId: Int
    let lines: Int
}
