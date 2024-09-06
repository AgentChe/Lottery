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
}

struct TicketUploadResponse {
    let imageUrl: String
    let detected: Int
    let scratchOff: ScratchOff
}

extension TicketUploadResponse {
    init?(json: [String: Any]) {
        guard
            let imageUrl = json["image_url"] as? String,
            let detected = json["detected"] as? Int,
            let scratchOffDict = json["ticket_data"] as? [String: Any],
            let raw = scratchOffDict["raw"] as? String,
            let title = scratchOffDict["title"] as? String,
            let company = scratchOffDict["company"] as? String,
            let analyze = scratchOffDict["analyze"] as? String
        else {
            return nil
        }
        
        let scratchOff = ScratchOff(raw: raw, title: title, company: company, analyze: analyze)
        self.imageUrl = imageUrl
        self.detected = detected
        self.scratchOff = scratchOff
    }
}
struct TicketUploadImageForScratchScan {
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
    
    func upload(image: UIImage, completion: ((TicketUploadResponse?) -> Void)? = nil) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/scratchoffs/upload"), let png = image.jpegData(compressionQuality: 0.5) else {
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
            let ticketResponse: TicketUploadResponse? = {
                guard
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                else { return nil }
                
                return TicketUploadResponse(json: json)
            }()
            completion?(ticketResponse)
        }.resume()
    }
    
    func fetchScratchOffsList(completion: @escaping ([TicketUploadResponse]?) -> Void) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/scratchoffs/list") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(GlobalDefinitions.apiKey, forHTTPHeaderField: "api_key")
        request.addValue(SessionManager().getSession()?.userToken ?? "", forHTTPHeaderField: "user_token")
        
        session.dataTask(with: request) { data, response, error in
            let scratchOffList: [TicketUploadResponse]? = {
                guard
                    let data = data,
                    let jsonArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]]
                else { return nil }
                
                return jsonArray.compactMap { TicketUploadResponse(json: $0) }
            }()
            
            completion(scratchOffList)
        }.resume()
    }
    
    func saveScratchOff(ticket: TicketUploadResponse, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/scratchoffs/save") else {
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(GlobalDefinitions.apiKey, forHTTPHeaderField: "api_key")
        request.addValue(SessionManager().getSession()?.userToken ?? "", forHTTPHeaderField: "user_token")
        
        // Prepare JSON data from TicketUploadResponse
        let jsonDict: [String: Any] = [
            "image_url": ticket.imageUrl,
            "detected": ticket.detected,
            "ticket_data": [
                "raw": ticket.scratchOff.raw,
                "title": ticket.scratchOff.title,
                "company": ticket.scratchOff.company,
                "analyze": ticket.scratchOff.analyze
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            completion?(false)
            return
        }
        
        request.httpBody = jsonData
        
        session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                completion?(false)
                return
            }
            
            completion?(true)
        }.resume()
    }
//   example of use:
//    let ticketUploadResponse = TicketUploadResponse(
//        imageUrl: "https://example.com/image.jpg",
//        detected: 1,
//        scratchOff: ScratchOff(raw: "raw_data", title: "Title", company: "Company", analyze: "Analysis")
//    )
//
//    let api = TicketUploadImageForScratchScan()
//    api.saveScratchOff(ticket: ticketUploadResponse) { success in
//        if success {
//            print("Ticket saved successfully!")
//        } else {
//            print("Failed to save the ticket.")
//        }
//    }
}
