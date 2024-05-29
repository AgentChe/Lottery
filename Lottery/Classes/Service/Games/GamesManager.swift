//
//  GamesManager.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation
import Foundation

protocol GamesManagerProtocol {
    func fetchNextGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void)
    func fetchPastGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void)
}

final class GamesManager {
    private let dispatcher: RequestDispatcherProtocol
    private let sessionManager: SessionManagerProtocol

    init(dispatcher: RequestDispatcherProtocol, sessionManager: SessionManagerProtocol) {
        self.dispatcher = dispatcher
        self.sessionManager = sessionManager
    }
}

// MARK: - GamesManagerProtocol
extension GamesManager: GamesManagerProtocol {
    func fetchNextGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void) {
        let request = FetchNextGamesRequest(stateId: stateId, sessionManager: sessionManager)
        let operation = APIOperation(endPoint: request)
        
        operation.execute(dispatcher: dispatcher) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let games = result as? [Game] {
                completion(.success(games))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    func fetchPastGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void) {
        let request = FetchPastGamesRequest(stateId: stateId, sessionManager: sessionManager)
        let operation = APIOperation(endPoint: request)
        
        operation.execute(dispatcher: dispatcher) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let games = result as? [Game] {
                completion(.success(games))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
}
