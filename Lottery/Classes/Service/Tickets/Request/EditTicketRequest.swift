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
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "id": id,
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
