//
//  APIService.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/28/24.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseUrl = "https://yourapi.com/api"
    private let apiKey = "your_api_key"
    private let userToken = "user_token"
    
    private init() {}
    
    // Fetch States
    func fetchStates(completion: @escaping (Result<[State], Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/states")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let states = try JSONDecoder().decode([State].self, from: data)
                completion(.success(states))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Fetch Lotteries
    func fetchLotteries(stateId: Int?, completion: @escaping (Result<[Lottery], Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/lotteries")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        if let stateId = stateId {
            let body = ["state_id": stateId]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let lotteries = try JSONDecoder().decode([Lottery].self, from: data)
                completion(.success(lotteries))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Add Lottery
    func addLottery(name: String, stateId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/lotteries/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        let body = ["name": name, "state_id": stateId] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let result = try JSONDecoder().decode([String: Bool].self, from: data)
                completion(.success(result["result"] ?? false))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Set Profile
    func setProfile(lotteries: [Int]?, state: Int?, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/profile/set")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        var body: [String: Any] = [:]
        if let lotteries = lotteries {
            body["lotteries"] = lotteries
        }
        if let state = state {
            body["state"] = state
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let result = try JSONDecoder().decode([String: Bool].self, from: data)
                completion(.success(result["result"] ?? false))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Get Profile
    func getProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/profile/get")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let profile = try JSONDecoder().decode(Profile.self, from: data)
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Fetch Next Games
    func fetchNextGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/games/next")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        if let stateId = stateId {
            let body = ["state_id": stateId]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let games = try JSONDecoder().decode([Game].self, from: data)
                completion(.success(games))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Fetch Past Games
    func fetchPastGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/games/past")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        if let stateId = stateId {
            let body = ["state_id": stateId]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let games = try JSONDecoder().decode([Game].self, from: data)
                completion(.success(games))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Add Lucky Numbers
    func addLuckyNumbers(numbers: [[Int]], gameId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/games/luckynumbers/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        let body = ["numbers": numbers, "game_id": gameId] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let result = try JSONDecoder().decode([String: Bool].self, from: data)
                completion(.success(result["result"] ?? false))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Add Ticket
    func addTicket(lotteryId: Int, pictureUrl: String?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/tickets/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        let body = ["lotteryId": lotteryId, "pictureUrl": pictureUrl as Any, "date": date, "numbers": numbers] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let ticket = try JSONDecoder().decode(Ticket.self, from: data)
                completion(.success(ticket))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Edit Ticket
    func editTicket(id: Int, lotteryId: Int, pictureUrl: String?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/tickets/edit")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        let body = ["id": id, "lotteryId": lotteryId, "pictureUrl": pictureUrl as Any, "date": date, "numbers": numbers] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let ticket = try JSONDecoder().decode(Ticket.self, from: data)
                completion(.success(ticket))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // List Tickets
    func listTickets(completion: @escaping (Result<[Ticket], Error>) -> Void) {
        let url = URL(string: "\(baseUrl)/tickets/list")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "_api_key")
        request.addValue(userToken, forHTTPHeaderField: "_user_token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let tickets = try JSONDecoder().decode([Ticket].self, from: data)
                completion(.success(tickets))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
