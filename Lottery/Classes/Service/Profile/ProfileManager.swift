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
    func getProfile(complete: @escaping (Result<Profile, Error>) -> Void)
    func setProfile(lotteries: [Int]?, state: Int?, complete: @escaping (Result<Bool, Error>) -> Void)
}

final class ProfileManager {
    enum Constants {
        static let syncTokensOperationKey = "sync_tokens_operation_key"
        static let loginOperationKey = "login_operation_key"
        static let getProfileOperationKey = "get_profile_operation_key"
        static let setProfileOperationKey = "set_profile_operation_key"
    }
    
    private lazy var operations = [String: APIOperationProtocol]()
    private lazy var requestDispatcher = RequestDispatcher()
    private let sessionManager: SessionManagerProtocol = SessionManager()
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

    func getProfile(complete: @escaping (Result<Profile, Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            complete(.failure(SignError.tokenNotFound))
            return
        }
        
        let request = GetProfileRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        operations[Constants.getProfileOperationKey] = operation
        
        operation.execute(dispatcher: requestDispatcher) { [weak self] result, error in
            self?.operations.removeValue(forKey: Constants.getProfileOperationKey)
            
            DispatchQueue.main.async {
                if let error = error {
                    complete(.failure(error))
                } else if let profileData = result as? [String: Any], let profile = Profile(response: profileData) {
                    complete(.success(profile))
                } else {
                    complete(.failure(ContentError(.notContent)))
                }
            }
        }
    }

    func setProfile(lotteries: [Int]?, state: Int?, complete: @escaping (Result<Bool, Error>) -> Void) {
        guard let userToken = sessionManager.getSession()?.userToken else {
            complete(.failure(SignError.tokenNotFound))
            return
        }
        
        let request = SetProfileRequest(userToken: userToken, lotteries: lotteries, state: state)
        let operation = APIOperation(endPoint: request)
        
        operations[Constants.setProfileOperationKey] = operation
        
        operation.execute(dispatcher: requestDispatcher) { [weak self] result, error in
            self?.operations.removeValue(forKey: Constants.setProfileOperationKey)
            
            DispatchQueue.main.async {
                if let error = error {
                    complete(.failure(error))
                } else if let result = result as? [String: Any], let success = result["result"] as? Bool {
                    complete(.success(success))
                } else {
                    complete(.failure(ContentError(.notContent)))
                }
            }
        }
    }
}
