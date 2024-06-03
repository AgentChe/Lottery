//  SuggestNewGameRequest.swift
//  Lottery
//


import Foundation

struct SuggestNewGameRequest: EndPoint {
    let gameTitle: String
    let userToken: String
    
    var path: String {
        "/api/games/suggest"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String: Any] {
        [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken,
            "game_title": gameTitle
        ]
    }
    
    var headers: [String: String] {
        [:]
    }
}
