//
//  SyncTokensRequest.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

struct SyncTokensRequest: EndPoint {
    let oldToken: String
    let newToken: String
    
    var path: String {
        "/api/users/set"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "user_token": newToken,
            "_user_token": oldToken
        ]
    }
    
    var headers: [String : String] {
        [:]
    }
}
