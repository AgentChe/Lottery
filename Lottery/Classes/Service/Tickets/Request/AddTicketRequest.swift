//
//  AddTicketRequest.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//
import Foundation

struct AddTicketRequest: EndPoint {
    let userToken: String
    let lotteryId: Int
    let pictureUrl: URL?
    let date: TimeInterval
    let numbers: [[Int]]
    
    var path: String {
        "/api/tickets/add"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any] {
        [
            "api_key": GlobalDefinitions.apiKey,
            "user_token": userToken,
            "lotteryId": lotteryId,
            "pictureUrl": pictureUrl?.absoluteString as Any,
            "date": date,
            "numbers": numbers
        ]
    }
    
    var headers: [String : String] {
        [:]
    }
}
