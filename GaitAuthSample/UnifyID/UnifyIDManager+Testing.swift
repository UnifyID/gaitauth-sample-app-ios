//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth

extension UnifyIDManager: ModelTester {
    func presentAuthenticationResult(_ result: AuthenticationResult) {
        dispatchPrecondition(condition: .onQueue(.main))
        let scores = result.context[.featureScores] as? [GaitScore] ?? []
        self.interactor?.presentScores(scores.map { (date: $0.date, score: $0.value) })
    }
}
