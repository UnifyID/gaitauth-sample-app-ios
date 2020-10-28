//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

/// Protocol for the subset of operations that a view refresher must be
/// able to support.
protocol ModelRefresher: class {
    /// Refreshes the active model and posts a notification when the operation is complete.
    func refreshModel()
}
