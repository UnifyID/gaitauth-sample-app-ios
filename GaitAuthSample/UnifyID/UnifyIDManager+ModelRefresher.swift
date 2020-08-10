//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

extension UnifyIDManager: ModelRefresher {
    func refreshModel() {
        DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval.random(in: 0.5...2.0)) {
            DispatchQueue.main.async {
                // guard let model = self.model else { return }
                NotificationCenter.default.post(
                    ModelDidRefreshNotification(
                        sender: self,
                        date: Date(),
                        modelID: "136f2019-326e-48e5-90e9-129433f20f86",
                        status: .training,
                        changeType: .noChange
                    )
                )
                self.refreshCount += 1
            }
        }
    }
}
