//
//  ProfileManager.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

import Foundation

protocol ProfileManagerProtocol {
    func syncTokens(oldToken: String, newToken: String, complete: ((LoginResult) -> Void)?)
    func login(userToken: String, complete: ((LoginResult) -> Void)?)
}

final class ProfileManager {
    enum Constants {
        static let syncTokensOperationKey = "sync_tokens_operation_key"
        static let loginOperationKey = "login_operation_key"
    }
    
    private lazy var operations = [String: APIOperationProtocol]()
    private lazy var requestDispatcher = RequestDispatcher()
}

// MARK: ProfileManagerProtocol
extension ProfileManager: ProfileManagerProtocol {
    func syncTokens(oldToken: String, newToken: String, complete: ((LoginResult) -> Void)? = nil) {
        let request = SyncTokensRequest(oldToken: oldToken, newToken: newToken)
        let operation = APIOperation(endPoint: request)
        
        operations[Constants.syncTokensOperationKey] = operation
        
        operation.execute(dispatcher: requestDispatcher) { [weak self] result, error in
            self?.operations.removeValue(forKey: Constants.syncTokensOperationKey)
            
            DispatchQueue.main.async {
                complete?(LoginResult(error: error))
            }
        }
    }
    
    func login(userToken: String, complete: ((LoginResult) -> Void)? = nil) {
        let request = LoginRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        operations[Constants.loginOperationKey] = operation
        
        operation.execute(dispatcher: requestDispatcher) { [weak self] result, error in
            self?.operations.removeValue(forKey: Constants.loginOperationKey)
            
            DispatchQueue.main.async {
                complete?(LoginResult(error: error))
            }
        }
    }
}
