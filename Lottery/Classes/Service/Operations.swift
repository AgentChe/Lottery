// Operations.swift

import Foundation

actor Operations {
    static let shared = Operations()
    
    var contentManagerOperations: [String: (any APIOperationProtocol)] = [:]
    var gamesManagerOperations: [String: (any APIOperationProtocol)] = [:]
    var ticketsManagerOperations: [String: (any APIOperationProtocol)] = [:]
    var profileManagerOperations: [String: (any APIOperationProtocol)] = [:]
    
    // Methods for contentManagerOperations
    func setContentManagerOperation(_ operation: any APIOperationProtocol, forKey key: String) {
        contentManagerOperations[key] = operation
    }

    func removeContentManagerOperation(forKey key: String) {
        contentManagerOperations.removeValue(forKey: key)
    }

    func getContentManagerOperation(forKey key: String) -> (any APIOperationProtocol)? {
        return contentManagerOperations[key]
    }
    
    // Methods for gamesManagerOperations
    func setGamesManagerOperation(_ operation: any APIOperationProtocol, forKey key: String) {
        gamesManagerOperations[key] = operation
    }
    
    func removeGamesManagerOperation(forKey key: String) {
        gamesManagerOperations.removeValue(forKey: key)
    }
    
    func getGamesManagerOperation(forKey key: String) -> (any APIOperationProtocol)? {
        return gamesManagerOperations[key]
    }
    
    // Methods for ticketsManagerOperations
    func setTicketsManagerOperation(_ operation: any APIOperationProtocol, forKey key: String) {
        ticketsManagerOperations[key] = operation
    }
    
    func removeTicketsManagerOperation(forKey key: String) {
        ticketsManagerOperations.removeValue(forKey: key)
    }
    
    func getTicketsManagerOperation(forKey key: String) -> (any APIOperationProtocol)? {
        return ticketsManagerOperations[key]
    }
    
    // Methods for profileManagerOperations
    func setProfileManagerOperation(_ operation: any APIOperationProtocol, forKey key: String) {
        profileManagerOperations[key] = operation
    }
    
    func removeProfileManagerOperation(forKey key: String) {
        profileManagerOperations.removeValue(forKey: key)
    }
    
    func getProfileManagerOperation(forKey key: String) -> (any APIOperationProtocol)? {
        return profileManagerOperations[key]
    }
}
