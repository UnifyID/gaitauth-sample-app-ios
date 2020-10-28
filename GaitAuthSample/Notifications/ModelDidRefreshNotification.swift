//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth

/// Notification that fires when the active model was refreshed successfully.
struct ModelDidRefreshNotification: TypedNotification {
    /// UnifyIDManager instance that fired the notification.
    let sender: UnifyIDManager

    /// Date of the refresh action.
    let date: Date

    /// Identifier of the model that was refreshed.
    let modelID: String

    /// Status of the model after it was refreshed.
    let status: GaitModel.Status

    /// Type of change indicated by the refresh operation.
    let changeType: GaitModel.ChangeType
}
