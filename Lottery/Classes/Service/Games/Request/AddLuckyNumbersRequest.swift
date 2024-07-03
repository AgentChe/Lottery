//
//  AddLuckyNumbersRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct AddLuckyNumbersRequest: EndPoint {
  
    let lotteryId: Int
    let numbers: [[Int]]
    let userToken: String
    let date: TimeInterval
 
    var path: String {
        "/api/games/luckynumbers/add"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "user_token": userToken,
            "api_key": GlobalDefinitions.apiKey,
            "numbers": numbers,
            "lotteryId": lotteryId,
            "date": date
        ]
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json"
        ]
    }
}
