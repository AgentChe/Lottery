//
//  TicketUploadImage.swift
//  Lottery
//
//  Created by Андрей Чернышев on 21.08.2024.
//

import UIKit

struct TicketUploadImage {
    let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = false
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        
        session = URLSession(configuration: config, delegate: nil, delegateQueue: queue)
    }
    
    func upload(image: UIImage, completion: ((URL?) -> Void)? = nil) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/tickets/upload"), let png = image.jpegData(compressionQuality: 0.5) else {
            completion?(nil)
            return
        }
        
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue(GlobalDefinitions.apiKey, forHTTPHeaderField: "api_key")
        request.addValue(SessionManager().getSession()?.userToken ?? "", forHTTPHeaderField: "user_token")
        
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(UUID().uuidString).jpeg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(png)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: request, from: data) { data, response, error in
            let url: URL? = {
                guard 
                    let data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let path = json["image_url"] as? String
                else { return nil }
                
                return URL(string: path)
            }()
            completion?(url)
        }.resume()
    }
}




struct UploadResponse: Codable {
    let image_url: String
    let numbers: [[Int]]
    let date_of_game: Double?
}
enum UploadError: Error {
    case invalidImageData
    case invalidResponse
    case serverError(String)
}


struct TicketScanUploadImage {
    let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = false
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        
        session = URLSession(configuration: config, delegate: nil, delegateQueue: queue)
    }

        
    func upload(image: UIImage, completion: ((UploadResponse?) -> Void)? = nil) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/tickets/upload"),
              let jpegData = image.jpegData(compressionQuality: 1) else {
            completion?(nil)
            return
        }
        
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue(GlobalDefinitions.apiKey, forHTTPHeaderField: "api_key")
        request.addValue(SessionManager().getSession()?.userToken ?? "", forHTTPHeaderField: "user_token")
        
        var bodyData = Data()
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(UUID().uuidString).jpeg\"\r\n".data(using: .utf8)!)
        bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        bodyData.append(jpegData)
        bodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: request, from: bodyData) { data, response, error in
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let imageUrl = json["image_url"] as? String,
                  let numbers = json["numbers"] as? [[String]],
                  let dateOfGame = json["date_of_game"] as? Double else {
                completion?(nil)
                return
            }
          
            
            var int2DArray: [[Int]] = []

            for row in numbers {
                var intRow: [Int] = []
                for stringValue in row {
                    if let intValue = Int(stringValue) {
                        intRow.append(intValue)
                    }
                }
                int2DArray.append(intRow)
            }
            
            // Create an UploadResponse instance with the parsed data
            let uploadResponse = UploadResponse(image_url: imageUrl, numbers: int2DArray, date_of_game: dateOfGame)
            completion?(uploadResponse)
        }.resume()
    }

}
