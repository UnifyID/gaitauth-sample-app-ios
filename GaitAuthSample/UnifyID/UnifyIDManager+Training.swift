//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth

/// Extension to allow `UnifyIDManager` to wrap and handle
/// errors from the UnifyID SDK model training related functions.
extension UnifyIDManager: ModelTrainer {
    /// A soft limit to avoid adding packets with very few training features.
    private static let minFeaturesToAdd = 10
    private static let maxFeatureBatchSize = 500

    /// Initiate model training.
    ///
    /// Presents an error if the model or UnifyID SDk is not initialized or if
    /// the training operation fails to start successfully.
    ///
    /// After initiating training, the model will be refreshed until it is
    /// ready or the training operation fails.
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

    /// Adds all of the features currently collected in the training buffer.
    /// Presents an error if the model is not initialized or if there are too few
    /// features available in the buffer.
    func addCollectedFeatures() {
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

        featureBuffer.flush(count: Self.maxFeatureBatchSize) { [weak self] items, flushComplete in
            DispatchQueue.main.async {
                guard let self = self else { return }
                model.add(items) {
                    if let error = $0 {
                        flushComplete(false)
                        self.interactor?.presentErrorAlert(
                            title: "Failed Adding Features",
                            message: error.localizedDescription
                        )
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
