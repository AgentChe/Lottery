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
    func listTickets( completion: @escaping (Result<[Ticket], Error>) -> Void)
}

final class TicketsManager {
    private let dispatcher: RequestDispatcherProtocol = RequestDispatcher()
    private let sessionManager: SessionManagerProtocol = SessionManager()
    private var operations: [String: any APIOperationProtocol] = [:]
}

// MARK: - TicketsManagerProtocol
extension TicketsManager: TicketsManagerProtocol {
    func addTicket(lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        let request = AddTicketRequest(userToken: userToken, lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            
            self?.operations.removeValue(forKey: operationId)
            
            
            if let error = error {
                completion(.failure(error))
            } else if let ticketDict = result as? [String: Any], let ticket = Ticket(response: ticketDict) {
                completion(.success(ticket))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    func editTicket(  id: Int, lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        let request = EditTicketRequest(userToken: userToken, id: id, lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            
            self?.operations.removeValue(forKey: operationId)
            
            if let error = error {
                completion(.failure(error))
            } else if let ticketDict = result as? [String: Any], let ticket = Ticket(response: ticketDict) {
                completion(.success(ticket))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    func listTickets( completion: @escaping (Result<[Ticket], Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        let request = ListTicketsRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            
            self?.operations.removeValue(forKey: operationId)            
            
            if let error = error {
                completion(.failure(error))
            } else if let ticketsArray = result as? [[String: Any]] {
                let tickets = ticketsArray.compactMap { Ticket(response: $0) }
                completion(.success(tickets))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
}
