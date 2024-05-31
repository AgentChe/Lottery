//
//  GamesManager.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

protocol GamesManagerProtocol {
    func fetchNextGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void)
    func fetchPastGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void)
}

final class GamesManager {
    private let dispatcher: RequestDispatcherProtocol = RequestDispatcher()
    private let sessionManager: SessionManagerProtocol = SessionManager()
    private var operations: [String: any APIOperationProtocol] = [:]
}

// MARK: - GamesManagerProtocol
extension GamesManager: GamesManagerProtocol {
    func fetchNextGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }

        let request = FetchNextGamesRequest(stateId: stateId, userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation

        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            defer {
                self?.operations.removeValue(forKey: operationId)
            }

            if let error = error {
                completion(.failure(error))
            } else if let gamesArray = result as? [[String: Any]] {
                let games = gamesArray.compactMap { Game(response: $0) }
                completion(.success(games))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    func fetchPastGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }

        let request = FetchPastGamesRequest(stateId: stateId, userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation

        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            defer {
                self?.operations.removeValue(forKey: operationId)
            }

            if let error = error {
                completion(.failure(error))
            } else if let gamesArray = result as? [[String: Any]] {
                let games = gamesArray.compactMap { Game(response: $0) }
                completion(.success(games))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
}
