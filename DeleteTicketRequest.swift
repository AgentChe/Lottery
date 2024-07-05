//
//  DeleteTicketRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 7/5/24.
//

import Foundation
struct DeleteTicketRequest: EndPoint {
    let userToken: String
    let id:Int
    
    var path: String {
        "/api/tickets/delete"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken,
            "id":id
        ]
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json",
        ]
    }
}
