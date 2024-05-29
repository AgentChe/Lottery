//
//  DataManager.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/28/24.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    var states: [State] = []
    var lotteries: [Lottery] = []
    var profile: Profile?
    var tickets: [Ticket] = []

    // Preload data method
    func preloadData(completion: @escaping (Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        var loadError: Error?
        
        dispatchGroup.enter()
        APIService.shared.fetchStates { result in
            switch result {
            case .success(let states):
                self.states = states
            case .failure(let error):
                loadError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        APIService.shared.fetchLotteries(stateId: nil) { result in
            switch result {
            case .success(let lotteries):
                self.lotteries = lotteries
            case .failure(let error):
                loadError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(loadError)
        }
    }
    
    // Load profile method
    func loadProfile(completion: @escaping (Error?) -> Void) {
        APIService.shared.getProfile { result in
            switch result {
            case .success(let profile):
                self.profile = profile
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // Update profile method
    func updateProfile(lotteries: [Int]?, state: Int?, completion: @escaping (Bool, Error?) -> Void) {
        APIService.shared.setProfile(lotteries: lotteries, state: state) { result in
            switch result {
            case .success(let success):
                if success {
                    self.profile = Profile(lotteries: lotteries, state: state)
                }
                completion(success, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    // Load tickets method
    func loadTickets(completion: @escaping (Error?) -> Void) {
        APIService.shared.listTickets { result in
            switch result {
            case .success(let tickets):
                self.tickets = tickets
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // Add ticket method
    func addTicket(lotteryId: Int, pictureUrl: String?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Error?) -> Void) {
        APIService.shared.addTicket(lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers) { result in
            switch result {
            case .success(let ticket):
                self.tickets.append(ticket)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // Edit ticket method
    func editTicket(id: Int, lotteryId: Int, pictureUrl: String?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Error?) -> Void) {
        APIService.shared.editTicket(id: id, lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers) { result in
            switch result {
            case .success(let ticket):
                if let index = self.tickets.firstIndex(where: { $0.id == id }) {
                    self.tickets[index] = ticket
                }
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // Fetch next games method
    func fetchNextGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void) {
        APIService.shared.fetchNextGames(stateId: stateId) { result in
            completion(result)
        }
    }
    
    // Fetch past games method
    func fetchPastGames(stateId: Int?, completion: @escaping (Result<[Game], Error>) -> Void) {
        APIService.shared.fetchPastGames(stateId: stateId) { result in
            completion(result)
        }
    }
}
