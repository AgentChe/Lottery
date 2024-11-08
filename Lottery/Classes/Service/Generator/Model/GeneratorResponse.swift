//
//  GeneratorResponse.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/8/24.
//

import Foundation

struct GeneratorResponse: Codable {
    let numbers: [[Int]]
    let scoreOfNumbers: AnalyticsData
    let regularNumbersFrequency: AnalyticsData
    let skippedNumbersAnalytics: AnalyticsData
    let consecutiveNumbersAnalytics: AnalyticsData

    enum CodingKeys: String, CodingKey {
        case numbers
        case scoreOfNumbers = "score_of_numbers"
        case regularNumbersFrequency = "regular_numbers_frequency"
        case skippedNumbersAnalytics = "skipped_numbers_analytics"
        case consecutiveNumbersAnalytics = "consecutive_numbers_analytics"
    }
}

struct AnalyticsData: Codable {
    let title: String
    let value: String
    let description: String
}
