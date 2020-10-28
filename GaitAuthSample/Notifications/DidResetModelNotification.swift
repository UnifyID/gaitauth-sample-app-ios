//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

/// Notification that fires when the model is reset.
struct DidResetModelNotification: TypedNotification {
    /// UnifyIDManager instance that fired the notification.
    let sender: UnifyIDManager
}
