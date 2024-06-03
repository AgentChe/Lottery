//
//  AddLotteryRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct AddLotteryRequest: EndPoint {
    let name: String
    let stateId: Int
    let userToken: String
    
    var path: String {
        "/api/lotteries/add"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken,
            "name": name,
            "state_id": stateId
        ]
    }
    
    var headers: [String : String] {
        [:]
    }
}
