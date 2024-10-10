//
//  ProfileManager.swift
//  Lottery
//

import Foundation

protocol ProfileManagerProtocol {
    func syncTokens(oldToken: String, newToken: String, complete: ((LoginResult) -> Void)?)
    func login(userToken: String, complete: ((LoginResult) -> Void)?)
    func getProfile(forceUpdate: Bool, complete: @escaping (Result<Profile, Error>) -> Void)
    func setProfile(lotteries: [Int]?, state: Int?, complete: @escaping (Result<Bool, Error>) -> Void)
}

final class ProfileManager {
    private enum Constants {
        static let syncTokensOperationKey = "sync_tokens_operation_key"
        static let loginOperationKey = "login_operation_key"
        static let getProfileOperationKey = "get_profile_operation_key"
        static let setProfileOperationKey = "set_profile_operation_key"
        static let cachedLotteriesKey = "cached_lotteries_key"
        static let cachedStateKey = "cached_state_key"
    }

    private let dispatcher: RequestDispatcherProtocol = RequestDispatcher()
    private let sessionManager: SessionManagerProtocol = SessionManager()

    private func cacheProfile(lotteries: [Int]?, state: Int?) {
        if let lotteries = lotteries {
            UserDefaults.standard.set(lotteries, forKey: Constants.cachedLotteriesKey)
        }
        if let state = state {
            UserDefaults.standard.set(state, forKey: Constants.cachedStateKey)
        }
    }

    private func loadCachedProfile() -> Profile? {
        let lotteries = UserDefaults.standard.array(forKey: Constants.cachedLotteriesKey) as? [Int]
        let state = UserDefaults.standard.value(forKey: Constants.cachedStateKey) as? Int
        return Profile(lotteries: lotteries, state: state)
    }
}

// MARK: - ProfileManagerProtocol
extension ProfileManager: ProfileManagerProtocol {
    func syncTokens(oldToken: String, newToken: String, complete: ((LoginResult) -> Void)? = nil) {
        let request = SyncTokensRequest(oldToken: oldToken, newToken: newToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        
        // Set the operation in Operations
        Operations.shared.setProfileManagerOperation(operation, forKey: operationId)

        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from Operations
            Operations.shared.removeProfileManagerOperation(forKey: operationId)
            DispatchQueue.main.async {
                complete?(LoginResult(error: error))
            }
        }
    }
    
    func login(userToken: String, complete: ((LoginResult) -> Void)? = nil) {
        let request = LoginRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)
        
        let operationId = UUID().uuidString
        
        // Set the operation in Operations
        Operations.shared.setProfileManagerOperation(operation, forKey: operationId)

        operation.execute(dispatcher: dispatcher) { result, error in
            // Remove the operation from Operations
            Operations.shared.removeProfileManagerOperation(forKey: operationId)
            DispatchQueue.main.async {
                complete?(LoginResult(error: error))
            }
        }
    }

    func getProfile(forceUpdate: Bool = false, complete: @escaping (Result<Profile, Error>) -> Void) {
        if !forceUpdate, let cachedProfile = loadCachedProfile() {
            complete(.success(cachedProfile))
            return
        }
        
        guard let userToken = sessionManager.getSession()?.userToken else {
            complete(.failure(SignError.tokenNotFound))
            return
        }

        let request = GetProfileRequest(userToken: userToken)
        let operation = APIOperation(endPoint: request)

        let operationId = UUID().uuidString
        
        // Set the operation in Operations
        Operations.shared.setProfileManagerOperation(operation, forKey: operationId)
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            // Remove the operation from Operations
            Operations.shared.removeProfileManagerOperation(forKey: operationId)
            DispatchQueue.main.async {
                if let error = error {
                    complete(.failure(error))
                } else if let profile = ResponseMapper.mapGetProfileResponse(result: result) {
                    self?.cacheProfile(lotteries: profile.lotteries, state: profile.state)
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
        
        // Set the operation in Operations
        Operations.shared.setProfileManagerOperation(operation, forKey: operationId)
        
        operation.execute(dispatcher: dispatcher) { [weak self] result, error in
            // Remove the operation from Operations
            Operations.shared.removeProfileManagerOperation(forKey: operationId)
            DispatchQueue.main.async {
                if let error = error {
                    complete(.failure(error))
                } else if let success = ResponseMapper.mapSetProfileResponse(result: result) {
                    if success {
                        self?.cacheProfile(lotteries: lotteries, state: state)
                    }
                    complete(.success(success))
                } else {
                    complete(.failure(ContentError(.notContent)))
                }
            }
        }
    }
}

// MARK: - ResponseMapper
final class ResponseMapper {
    static func mapSetProfileResponse(result: Any) -> Bool? {
        guard let result = result as? [String: Any] else {
            return nil
        }
        return result["result"] as? Bool
    }
    
    static func mapGetProfileResponse(result: Any) -> Profile? {
        guard let result = result as? [String: Any] else {
            return nil
        }
        return Profile(response: result)
    }
}
