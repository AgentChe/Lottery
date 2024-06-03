//
//  GetProfileRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct GetProfileRequest: EndPoint {
    let userToken: String
    
    var path: String {
        "/api/profile/get"
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
