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
            "api_key": GlobalDefinitions.apiKey,
            "newToken": newToken,
            "oldToken": oldToken
        ]
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json"
        ]
    }
}
