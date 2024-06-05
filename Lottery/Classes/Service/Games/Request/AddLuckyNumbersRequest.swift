//
//  AddLuckyNumbersRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct AddLuckyNumbersRequest: EndPoint {
    let numbers: [[Int]]
    let gameId: Int
    let userToken: String
    
    var path: String {
        "/api/games/luckynumbers/add"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken,
            "numbers": numbers,
            "game_id": gameId
        ]
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json"
        ]
    }
}
