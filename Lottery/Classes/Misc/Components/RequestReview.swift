//
//  RequestReview.swift
//  Soccer
//
//  Created by Андрей Чернышев on 10.11.2022.
//

import StoreKit

final class RequestReview {
    struct Constants {
        static let wasRequestedKey = "request_review_was_requested_key"
    }

    static func requestOnce() {
        guard !UserDefaults.standard.bool(forKey: Constants.wasRequestedKey) else {
            return
        }

        UserDefaults.standard.setValue(true, forKey: Constants.wasRequestedKey)

        request()
    }

    static func request() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }

        DispatchQueue.main.async {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
