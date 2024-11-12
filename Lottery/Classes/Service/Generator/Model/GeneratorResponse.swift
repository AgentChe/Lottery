//
//  GeneratorResponse.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/8/24.
//

import Foundation

// Updated GeneratorResponse struct without CodingKeys
struct GeneratorResponse: Codable {
    let numbers: [[Int]]
    let scoreOfNumbers: AnalyticsData
    let regularNumbersFrequency: AnalyticsData
    let skippedNumbersAnalytics: AnalyticsData
    let consecutiveNumbersAnalytics: AnalyticsData
}

// Updated AnalyticsData struct with CodingKeys to handle 'description'
struct AnalyticsData: Codable {
    let title: String
    let value: String
    let infoDescription: String // Renamed from 'description' to 'infoDescription'
    
    enum CodingKeys: String, CodingKey {
        case title
        case value
        case infoDescription = "description"
    }
}
