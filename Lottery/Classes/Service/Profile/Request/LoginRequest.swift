//
//  LoginRequest.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

struct LoginRequest: EndPoint {
    let userToken: String
    
    var path: String {
        "/api/users/login"
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
        [
            "Content-Type": "application/json"
        ]
    }
}
