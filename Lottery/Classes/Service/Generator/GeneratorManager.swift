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
    private let sessionManager: SessionManagerProtocol = SessionManager()
    
    func generateNumbers(lotteryId: Int, lines: Int, completion: @escaping (Result<GeneratorResponse, Error>) -> Void) {
        // API Endpoint
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/generator") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        guard let userToken = sessionManager.getSession()?.userToken else {
            completion(.failure(ContentError(.notContent)))
            return
        }
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare JSON Body
        let apiKey = GlobalDefinitions.apiKey // Replace with your actual API key
        let jsonBody: [String: Any] = [
            "user_token": userToken,
            "api_key": apiKey,
            "lotteryId": lotteryId,
            "lines": lines
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        // Create Data Task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle Error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check Response and Data
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            // Print HTTP Status Code
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            // Print Response Data
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
               // print("Response data: \(dataString)")
            }
            
            // Check for Success Status Code
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                completion(.failure(NSError(domain: "Invalid response status code", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            // Decode JSON Response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let generatorResponse = try decoder.decode(GeneratorResponse.self, from: data)
                completion(.success(generatorResponse))
            } catch {
                print("Error decoding JSON: \(error)")
                completion(.failure(error))
            }
        }
        
        // Start Task
        task.resume()
    }
}
