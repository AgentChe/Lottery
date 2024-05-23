//
//  LoginResult.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

enum LoginResult {
    case success
    case error(Error)
    
    init(error: Error?) {
        if let error {
            self = .error(error)
        } else {
            self = .success
        }
    }
}
