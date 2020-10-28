//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit

class SelectModelViewController: UIViewController {
    unowned var manager: ModelSelector = unifyid

    @IBAction func createModel() {
        manager.createModel()
    }

    @IBAction func loadModel() {
        presentInputAlert(
            title: "Load Model",
            prompt: "Please enter a valid model id."
        ) { [weak self] modelID in
            guard let self = self else { return }
            guard
                let modelID = modelID?.trimmingCharacters(in: .whitespaces),
                let modelUUID = UUID(uuidString: modelID)
            else {
                self.presentAlert(title: "Invalid Model ID")
                return
            }
            self.manager.loadModel(modelUUID.uuidString.lowercased())
        }
    }
}
