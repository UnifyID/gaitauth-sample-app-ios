//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth

/// Notification that fires when the active model changes.
struct ActiveModelDidChangeNotification: TypedNotification {
    /// UnifyIDManager instance that fired the notification.
    let sender: UnifyIDManager

    /// Identifier of the newly selected model.
    let modelID: String

    /// Status of the newly selected model.
    let status: GaitModel.Status
}
