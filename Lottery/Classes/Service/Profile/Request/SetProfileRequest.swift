//
//  SetProfileRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct SetProfileRequest: EndPoint {
    let userToken: String
    let lotteries: [Int]?
    let state: Int?
    
    var path: String {
        "/api/profile/set"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        var params: [String: Any] = [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken
        ]
        if let lotteries = lotteries {
            params["lotteries"] = lotteries
        }
        if let state = state {
            params["state"] = state
        }
        return params
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json"
        ]
    }
}
