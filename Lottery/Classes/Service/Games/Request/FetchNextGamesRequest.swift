//
//  FetchNextGamesRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct FetchNextGamesRequest: EndPoint {
    let stateId: Int?
    let userToken: String
    
    var path: String {
        "/api/games/next"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        var params = [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
        if let stateId = stateId {
            params["state_id"] = "\(stateId)"
        }
        return params
    }
    
    var headers: [String : String] {
        [:]
    }
}
