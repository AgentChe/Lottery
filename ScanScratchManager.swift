//
//  TicketUploadImageForScratchScan.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/5/24.
//

import UIKit

struct ScratchOff: Codable {
    let raw: String
    let title: String
    let company: String
    let analyze: String
    let imageUrl: String
    let date: Date?
}

extension ScratchOff {
    init?(json: [String: Any]) {
        guard
            let raw = json["raw"] as? String,                     // Extract raw directly
            let title = json["title"] as? String,                 // Extract title directly
            let company = json["company"] as? String,             // Extract company directly
            let analyze = json["analyze"] as? String,             // Extract analyze directly
            let imageUrl = json["image_url"] as? String           // Extract image_url directly
        else {
            return nil
        }

        // Attempt to extract and parse the date, if present
        var date: Date? = nil
        if let dateString = json["date"] as? String {
            let dateFormatter = ISO8601DateFormatter()
            date = dateFormatter.date(from: dateString)
        }
        
        // Assign values to properties
        self.raw = raw
        self.title = title
        self.company = company
        self.analyze = analyze
        self.imageUrl = imageUrl
        self.date = date
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
        print("apiKey: \(GlobalDefinitions.apiKey)")
        print("userToken: \(SessionManager().getSession()?.userToken )")
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
                  let ticketData = json["ticket_data"] as? [String: Any],
                  let raw = ticketData["raw"] as? String,
                  let title = ticketData["title"] as? String,
                  let company = ticketData["company"] as? String,
                  let analyze = ticketData["analyze"] as? String else {
                completion?(nil)
                return
            }

            // Create the ScratchOff instance with the parsed data
            let scratchOff = ScratchOff(raw: raw, title: title, company: company, analyze: analyze, imageUrl: imageUrl,date: nil)
            completion?(scratchOff)
        }.resume()
    }

    
    func list(completion: @escaping ([ScratchOff]?) -> Void) {
        guard let url = URL(string: "https://lottery.camplain-apps.com/api/scratchoffs/list") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the request body with the required parameters
        let body: [String: Any] = [
            "user_token": SessionManager().getSession()?.userToken ?? "anon_id_arntzanmtrfmtmytrmlkwxaudpmkagpsbqxswvkqxbtenserytjswwathmipfmao",
            "api_key": GlobalDefinitions.apiKey
        ]
        
        // Convert body dictionary to JSON data
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                // Print raw JSON string for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                
                // Try to parse the JSON as an array of dictionaries
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
                    print("Failed to parse JSON as array")
                    completion(nil)
                    return
                }
                
                var scratchOffList: [ScratchOff] = []
                
                // Loop through each item in the JSON array
                for jsonItem in jsonArray {
                    // Extract ticket_data dictionary
                    guard let ticketData = jsonItem["ticket_data"] as? [String: Any],
                          let raw = ticketData["raw"] as? String,
                          let title = ticketData["title"] as? String,
                          let company = ticketData["company"] as? String,
                          let analyze = ticketData["analyze"] as? String,
                          let imageUrl = jsonItem["image_url"] as? String,
                          let dateTimestamp = jsonItem["date"] as? Double else {
                        print("Failed to parse required fields for one item")
                        continue
                    }
                    
                    // Convert the timestamp to a Date object
                    let date = Date(timeIntervalSince1970: dateTimestamp)
                    
                    // Create a ScratchOff object and add it to the list
                    let scratchOff = ScratchOff(
                        raw: raw,
                        title: title,
                        company: company,
                        analyze: analyze,
                        imageUrl: imageUrl,
                        date: date
                    )
                    
                    scratchOffList.append(scratchOff)
                }
                
                completion(scratchOffList)
                
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func save(scratchOff: ScratchOff, completion: ((Bool) -> Void)? = nil) {
           guard let url = URL(string: "https://lottery.camplain-apps.com/api/scratchoffs/save") else {
               completion?(false)
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           
           
           let body: [String: Any] = [
               "api_key": GlobalDefinitions.apiKey,
               "user_token": SessionManager().getSession()?.userToken ?? "anon_id",
               "image_url": scratchOff.imageUrl,
               "ticket_data": [
                   "raw": scratchOff.raw,
                   "title": scratchOff.title,
                   "company": scratchOff.company,
                   "analyze": scratchOff.analyze
               ]
           ]
           
           
           request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
           
           
           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Error occurred: \(error.localizedDescription)")
                   completion?(false)
                   return
               }
               
               guard let data = data else {
                   print("No data received")
                   completion?(false)
                   return
               }
               
               do {
                   // Parse the response JSON
                   if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                      let result = json["result"] as? Bool {
                       completion?(result)
                   } else {
                       completion?(false)
                   }
               } catch {
                   print("JSON parsing error: \(error.localizedDescription)")
                   completion?(false)
               }
           }.resume()
       }




}
