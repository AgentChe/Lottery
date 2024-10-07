// ContentManager.swift

import Foundation

protocol ContentManagerProtocol {
    func fetchStates(forceUpdate: Bool, completion: @escaping (Result<[State], Error>) -> Void)
    func fetchLotteries(forceUpdate: Bool, stateId: Int?, completion: @escaping (Result<[Lottery], Error>) -> Void)
    func fetchLotteriesPattern(forceUpdate: Bool, stateId: Int?, completion: @escaping (Result<[LotteryPattern], Error>) -> Void)
}

final class ContentManager {
    enum Constants {
        static let stateCacheKey = "states_cache"
        static let lotteryCacheKey = "lotteries_cache"
        static let lotteryPatternsCacheKey = "lottery_patterns_cache"
    }
    
    private let dispatcher: RequestDispatcherProtocol = RequestDispatcher()
    private let sessionManager: SessionManagerProtocol = SessionManager()
}

// MARK: - ContentManagerProtocol
extension ContentManager: ContentManagerProtocol {
    func fetchStates(forceUpdate: Bool, completion: @escaping (Result<[State], Error>) -> Void) {
        if !forceUpdate, let cachedStates: [State] = loadFromCache(forKey: Constants.stateCacheKey) {
            completion(.success(cachedStates))
            return
        }
        
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        
        let request = FetchStatesRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)
        let operationId = UUID().uuidString
        
        // Set the operation in the actor
        Task {
            await Operations.shared.setContentManagerOperation(operation, forKey: operationId)
        }
        
        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from the actor
            Task {
                await Operations.shared.removeContentManagerOperation(forKey: operationId)
                
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else if let statesArray = result as? [[String: Any]] {
                        let states = statesArray.compactMap { State(response: $0) }
                        self.saveToCache(data: states, forKey: Constants.stateCacheKey)
                        completion(.success(states))
                    } else {
                        completion(.failure(ContentError(.notContent)))
                    }
                }
            }
        }
    }
    
    func fetchLotteries(forceUpdate: Bool, stateId: Int? = nil, completion: @escaping (Result<[Lottery], Error>) -> Void) {
        if !forceUpdate, let cachedLotteries: [Lottery] = loadFromCache(forKey: Constants.lotteryCacheKey) {
            if let stateId = stateId {
                let filteredLotteries = cachedLotteries.filter { $0.avaliable_states.contains(stateId) }
                completion(.success(filteredLotteries))
            } else {
                completion(.success(cachedLotteries))
            }
            return
        }
        
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        
        let request = FetchLotteriesRequest(stateId: stateId, userToken: userToken)
        let operation = APIOperation(endPoint: request)
        let operationId = UUID().uuidString
        
        // Set the operation in the actor
        Task {
            await Operations.shared.setContentManagerOperation(operation, forKey: operationId)
        }
        
        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from the actor
            Task {
                await Operations.shared.removeContentManagerOperation(forKey: operationId)
                
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else if let lotteriesArray = result as? [[String: Any]] {
                        let lotteries = lotteriesArray.compactMap { Lottery(response: $0) }
                        self.saveToCache(data: lotteries, forKey: Constants.lotteryCacheKey)
                        completion(.success(lotteries))
                    } else {
                        completion(.failure(ContentError(.notContent)))
                    }
                }
            }
        }
    }
    
    func fetchLotteriesPattern(forceUpdate: Bool, stateId: Int? = nil, completion: @escaping (Result<[LotteryPattern], Error>) -> Void) {
        if !forceUpdate, let cachedPatterns: [LotteryPattern] = loadFromCache(forKey: Constants.lotteryPatternsCacheKey) {
            completion(.success(cachedPatterns))
            return
        }
        
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        
        let request = FetchLotteriesPatternRequest(stateId: stateId, userToken: userToken)
        let operation = APIOperation(endPoint: request)
        let operationId = UUID().uuidString
        
        // Set the operation in the actor
        Task {
            await Operations.shared.setContentManagerOperation(operation, forKey: operationId)
        }
        
        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from the actor
            Task {
                await Operations.shared.removeContentManagerOperation(forKey: operationId)
                
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else if let patternsArray = result as? [[String: Any]] {
                        let patterns = patternsArray.compactMap { LotteryPattern(response: $0) }
                        self.saveToCache(data: patterns, forKey: Constants.lotteryPatternsCacheKey)
                        completion(.success(patterns))
                    } else {
                        completion(.failure(ContentError(.notContent)))
                    }
                }
            }
        }
    }
}

// MARK: - Private Methods
private extension ContentManager {
    func loadFromCache<T: Decodable>(forKey key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key),
           let cachedData = try? JSONDecoder().decode(T.self, from: data) {
            return cachedData
        }
        return nil
    }
    
    func saveToCache<T: Encodable>(data: T, forKey key: String) {
        if let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: key)
        }
    }
}
