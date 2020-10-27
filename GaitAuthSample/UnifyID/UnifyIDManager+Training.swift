//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth

extension UnifyIDManager: ModelTrainer {
    private static let minFeaturesToAdd = 10

    func trainModel() {
        dispatchPrecondition(condition: .onQueue(.main))

        guard let model = self.model else {
            interactor?.presentErrorAlert(
                title: "Train Model Failed",
                message: "Model is not initialized"
            )
            return
        }

        model.train { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.interactor?.presentErrorAlert(
                        title: "Train Model Failed",
                        message: error.localizedDescription
                    )
                    return
                }
                self.interactor?.presentPending()
            }
        }
    }

    func addCollectedFeatures(completion: ((Error) -> Void)? = nil) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard featureCollectionCount >= Self.minFeaturesToAdd else {
            interactor?.presentErrorAlert(
                title: "More features required",
                message: "Please collect at least \(Self.minFeaturesToAdd) features before adding.")
            return
        }

        guard let model = self.model else {
            interactor?.presentErrorAlert(
                title: "Train Model Failed",
                message: "Model is not initialized"
            )
            return
        }

        featureBuffer.flush(count: 500) { [weak self] items, flushComplete in
            DispatchQueue.main.async {
                guard let self = self else { return }
                model.add(items) {
                    if let error = $0 {
                        completion?(error)
                        flushComplete(false)
                        return
                    }
                    flushComplete(true)
                    self.featureBuffer.getCount { [weak self] count in
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.featureCollectionCount = count
                            NotificationCenter.default.post(
                                DidCollectFeaturesNotification(
                                    sender: self,
                                    newFeatureCount: 0,
                                    totalFeaturesCollected: count
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}
