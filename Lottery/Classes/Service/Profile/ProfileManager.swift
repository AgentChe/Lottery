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
    private enum Constants {
        static let syncTokensOperationKey = "sync_tokens_operation_key"
        static let loginOperationKey = "login_operation_key"
        static let getProfileOperationKey = "get_profile_operation_key"
        static let setProfileOperationKey = "set_profile_operation_key"
    }

    private let dispatcher: RequestDispatcherProtocol = RequestDispatcher()
    private let sessionManager: SessionManagerProtocol = SessionManager()
    private var operations: [String: any APIOperationProtocol] = [:]
}

// MARK: ProfileManagerProtocol
extension ProfileManager: ProfileManagerProtocol {
    func syncTokens(oldToken: String, newToken: String, complete: ((LoginResult) -> Void)? = nil) {
        let request = SyncTokensRequest(oldToken: oldToken, newToken: newToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation

        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            defer {
                self?.operations.removeValue(forKey: operationId)
            }

            DispatchQueue.main.async {
                complete?(LoginResult(error: error))
            }
        }
    }
    
    func login(userToken: String, complete: ((LoginResult) -> Void)? = nil) {
        let request = LoginRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        operations[operationId] = operation

        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            defer {
                self?.operations.removeValue(forKey: operationId)
            }

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

        let operationId = UUID().uuidString
        operations[operationId] = operation
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            defer {
                self?.operations.removeValue(forKey: operationId)
            }

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

        let operationId = UUID().uuidString
        operations[operationId] = operation
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            defer {
                self?.operations.removeValue(forKey: operationId)
            }

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
