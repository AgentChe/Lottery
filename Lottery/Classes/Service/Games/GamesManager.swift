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
    private var operations: [UUID: any APIOperationProtocol] = [:]

    private func storeOperation(_ operation: any APIOperationProtocol) -> UUID {
        let id = UUID()
        operations[id] = operation
        return id
    }

    private func removeOperation(withId id: UUID) {
        operations.removeValue(forKey: id)
    }
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

        let operationId = storeOperation(operation)
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            defer {
                self?.removeOperation(withId: operationId)
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

        let operationId = storeOperation(operation)
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            defer {
                self?.removeOperation(withId: operationId)
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
