//
//  TicketsManager.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//


import Foundation

protocol TicketsManagerProtocol {
    func addTicket(lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void)
    func editTicket(id: Int, lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void)
    func listTickets(completion: @escaping (Result<[Ticket], Error>) -> Void)
}

final class TicketsManager {
    private let dispatcher: RequestDispatcherProtocol
    private let sessionManager: SessionManagerProtocol

    init(dispatcher: RequestDispatcherProtocol, sessionManager: SessionManagerProtocol) {
        self.dispatcher = dispatcher
        self.sessionManager = sessionManager
    }
}

// MARK: - TicketsManagerProtocol
extension TicketsManager: TicketsManagerProtocol {
    func addTicket(lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        let request = AddTicketRequest(lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers, sessionManager: sessionManager)
        let operation = APIOperation(endPoint: request)
        
        operation.execute(dispatcher: dispatcher) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let ticket = result as? Ticket {
                completion(.success(ticket))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    func editTicket(id: Int, lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        let request = EditTicketRequest(id: id, lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers, sessionManager: sessionManager)
        let operation = APIOperation(endPoint: request)
        
        operation.execute(dispatcher: dispatcher) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let ticket = result as? Ticket {
                completion(.success(ticket))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    func listTickets(completion: @escaping (Result<[Ticket], Error>) -> Void) {
        let request = ListTicketsRequest(sessionManager: sessionManager)
        let operation = APIOperation(endPoint: request)
        
        operation.execute(dispatcher: dispatcher) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let tickets = result as? [Ticket] {
                completion(.success(tickets))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
}
