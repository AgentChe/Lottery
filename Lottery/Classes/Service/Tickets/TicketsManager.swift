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
}

// MARK: - TicketsManagerProtocol
extension TicketsManager: TicketsManagerProtocol {
    func listTickets( completion: @escaping (Result<[Ticket], Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        let request = ListTicketsRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        Oprtaions.ticketsManagerOprations[operationId] = operation
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            
            Oprtaions.ticketsManagerOprations.removeValue(forKey: operationId)
            
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
    func addTicket(lotteryId: Int, pictureUrl: URL?, date: TimeInterval, numbers: [[Int]], completion: @escaping (Result<Ticket, Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        let request = AddTicketRequest(userToken: userToken, lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbers)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        Oprtaions.ticketsManagerOprations[operationId] = operation
        
//        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
//            
//            self?.operations.removeValue(forKey: operationId)
//            
//            
//            if let error = error {
//                completion(.failure(error))
//            } else if let ticketDict = result as? [String: Any], let ticket = Ticket(response: ticketDict) {
//                completion(.success(ticket))
//            } else {
//                completion(.failure(ContentError(.notContent)))
//            }
//        }
        performRequest(request) { [weak self] (result: Result<LotteryResponse, Error>) in
            Oprtaions.ticketsManagerOprations.removeValue(forKey: operationId)
            switch result {
            case .success(let ticketResponse):
                let ticket = Ticket(id: ticketResponse.id, lotteryId: ticketResponse.lotteryId, pictureUrl: URL(string: ticketResponse.pictureUrl), date: ticketResponse.date, numbers: ticketResponse.numbers)
                completion(.success(ticket ))
                
                
            case .failure(let error):
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
        Oprtaions.ticketsManagerOprations[operationId] = operation
        
//        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
//            
//            self?.operations.removeValue(forKey: operationId)
//            
//            if let error = error {
//                completion(.failure(error))
//            } else if let ticketDict = result as? [String: Any], let ticket = Ticket(response: ticketDict) {
//                completion(.success(ticket))
//            } else {
//                completion(.failure(ContentError(.notContent)))
//            }
//        }
        performRequest(request) { [weak self] (result: Result<LotteryResponse, Error>) in
            Oprtaions.ticketsManagerOprations.removeValue(forKey: operationId)
            switch result {
            case .success(let ticketResponse):
                let ticket = Ticket(id: ticketResponse.id, lotteryId: ticketResponse.lotteryId, pictureUrl: URL(string: ticketResponse.pictureUrl), date: ticketResponse.date, numbers: ticketResponse.numbers)
                completion(.success(ticket ))
                
                
            case .failure(let error):
                completion(.failure(ContentError(.notContent)))
            }
        }

    }
    func deleteTicket(id: Int, completion: @escaping (Result<ResultResponse, Error>) -> Void) {
          guard let userToken = sessionManager.getSession()?.userToken else {
              completion(.failure(ContentError(.notContent)))
              return
          }
          
          let request = DeleteTicketRequest(userToken: userToken, id: id)
          let operationId = UUID().uuidString
          
        Oprtaions.ticketsManagerOprations[operationId] = APIOperation(endPoint: request)
          
          performRequest(request) { [weak self] (result: Result<ResultResponse, Error>) in
              Oprtaions.ticketsManagerOprations.removeValue(forKey: operationId)
              
              switch result {
              case .success(let response):
                  if response.result {
                      completion(.success(response))
                  } else {
                      let error = NSError(domain: "Delete operation failed", code: -1, userInfo: [NSLocalizedDescriptionKey: "The delete operation did not succeed."])
                      completion(.failure(error))
                  }
              case .failure(let error):
                  completion(.failure(error))
              }
          }
      }

    
    
}
extension TicketsManager {
    private func performRequest<T: EndPoint, U: Codable>(_ endpoint: T, completion: @escaping (Result<U, Error>) -> Void) {
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
             
             do {
                 let decodedData = try JSONDecoder().decode(U.self, from: data)
                 completion(.success(decodedData))
             } catch {
                 completion(.failure(error))
             }
         }
         
         task.resume()
     }
  
}
struct LotteryResponse: Codable {
    let id: Int
    let lotteryId: Int
    let pictureUrl: String
    let date: Double
    let numbers: [[Int]]
}
struct ResultResponse: Codable {
    let result: Bool
}
