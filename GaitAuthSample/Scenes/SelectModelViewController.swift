//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit

class SelectModelViewController: UIViewController {
    weak var delegate: ModelSelector?

    @IBAction func createModel() {
        delegate?.createModel()
    }

    @IBAction func loadModel() {
        presentConfirmation(
            title: "Load",
            message: "Simulate loading a model",
            actionTitle: "Load"
            ) { confirmed in
                guard confirmed else { return }
                self.delegate?.loadModel("92d0476f-7303-4958-aad9-da37c4af1bee")
        }
    }
}
