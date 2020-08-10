//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

protocol Interactor: class {
    func presentTraining(confirm: Bool)
    func presentScores(_ scores: [(date: Date, score: Double)])
    func presentErrorAlert(title: String, message: String, completion: (() -> Void)?)
    func presentTerminalError(message: String)
}
