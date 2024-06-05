//
//  FetchPastGamesRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct FetchPastGamesRequest: EndPoint {
    let stateId: Int?
    let userToken: String
    
    var path: String {
        "/api/games/past"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        var params = [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken
        ]
        if let stateId = stateId {
            params["state_id"] = "\(stateId)"
        }
        return params
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json"
        ]
    }
}
