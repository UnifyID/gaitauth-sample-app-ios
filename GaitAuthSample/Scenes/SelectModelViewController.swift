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
        presentSingleInputAlert(
            title: "Load Model",
            prompt: "Please enter a valid model id."
        ) { [weak self] modelID in
            guard let self = self else { return }
            guard
                let modelID = modelID?.trimmingCharacters(in: .whitespaces),
                let modelUUID = UUID(uuidString: modelID)
            else {
                self.presentAlert(title: "Invalid Model ID") { [weak self] in
                    DispatchQueue.main.async {
                        self?.loadModel()
                    }
                }
                return
            }
            self.delegate?.loadModel(modelUUID.uuidString.lowercased())
        }
    }
}
