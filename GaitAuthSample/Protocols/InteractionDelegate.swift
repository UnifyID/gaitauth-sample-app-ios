//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

protocol Interactor: class {
    func presentPending()
    func presentScores(_ scores: [(date: Date, score: Double)])
    func presentErrorAlert(title: String, message: String, completion: (() -> Void)?)
    func presentTerminalError(message: String)

    func presentConfirmation(
        title: String,
        message: String?,
        cancelTitle: String,
        actionTitle: String,
        completion: @escaping (Bool) -> Void
    )
}

extension Interactor {
    func presentErrorAlert(title: String, message: String) {
        presentErrorAlert(title: title, message: message, completion: nil)
    }
}
