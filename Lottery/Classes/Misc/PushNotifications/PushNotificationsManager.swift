//
//  PushNotificationsManager.swift
//  Soccer
//
//  Created by Андрей Чернышев on 28.06.2022.
//

import FirebaseMessaging
import Firebase

protocol PushNotificationsDelegate: AnyObject {
    func pushNotificationsDidReceive(authorizationStatus: PushNotificationsAuthorizationStatus)
    func pushNotificationsDidReceive(token: String?)
    func pushNotificationsDidReceive(model: PushNotificationsModel, completion: @escaping () -> Void)
}

final class PushNotificationsManager: NSObject, MessagingDelegate {
    static let shared = PushNotificationsManager()
    
    private let notificationsCenter = UNUserNotificationCenter.current()
    
    private var delegates = [Weak<PushNotificationsDelegate>]()
    
    // Add properties to manage notification queue
    private let notificationQueue = DispatchQueue(label: "com.yourapp.notificationQueue", attributes: .concurrent)
    private var pendingNotifications: [PushNotificationsModel] = []
    private var isProcessingNotification = false

    private override init() {
        super.init()
        notificationsCenter.delegate = self
        Messaging.messaging().delegate = self
    }
}

// MARK: UNUserNotificationCenterDelegate
extension PushNotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        received(userInfo: response.notification.request.content.userInfo)
        completionHandler() // Call the completion handler to let the system know we're done
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("userNotificationCenter(_:willPresent:) called")
        completionHandler([.alert, .sound])
        // If you want to handle the notification when the app is in foreground, uncomment the following lines:
        // received(userInfo: notification.request.content.userInfo)
        // completionHandler([])
    }
}

// MARK: Public
extension PushNotificationsManager {
    func retriveAuthorizationStatus(handler: ((PushNotificationsAuthorizationStatus) -> Void)?) {
        notificationsCenter.getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                let result: PushNotificationsAuthorizationStatus
                
                switch settings.authorizationStatus {
                case .authorized:
                    result = .authorized
                case .notDetermined:
                    result = .notDetermined
                default:
                    result = .denied
                }
                
                handler?(result)
                self?.delegates.forEach { $0.weak?.pushNotificationsDidReceive(authorizationStatus: result) }
            }
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationsCenter.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion(granted) // Call the completion handler with the result
            }
        }
    }
    
    func add(observer: PushNotificationsDelegate) {
        let weakly = observer as AnyObject
        delegates.append(Weak<PushNotificationsDelegate>(weakly))
        delegates = delegates.filter { $0.weak != nil }
    }
    
    func remove(observer: PushNotificationsDelegate) {
        if let index = delegates.firstIndex(where: { $0.weak === observer }) {
            delegates.remove(at: index)
        }
    }
}

// MARK: Private
private extension PushNotificationsManager {
    func received(pushToken: Data?, error: Error?) {
        Messaging.messaging().apnsToken = pushToken
        
        DispatchQueue.main.async { [weak self] in
            if error == nil, let token = Messaging.messaging().fcmToken {
                self?.delegates.forEach { $0.weak?.pushNotificationsDidReceive(token: token) }
            } else {
                self?.delegates.forEach { $0.weak?.pushNotificationsDidReceive(token: nil) }
            }
        }
    }
    
    func received(userInfo: [AnyHashable: Any]) {
        let model = PushNotificationsModel(userInfo: userInfo)
        enqueueNotification(model)
    }
    
    // Enqueue the notification for sequential processing
    private func enqueueNotification(_ model: PushNotificationsModel) {
        notificationQueue.async(flags: .barrier) {
            self.pendingNotifications.append(model)
            self.processNextNotification()
        }
    }
    
    // Process notifications one by one
    private func processNextNotification() {
        notificationQueue.async {
            guard !self.isProcessingNotification, let nextNotification = self.pendingNotifications.first else {
                return
            }
            
            self.isProcessingNotification = true
            self.pendingNotifications.removeFirst()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let dispatchGroup = DispatchGroup()
                for delegate in self.delegates {
                    dispatchGroup.enter()
                    delegate.weak?.pushNotificationsDidReceive(model: nextNotification) {
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.isProcessingNotification = false
                    self.processNextNotification()
                }
            }
        }
    }
}

extension PushNotificationsManager {
    // MARK: MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("Получен FCM-токен: \(fcmToken)")
        
        // Отправка FCM-токена на сервер
        sendFCMTokenToServer(fcmToken)
        
        // Уведомление делегатов
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach { $0.weak?.pushNotificationsDidReceive(token: fcmToken) }
        }
    }
    
    private func sendFCMTokenToServer(_ fcmToken: String) {
        let sessionManager: SessionManagerProtocol = SessionManager()
        guard let url = URL(string: "https://lottery.camplain-apps.com/profile/push_token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let userToken = sessionManager.getSession()?.userToken else {
            fatalError()
        }
        
        let parameters: [String: Any] = [
            "api_key":  GlobalDefinitions.apiKey,
            "user_token": userToken,
            "registration_token": fcmToken
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Ошибка сериализации JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка отправки FCM-токена на сервер: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Некорректный ответ от сервера")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("FCM-токен успешно отправлен на сервер")
            } else {
                print("Не удалось отправить FCM-токен на сервер: HTTP \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
}
