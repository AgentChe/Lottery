//
//  TicketsManager.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 5/30/24.
//

import Foundation

protocol TicketsManagerProtocol {
    func addTicket(userToken: String, lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void)
    func editTicket(userToken: String, id: Int, lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void)
    func listTickets(userToken: String, completion: @escaping (Result<[Ticket], Error>) -> Void)
}

final class TicketsManager {
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

// MARK: - TicketsManagerProtocol
extension TicketsManager: TicketsManagerProtocol {
    func addTicket(userToken: String, lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        let request = AddTicketRequest(userToken: userToken, lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers)
        let operation = APIOperation(endPoint: request)

        let operationId = storeOperation(operation)
        
        operation.execute(dispatcher: dispatcher) { result, error in
            defer {
                self.removeOperation(withId: operationId)
            }

            if let error = error {
                completion(.failure(error))
            } else if let ticketDict = result as? [String: Any], let ticket = Ticket(response: ticketDict) {
                completion(.success(ticket))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    func editTicket(userToken: String, id: Int, lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        let request = EditTicketRequest(userToken: userToken, id: id, lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers)
        let operation = APIOperation(endPoint: request)

        let operationId = storeOperation(operation)
        
        operation.execute(dispatcher: dispatcher) { result, error in
            defer {
                self.removeOperation(withId: operationId)
            }

            if let error = error {
                completion(.failure(error))
            } else if let ticketDict = result as? [String: Any], let ticket = Ticket(response: ticketDict) {
                completion(.success(ticket))
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
    
    func listTickets(userToken: String, completion: @escaping (Result<[Ticket], Error>) -> Void) {
        let request = ListTicketsRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)

        let operationId = storeOperation(operation)
        
        operation.execute(dispatcher: dispatcher) { result, error in
            defer {
                self.removeOperation(withId: operationId)
            }

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
