//
//  TicketUploadImageForScratchScan.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/5/24.
//

import UIKit

struct ScratchOff {
    let raw: String
    let title: String
    let company: String
    let analyze: String
    let imageUrl: String
    let detected: Int
}

extension ScratchOff {
    init?(json: [String: Any]) {
        guard
            let raw = json["raw"] as? String,                     // Extract raw directly
            let title = json["title"] as? String,                 // Extract title directly
            let company = json["company"] as? String,             // Extract company directly
            let analyze = json["analyze"] as? String,             // Extract analyze directly
            let imageUrl = json["image_url"] as? String,          // Extract image_url directly
            let detected = json["detected"] as? Int               // Extract detected directly
        else {
            return nil
        }

        // Assign values to properties
        self.raw = raw
        self.title = title
        self.company = company
        self.analyze = analyze
        self.imageUrl = imageUrl
        self.detected = detected
    }
}


struct ScanScratchManager {
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
    
    func analyze(image: UIImage, completion: ((ScratchOff?) -> Void)? = nil) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/scratchoffs/analyze"),
              let imageData = image.jpegData(compressionQuality: 0.5) else {
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
        bodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(UUID().uuidString).jpeg\"\r\n".data(using: .utf8)!)
        bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        bodyData.append(imageData)
        bodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: request, from: bodyData) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let imageUrl = json["image_url"] as? String,
                  let detected = json["detected"] as? Int,
                  let ticketData = json["ticket_data"] as? [String: Any],
                  let raw = ticketData["raw"] as? String,
                  let title = ticketData["title"] as? String,
                  let company = ticketData["company"] as? String,
                  let analyze = ticketData["analyze"] as? String else {
                completion?(nil)
                return
            }

            // Create the ScratchOff instance with the parsed data
            let scratchOff = ScratchOff(raw: raw, title: title, company: company, analyze: analyze, imageUrl: imageUrl, detected: detected)
            completion?(scratchOff)
        }.resume()
    }

    
    func fetchScratchOffsList(completion: @escaping ([ScratchOff]?) -> Void) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/scratchoffs/list") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(GlobalDefinitions.apiKey, forHTTPHeaderField: "api_key")
        request.addValue(SessionManager().getSession()?.userToken ?? "", forHTTPHeaderField: "user_token")
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let jsonArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
                completion(nil)
                return
            }
            
            let scratchOffList = jsonArray.compactMap { ScratchOff(json: $0) }
            completion(scratchOffList)
        }.resume()
    }
    
    func saveScratchOff(ticket: ScratchOff, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/scratchoffs/save") else {
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(GlobalDefinitions.apiKey, forHTTPHeaderField: "api_key")
        request.addValue(SessionManager().getSession()?.userToken ?? "", forHTTPHeaderField: "user_token")
        
        let jsonDict: [String: Any] = [
            "image_url": ticket.imageUrl,
            "detected": ticket.detected,
            "raw": ticket.raw,
            "title": ticket.title,
            "company": ticket.company,
            "analyze": ticket.analyze
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            completion?(false)
            return
        }
        
        request.httpBody = jsonData
        
        session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200, error == nil else {
                completion?(false)
                return
            }
            
            completion?(true)
        }.resume()
    }

}
