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
    func suggestNewGame(gameTitle: String, completion: @escaping (Result<Bool, Error>) -> Void)
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
            
            self?.operations.removeValue(forKey: operationId)
            
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
            
            self?.operations.removeValue(forKey: operationId)
            
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
    
    func suggestNewGame(gameTitle: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        
        let request = SuggestNewGameRequest(gameTitle: gameTitle, userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            
            self?.operations.removeValue(forKey: operationId)
            
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    func addLuckyNumbers(lotteryId: Int, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }

        let request = AddLuckyNumbersRequest(lotteryId: lotteryId ,
                                             numbers: numbers,
                                             userToken: userToken,
                                             date: date)
        
        
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation

//        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
//            
//            self?.operations.removeValue(forKey: operationId)
//            
//            if let error = error {
//                completion(.failure(error))
//            } else if let resultDict = result as? [String: Any], let success = resultDict["result"] as? Bool, success {
//                completion(.success(true))
//            } else {
//                completion(.failure(ContentError(.notContent)))
//            }
//        }
        
        performRequest(request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                   
                    if let resultDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let success = resultDict["result"] as? Bool {
                        self?.operations.removeValue(forKey: operationId)
                        completion(.success(success))
                    } else {
                        completion(.failure(ContentError(.notContent)))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
}

extension GamesManager {
    func performRequest<T: EndPoint>(_ endpoint: T, completion: @escaping (Result<Data, Error>) -> Void) {
        // Base URL of the API
        let baseURL = GlobalDefinitions.domain
        
        // Create the full URL
        guard let url = URL(string: baseURL + endpoint.path) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Encode parameters to JSON if the method is POST, PUT, PATCH
        if [.post, .put, .patch].contains(endpoint.method) {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: endpoint.parameters, options: [])
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        // Start the task
        task.resume()
    }
}
