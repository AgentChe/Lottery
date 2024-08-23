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
    
    func upload(image: UIImage, competion: ((URL?) -> Void)? = nil) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/tickets/upload"), let png = image.jpegData(compressionQuality: 0.5) else {
            competion?(nil)
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
            competion?(url)
        }.resume()
    }
}
