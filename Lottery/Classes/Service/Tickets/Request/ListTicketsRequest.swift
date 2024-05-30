//
//  ListTicketsRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

struct ListTicketsRequest: EndPoint {
    let userToken: String
    
    var path: String {
        "/api/tickets/list"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
    }
    
    var headers: [String : String] {
        [:]
    }
}
