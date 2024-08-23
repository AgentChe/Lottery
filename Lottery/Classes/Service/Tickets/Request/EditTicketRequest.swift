//
//  EditTicketRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//
import Foundation

struct EditTicketRequest: EndPoint {
    let userToken: String
    let id: Int
    let lotteryId: Int
    let pictureUrl: URL?
    let date: TimeInterval
    let numbers: [[Int]]
    
    var path: String {
        "/api/tickets/edit"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        var params: [String: Any] = [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken,
            "id": id,
            "lotteryId": lotteryId,
            "date": date,
            "numbers": numbers
        ]
        
        if let imageUrl = pictureUrl?.absoluteString {
            params["image_url"] = imageUrl
        }
        
        return params
    }
    
    var headers: [String : String] {
        [
            "Content-Type": "application/json"
        ]
    }
}
