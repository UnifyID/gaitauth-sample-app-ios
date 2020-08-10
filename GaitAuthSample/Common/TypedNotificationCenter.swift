//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//
// Code adapted from NSScreencast (MIT LICENSE):
// https://github.com/nsscreencast/410-typed-notifications

import Foundation

protocol TypedNotification {
    associatedtype Sender
    static var name: String { get }
    var sender: Sender { get }
}

extension TypedNotification {
    static var name: String { String(describing: Self.self) }
    static var notificationName: Notification.Name {
        return Notification.Name(rawValue: name)
    }
}

protocol TypedNotificationCenter {
    /// Post a typed notification.
    func post<N: TypedNotification>(_ notification: N)

    /// Add an observer for a typed notification.
    @discardableResult
    func addObserver<N: TypedNotification>(
        for: N.Type,
        sender: N.Sender?,
        queue: OperationQueue?,
        using block: @escaping (N) -> Void
    ) -> NSObjectProtocol
}

extension NotificationCenter: TypedNotificationCenter {
    static var typedNotificationUserInfoKey = "_TypedNotification"

    func post<N>(_ notification: N) where N: TypedNotification {
        post(
            name: N.notificationName,
            object: notification.sender,
            userInfo: [
                NotificationCenter.typedNotificationUserInfoKey: notification
            ]
        )
    }

    @discardableResult
    func addObserver<N>(
        for: N.Type,
        sender: N.Sender? = nil,
        queue: OperationQueue? = nil,
        using block: @escaping (N) -> Void
    ) -> NSObjectProtocol where N: TypedNotification {
        return addObserver(forName: N.notificationName, object: sender, queue: queue) { notification in
            guard let userInfo = notification.userInfo,
                let typedNotification = userInfo[NotificationCenter.typedNotificationUserInfoKey] as? N else {
                fatalError("Failed reading typed object: \(N.name) from notification: \(notification)")
            }
            block(typedNotification)
        }
    }
}
