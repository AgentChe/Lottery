//
//  FetchStatesRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct FetchStatesRequest: EndPoint {
    let userToken: String
    
    var path: String {
        "/api/states"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken
        ]
    }
    
    var headers: [String : String] {
        [:]
    }
}
