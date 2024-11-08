//
//  GeneratorManager.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/8/24.
//

import Foundation

protocol GeneratorManagerProtocol {
    func generateNumbers(lotteryId: Int, lines: Int, completion: @escaping (Result<GeneratorResponse, Error>) -> Void)
}
final class GeneratorManager: GeneratorManagerProtocol {
    private let sessionManager: SessionManagerProtocol
    private let dispatcher: RequestDispatcherProtocol

    // Dependency Injection for better testability
    init(sessionManager: SessionManagerProtocol = SessionManager(),
         dispatcher: RequestDispatcherProtocol = RequestDispatcher()) {
        self.sessionManager = sessionManager
        self.dispatcher = dispatcher
    }

    func generateNumbers(lotteryId: Int, lines: Int, completion: @escaping (Result<GeneratorResponse, Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }

        let request = GenerateNumbersRequest(userToken: userToken, lotteryId: lotteryId, lines: lines)
        let operation = APIOperation(endPoint: request)
        let operationId = UUID().uuidString

        // Set the operation in the Operations class
        Operations.shared.setGeneratorManagerOperation(operation, forKey: operationId)

        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from the Operations class
            Operations.shared.removeGeneratorManagerOperation(forKey: operationId)

            if let error = error {
                completion(.failure(error))
            } else if let data = result as? Data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(GeneratorResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(ContentError(.notContent)))
            }
        }
    }
}
