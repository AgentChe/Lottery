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
    static let amplitudeApiKey = "d433d2c66723aeefd10c5b65f91c1fa3"
    
    static let termsOfUseUrl = URL(string: "https://camplain-apps.com/terms-of-use.html")!
    static let privacyPolicyUrl = URL(string: "https://camplain-apps.com/privacy-policy.html")!
    static let contactUsUrl = URL(string: "https://camplain-apps.com/contacts.html")!
    
    // TODO: заменить
    enum Paygate {
        static let defaultLifetime = "app.iphone.tracker.yearly"
        static let defaultMonthly = "app.iphone.tracker.weekly"
    }
}
