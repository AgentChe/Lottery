//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://lottery.camplain-apps.com"
    static let apiKey = "CVW34OdTfiTKzKHCMAI0unHpotOOSePkXRG10rehoSRfyv0aKaAWApHydxhFaYftyfoXFuW3utyhrZSQtqjcWl994tPfd4QHu5jfdxQP5cDDRMXvz0H2iHw6TXdO9WUL"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "3mpDyKfrgqTq0ceJ"
    
    static let applicationTag = "LOTTERY"
    static let amplitudeApiKey = "784ee0e6cb07cb515f3b080b4b415b27"
    
    static let termsOfUseUrl = URL(string: "https://camplain-apps.com/terms-of-use.html")!
    static let privacyPolicyUrl = URL(string: "https://camplain-apps.com/privacy-policy.html")!
    static let contactUsUrl = URL(string: "https://camplain-apps.com/contacts.html")!
    
    enum Paygate {
        static let defaultLifetime = "app.iphone.tracker.lifetime"
        static let defaultMonthly = "app.iphone.tracker.weekly2"
    }
}
