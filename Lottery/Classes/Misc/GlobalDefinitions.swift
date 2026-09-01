//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://lottery.thinkaboutapps.com"
    static let apiKey = "CVW34OdTfiTKzKHCMAI0unHpotOOSePkXRG10rehoSRfyv0aKaAWApHydxhFaYftyfoXFuW3utyhrZSQtqjcWl994tPfd4QHu5jfdxQP5cDDRMXvz0H2iHw6TXdO9WUL"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "3mpDyKfrgqTq0ceJ"

    static let applicationTag = "LOTTERY"
    static let postHogHost = "https://posthog.korrekted.com"
    static let postHogApiKey = "phc_a29Kj3MGr3nLv9NN4WLZiRyHF5mluQZaPbVgcCbIqPa"
    
    static let termsOfServiceUrl = URL(string: "https://thinkaboutapps.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://thinkaboutapps.com/policy")!
    static let contactUsUrl = URL(string: "https://thinkaboutapps.com/contact")!
    
    enum Paygate {
        static let defaultLifetime = "app.iphone.tracker.lifetime"
        static let defaultMonthly = "app.iphone.tracker.weekly2"
    }
}
