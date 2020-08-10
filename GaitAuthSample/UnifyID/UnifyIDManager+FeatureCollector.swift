//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

extension UnifyIDManager: FeatureCollector {
    private static let minFeaturesToAdd = 10

    func trainModel(withConfirmation: Bool) {
        dispatchPrecondition(condition: .onQueue(.main))
        isCollectingFeatures = false
        featureCollectionCount = 0
        interactor?.presentTraining(confirm: withConfirmation)
    }

    func addCollectedFeatures(completion: ((Error) -> Void)? = nil) {
        guard featureCollectionCount >= Self.minFeaturesToAdd else {
            interactor?.presentErrorAlert(
                title: "More features required",
                message: "Please collect at least 10 features before adding.",
                completion: nil)
            return
        }

        self.featureCollectionCount = 0

        featureBuffer.flush { items, completion in
            print("added \(items.count) collected features")

            completion(true)

            self.featureBuffer.getCount { _ in
                DispatchQueue.main.async {
                    self.featureCollectionCount = 0
                }
            }
        }
    }

    func scoreCollectedFeatures(withConfirmation: Bool) {
        featureBuffer.flush { items, completion in
            print("scoring \(items.count) collected features")

            completion(true)
            self.featureBuffer.getCount { _ in
                DispatchQueue.main.async {
                    self.featureCollectionCount = 0

                    let scores = items.map { (date: $0.date, score: Double.random(in: -1.0...1.0)) }
                    self.interactor?.presentScores(scores)
                }
            }
        }
    }
}
