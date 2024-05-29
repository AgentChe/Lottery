//
//  FetchLotteriesRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import RxCocoa
import OtterScaleiOS

struct FetchLotteriesRequest: EndPoint {
    private let sessionManager: SessionManagerProtocol
    let stateId: Int?
    
    init(stateId: Int?, sessionManager: SessionManagerProtocol) {
        self.stateId = stateId
        self.sessionManager = sessionManager
    }
    
    var path: String {
        "/api/lotteries"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String: Any] {
        var params: [String: Any] = [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": sessionManager.getSession()?.userToken ?? ""
        ]
        if let stateId = stateId {
            params["state_id"] = stateId
        }
        return params
    }
    
    var headers: [String: String] {
        [:]
    }
}
