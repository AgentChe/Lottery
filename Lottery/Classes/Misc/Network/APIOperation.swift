//
//  APIOperation.swift
//  OtterScaleiOS
//
//  Created by Андрей Чернышев on 11.01.2022.
//

import Foundation



protocol APIOperationProtocol {
    func cancel()
    func execute(dispatcher: RequestDispatcherProtocol, completion: ((Any?, Error?) -> Void)?)
}

final class APIOperation: APIOperationProtocol {
    deinit {
        task?.cancel()
        task = nil
    }
    
    private var task: URLSessionDataTask?
    
    private let endPoint: EndPoint
    
    init(endPoint: EndPoint) {
        self.endPoint = endPoint
    }
}

// MARK: Internal
extension APIOperation {
    func cancel() {
        task?.cancel()
    }
    
    func execute(dispatcher: RequestDispatcherProtocol, completion: ((Any?, Error?) -> Void)? = nil) {
        task = dispatcher.execute(endPoint: endPoint) { result, error in
            completion?(result, error)
        }
    }
}

