// GamesManager.swift

import Foundation

protocol GamesManagerProtocol {
    func fetchNextGames(stateId: Int?, forceUpdate: Bool, completion: @escaping (Result<[Game], Error>) -> Void)
    func fetchPastGames(stateId: Int?, forceUpdate: Bool, completion: @escaping (Result<[Game], Error>) -> Void)
    func suggestNewGame(gameTitle: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func addLuckyNumbers(lotteryId: Int, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Bool, Error>) -> Void)
}

final class GamesManager {
    private enum Constants {
        static let cachedNextGamesKey = "cached_next_games_key"
        static let cachedPastGamesKey = "cached_past_games_key"
    }

    private let dispatcher: RequestDispatcherProtocol = RequestDispatcher()
    private let sessionManager: SessionManagerProtocol = SessionManager()

    private func cacheGames(games: [Game], key: String) {
        let data = try? JSONEncoder().encode(games)
        UserDefaults.standard.set(data, forKey: key)
    }

    private func loadCachedGames(key: String) -> [Game]? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let games = try? JSONDecoder().decode([Game].self, from: data) else {
            return nil
        }
        return games
    }
}

// MARK: - GamesManagerProtocol
extension GamesManager: GamesManagerProtocol {

    func fetchNextGames(stateId: Int?, forceUpdate: Bool = false, completion: @escaping (Result<[Game], Error>) -> Void) {
        if !forceUpdate, let cachedGames = loadCachedGames(key: Constants.cachedNextGamesKey) {
            completion(.success(cachedGames))
            return
        }

        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }

        let request = FetchNextGamesRequest(stateId: stateId, userToken: userToken)
        let operation = APIOperation(endPoint: request)

        let operationId = UUID().uuidString

        // Set the operation in the Operations class
        Operations.shared.setGamesManagerOperation(operation, forKey: operationId)

        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from the Operations class
            Operations.shared.removeGamesManagerOperation(forKey: operationId)

            if let error = error {
                completion(.failure(error))
            } else if let gamesArray = result as? [[String: Any]] {
                let games = gamesArray.compactMap { Game(response: $0) }
                self.cacheGames(games: games, key: Constants.cachedNextGamesKey)
                completion(.success(games))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }

    func fetchPastGames(stateId: Int?, forceUpdate: Bool = false, completion: @escaping (Result<[Game], Error>) -> Void) {
        if !forceUpdate, let cachedGames = loadCachedGames(key: Constants.cachedPastGamesKey) {
            completion(.success(cachedGames))
            return
        }

        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }

        let request = FetchPastGamesRequest(stateId: stateId, userToken: userToken)
        let operation = APIOperation(endPoint: request)

        let operationId = UUID().uuidString

        // Set the operation in the Operations class
        Operations.shared.setGamesManagerOperation(operation, forKey: operationId)

        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from the Operations class
            Operations.shared.removeGamesManagerOperation(forKey: operationId)

            if let error = error {
                completion(.failure(error))
            } else if let gamesArray = result as? [[String: Any]] {
                let games = gamesArray.compactMap { Game(response: $0) }
                self.cacheGames(games: games, key: Constants.cachedPastGamesKey)
                print("cachedGames: \(games.count)")
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

        // Set the operation in the Operations class
        Operations.shared.setGamesManagerOperation(operation, forKey: operationId)

        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from the Operations class
            Operations.shared.removeGamesManagerOperation(forKey: operationId)

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

        let request = AddLuckyNumbersRequest(lotteryId: lotteryId, numbers: numbers, userToken: userToken, date: date)
        let operation = APIOperation(endPoint: request)

        let operationId = UUID().uuidString

        // Set the operation in the actor
        
        Operations.shared.setGamesManagerOperation(operation, forKey: operationId)
        

        performRequest(request) { result in
            // Remove the operation from the actor
            
        Operations.shared.removeGamesManagerOperation(forKey: operationId)
        

            switch result {
            case .success(let data):
                do {
                    if let resultDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let success = resultDict["result"] as? Bool {
                        completion(.success(success))
                    } else {
                        completion(.failure(ContentError(.notContent)))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(_):
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
}


extension GamesManager {
    func performRequest<T: EndPoint>(_ endpoint: T, completion: @escaping (Result<Data, Error>) -> Void) {
        let baseURL = GlobalDefinitions.domain

        guard let url = URL(string: baseURL + endpoint.path) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if [.post, .put, .patch].contains(endpoint.method) {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: endpoint.parameters, options: [])
            } catch {
                completion(.failure(error))
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // No need to access the actor here unless you have shared mutable state
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

        task.resume()
    }
}
extension GamesManager {
    func fetchPastGamesAsync(stateId: Int?, forceUpdate: Bool = false) async throws -> [Game] {
        return try await withCheckedThrowingContinuation { continuation in
            self.fetchPastGames(stateId: stateId, forceUpdate: forceUpdate) { result in
                switch result {
                case .success(let games):
                    continuation.resume(returning: games)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchNextGamesAsync(stateId: Int?, forceUpdate: Bool = false) async throws -> [Game] {
        return try await withCheckedThrowingContinuation { continuation in
            self.fetchNextGames(stateId: stateId, forceUpdate: forceUpdate) { result in
                switch result {
                case .success(let games):
                    continuation.resume(returning: games)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
