//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit

/// Protocol to provide support for limited UI functionality from non-view code.
protocol Interactor: class {
    /// Presents a UIAlertController with the provided title and message.
    func presentAlert(
        title: String,
        message: String?,
        cancelTitle: String,
        completion: (() -> Void)?
    )
}

extension Interactor {
    /// Presents a UIAlertController with the provided title and message.
    /// Default implementation to give default values to optional protocol parameters.
    func presentAlert(
        title: String,
        message: String? = nil,
        cancelTitle: String = "Cancel",
        completion: (() -> Void)? = nil
    ) {
        presentAlert(title: title, message: message, cancelTitle: cancelTitle, completion: completion)
    }
}

/// A `UIViewController` extension is already expected to add the alert functionality
/// to all `UIViewController` instances.
extension UIViewController: Interactor {}
