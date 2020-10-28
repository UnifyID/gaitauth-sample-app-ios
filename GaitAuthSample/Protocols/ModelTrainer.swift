//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

/// Protocol representing the interface required to train a model.
protocol ModelTrainer: class {
    /// Returns the number of features currently collected in the buffer.
    var featureCollectionCount: Int { get }

    /// If set to `true`, features will be collected into the training buffer.
    /// If set to `false`, feature collection will be stopped.
    var isCollectingFeatures: Bool { get set }

    /// Initiates model training.
    /// If the model is not initialized or the model is not in a state
    /// that can be transitioned to `training` (see `GaitAuth` documentation),
    /// an error will be presented.
    func trainModel()

    /// Adds features from the training buffer to the active model.
    ///
    /// If the model is not initialized or there are insufficient features
    /// in the training buffer, an error will be presented.
    func addCollectedFeatures()
}
