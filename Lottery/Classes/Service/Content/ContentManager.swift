//
//  ContentManager.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

protocol ContentManagerProtocol {
    func fetchStates(forceUpdate: Bool, completion: @escaping (Result<[State], Error>) -> Void)
    func fetchLotteries(forceUpdate: Bool, stateId: Int?, completion: @escaping (Result<[Lottery], Error>) -> Void)
}

final class ContentManager: ContentManagerProtocol {
    private let dispatcher: RequestDispatcherProtocol
    private let sessionManager: SessionManagerProtocol
    private let stateCacheKey = "states_cache"
    private let lotteryCacheKey = "lotteries_cache"
    
    init(dispatcher: RequestDispatcherProtocol, sessionManager: SessionManagerProtocol) {
        self.dispatcher = dispatcher
        self.sessionManager = sessionManager
    }
    
    // Fetch States
    func fetchStates(forceUpdate: Bool, completion: @escaping (Result<[State], Error>) -> Void) {
        if !forceUpdate, let cachedStates = loadFromCache(forKey: stateCacheKey) as [State]? {
            completion(.success(cachedStates))
            return
        }
        
        let operation = APIOperation(endPoint: FetchStatesRequest(sessionManager: sessionManager))
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
            } else if let states = result as? [State] {
                self?.saveToCache(data: states, forKey: self?.stateCacheKey)
                completion(.success(states))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    // Fetch Lotteries
    func fetchLotteries(forceUpdate: Bool, stateId: Int?, completion: @escaping (Result<[Lottery], Error>) -> Void) {
        if !forceUpdate, let cachedLotteries = loadFromCache(forKey: lotteryCacheKey) as [Lottery]? {
            completion(.success(cachedLotteries))
            return
        }
        
        let operation = APIOperation(endPoint: FetchLotteriesRequest(stateId: stateId, sessionManager: sessionManager))
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
            } else if let lotteries = result as? [Lottery] {
                self?.saveToCache(data: lotteries, forKey: self?.lotteryCacheKey)
                completion(.success(lotteries))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    // Load from cache
    private func loadFromCache<T: Decodable>(forKey key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key),
           let cachedData = try? JSONDecoder().decode(T.self, from: data) {
            return cachedData
        }
        return nil
    }
    
    // Save to cache
    private func saveToCache<T: Encodable>(data: T, forKey key: String?) {
        if let key = key, let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: key)
        }
    }
}
