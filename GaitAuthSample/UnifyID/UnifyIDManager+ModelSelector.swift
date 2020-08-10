//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

extension UnifyIDManager: ModelSelector {
    func createModel() {
        NotificationCenter.default.post(
            ActiveModelDidChangeNotification(
                sender: self,
                modelID: "0779325d-f53b-43b2-9d02-6454a9cfbba1",
                status: .created
            )
        )
    }

    func loadModel(_ id: String) {
        NotificationCenter.default.post(
            ActiveModelDidChangeNotification(
                sender: self,
                modelID: id,
                status: .ready
            )
        )
    }
}
