//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

/// Notification that fires when the collection state changes.
struct CollectionStateDidChangeNotification: TypedNotification {
    /// UnifyIDManager instance that fired the notification.
    let sender: UnifyIDManager
    /// New collection state.
    let isCollecting: Bool
}
