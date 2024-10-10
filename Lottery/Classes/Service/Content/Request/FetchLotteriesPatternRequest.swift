//
//  FetchLotteriesPatternRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/1/24.
//

struct FetchLotteriesPatternRequest: EndPoint {
    let stateId: Int?
    let userToken: String
    
    var path: String {
        "/api/lotteries/patterns"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String: Any] {
        var params: [String: Any] = [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken
        ]
        if let stateId = stateId {
            params["state_id"] = "\(stateId)"
        }
        return params
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json"
        ]
    }
}
