// Operations.swift

import Foundation

class Operations {
    static let shared = Operations()
    
    private var contentManagerOperations: [String: any APIOperationProtocol] = [:]
    private var gamesManagerOperations: [String: any APIOperationProtocol] = [:]
    private var ticketsManagerOperations: [String: any APIOperationProtocol] = [:]
    private var profileManagerOperations: [String: any APIOperationProtocol] = [:]
    
    
    private let operationsQueue = DispatchQueue(label: "com.example.OperationsQueue")
    
    // MARK: - Methods for contentManagerOperations
    func setContentManagerOperation(_ operation: any APIOperationProtocol, forKey key: String) {
        operationsQueue.sync {
            contentManagerOperations[key] = operation
        }
    }

    func removeContentManagerOperation(forKey key: String) {
        operationsQueue.sync {
            contentManagerOperations.removeValue(forKey: key)
        }
    }

    func getContentManagerOperation(forKey key: String) -> (any APIOperationProtocol)? {
        return operationsQueue.sync {
            contentManagerOperations[key]
        }
    }
    
    // MARK: - Methods for gamesManagerOperations
    func setGamesManagerOperation(_ operation: any APIOperationProtocol, forKey key: String) {
        operationsQueue.sync {
            gamesManagerOperations[key] = operation
        }
    }
    
    func removeGamesManagerOperation(forKey key: String) {
        operationsQueue.sync {
            gamesManagerOperations.removeValue(forKey: key)
        }
    }
    
    func getGamesManagerOperation(forKey key: String) -> (any APIOperationProtocol)? {
        return operationsQueue.sync {
            gamesManagerOperations[key]
        }
    }
    
    // MARK: - Methods for ticketsManagerOperations
    func setTicketsManagerOperation(_ operation: any APIOperationProtocol, forKey key: String) {
        operationsQueue.sync {
            ticketsManagerOperations[key] = operation
        }
    }
    
    func removeTicketsManagerOperation(forKey key: String) {
        operationsQueue.sync {
            ticketsManagerOperations.removeValue(forKey: key)
        }
    }
    
    func getTicketsManagerOperation(forKey key: String) -> (any APIOperationProtocol)? {
        return operationsQueue.sync {
            ticketsManagerOperations[key]
        }
    }
    
    // MARK: - Methods for profileManagerOperations
    func setProfileManagerOperation(_ operation: any APIOperationProtocol, forKey key: String) {
        operationsQueue.sync {
            profileManagerOperations[key] = operation
        }
    }
    
    func removeProfileManagerOperation(forKey key: String) {
        operationsQueue.sync {
            profileManagerOperations.removeValue(forKey: key)
        }
    }
    
    func getProfileManagerOperation(forKey key: String) -> (any APIOperationProtocol)? {
        return operationsQueue.sync {
            profileManagerOperations[key]
        }
    }
}
