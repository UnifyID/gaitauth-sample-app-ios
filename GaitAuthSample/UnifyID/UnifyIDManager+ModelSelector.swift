//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

/// Extends UnifyIDManager to implement the logic for creating and loading models using the UnifyID SDK.
extension UnifyIDManager: ModelSelector {
    /// Creates a new GaitAuth model, updates the `model` and `modelID` properties
    /// and then posts a notification with the new model's `id` and `status`.
    func createModel() {
        guard let gaitAuth = gaitAuth else {
            interactor?.presentErrorAlert(
                title: "Failed Creating Model",
                message: "GaitAuth not initialized"
            )
            return
        }

        gaitAuth.createModel { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.interactor?.presentErrorAlert(
                        title: "Failed Creating Model",
                        message: error.localizedDescription
                    )
                case .success(let model):
                    self.model = model
                    self.modelID = model.id
                    NotificationCenter.default.post(
                        ActiveModelDidChangeNotification(
                            sender: self,
                            modelID: model.id,
                            status: .created
                        )
                    )
                }
            }
        }
    }

    /// Loads an existing GaitAuth model, updates the `model` and `modelID` properties
    /// and then posts a notification with the loaded model's `id` and `status`.
    func loadModel(_ id: String) {
        guard let gaitAuth = gaitAuth else {
            interactor?.presentErrorAlert(
                title: "Failed Loading Model",
                message: "GaitAuth not initialized"
            )
            return
        }

        gaitAuth.loadModel(withIdentifier: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.interactor?.presentErrorAlert(
                        title: "Failed Loading Model",
                        message: error.localizedDescription
                    )
                case .success(let model):
                    self.model = model
                    self.modelID = model.id
                    NotificationCenter.default.post(
                        ActiveModelDidChangeNotification(
                            sender: self,
                            modelID: model.id,
                            status: model.status
                        )
                    )
                }
            }
        }
    }
}
