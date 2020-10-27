//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit

private let alertPresentationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "AlertPresentationQueue"
    queue.maxConcurrentOperationCount = 1
    return queue
}()

extension UIViewController {
    func presentConfirmation(
        title: String,
        message: String? = nil,
        cancelTitle: String = "Cancel",
        actionTitle: String = "Confirm",
        completion: @escaping (Bool) -> Void
    ) {
        let wrappedCompletion: (Bool) -> Void = { confirmed in
            DispatchQueue.main.async {
                completion(confirmed)
                alertPresentationQueue.isSuspended = false
            }
        }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            wrappedCompletion(false)
        })
        alert.addAction(
            UIAlertAction(title: actionTitle, style: .destructive) { _ in
                wrappedCompletion(true)
            }
        )

        alertPresentationQueue.addOperation {
            alertPresentationQueue.isSuspended = true
            DispatchQueue.main.sync {
                self.present(alert, animated: true)
            }
        }
    }

    func presentAlert(
        title: String,
        message: String? = nil,
        cancelTitle: String = "Cancel",
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            DispatchQueue.main.async {
                completion?()
                alertPresentationQueue.isSuspended = false
            }
        })

        alertPresentationQueue.addOperation {
            alertPresentationQueue.isSuspended = true
            DispatchQueue.main.sync {
                self.present(alert, animated: true)
            }
        }
    }

    func presentError(
        title: String,
        message: String? = nil,
        completion: (() -> Void)? = nil
    ) {
        presentAlert(title: title, message: message, completion: completion)
    }

    func presentError(
        title: String,
        error: Error,
        completion: (() -> Void)? = nil
    ) {
        presentAlert(title: title, message: error.localizedDescription, completion: completion)
    }

    func presentInputAlert(
        title: String,
        prompt: String? = nil,
        cancelTitle: String = "Cancel",
        confirmTitle: String = "Confirm",
        completion: ((String?) -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: prompt,
            preferredStyle: .alert
        )
        alert.addTextField()

        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            DispatchQueue.main.async {
                completion?(nil)
                alertPresentationQueue.isSuspended = false
            }
        })
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
            DispatchQueue.main.async {
                let input = alert.textFields?.first?.text
                completion?(input)
                alertPresentationQueue.isSuspended = false
            }
        })

        alertPresentationQueue.addOperation {
            alertPresentationQueue.isSuspended = true
            DispatchQueue.main.sync {
                self.present(alert, animated: true)
            }
        }
    }
}
