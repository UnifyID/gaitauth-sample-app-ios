//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

/// Notification that fires when the collection state changes.
struct DidCollectFeaturesNotification: TypedNotification {
    /// UnifyIDManager instance that fired the notification.
    let sender: UnifyIDManager
    /// Count of new features added.
    let newFeatureCount: Int
    /// Total features collected.
    let totalFeaturesCollected: Int
}
