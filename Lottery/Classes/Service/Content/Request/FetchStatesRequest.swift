//
//  FetchStatesRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation
struct FetchStatesRequest: EndPoint {
    private let sessionManager: SessionManagerProtocol

       init(sessionManager: SessionManagerProtocol) {
           self.sessionManager = sessionManager
       }
    
    var path: String {
        "/api/states"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token":  sessionManager.getSession()?.userToken ?? ""
        ]
    }
    
    var headers: [String : String] {
        [:]
    }
}
