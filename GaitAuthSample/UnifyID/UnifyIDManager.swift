//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import UnifyID
import GaitAuth

class UnifyIDManager {
    weak internal var interactor: Interactor?
    internal var core: UnifyID?
    internal var gaitAuth: GaitAuth? { core?.gaitAuth }
    internal var model: GaitModel?
    internal var modelID: String?
    internal var featureBuffer = FeatureBuffer()

    /// Must be modified on the main thread.
    internal var isCollectingFeatures = false {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            updateSimulatedCollection()
            NotificationCenter.default.post(
                CollectionStateDidChangeNotification(sender: self, isCollecting: isCollectingFeatures)
            )
        }
    }

    /// Reset the application state.
    func reset() {
        dispatchPrecondition(condition: .onQueue(.main))
        isCollectingFeatures = false
        featureCollectionCount = 0
        featureBuffer.removeAll()
        NotificationCenter.default.post(DidResetModelNotification(sender: self))
    }

    var featureCollectionCount: Int = 0 {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            NotificationCenter.default.post(
                CollectionStateDidChangeNotification(sender: self, isCollecting: isCollectingFeatures)
            )
        }
    }

    // MARK: Simulate Model Refreshing

    internal var refreshCount: Int = 0 {
        didSet {
            guard refreshCount >= 3 else { return }
            interactor?.presentTerminalError(message: "Model training failed:\nInsufficient features")
            refreshCount = 0
        }
    }

    // MARK: Simulate Collection

    private var collector: FakeFeatureGenerator?

    private func updateSimulatedCollection() {
        collector = !isCollectingFeatures ? nil : FakeFeatureGenerator { features in
            self.featureBuffer.write(features)
            DispatchQueue.main.async {
                self.featureCollectionCount += features.count
            }
        }
    }
}
