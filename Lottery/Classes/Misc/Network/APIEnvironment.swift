//
//  APIEnvironment.swift
//  OtterScaleiOS
//
//  Created by Андрей Чернышев on 11.01.2022.
//

protocol APIEnvironmentProtocol {
    var host: String { get }
}

struct APIEnvironment: APIEnvironmentProtocol {
    let host: String
}
