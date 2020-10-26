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

        guard let model = self.model else {
            interactor?.presentErrorAlert(
                title: "Train Model Failed",
                message: "Model is not initialized",
                completion: nil
            )
            return
        }

        interactor?.presentConfirmation(
            title: "Train Model",
            message: "Are you sure you would like to begin training your model? This action cannot be reversed.",
            cancelTitle: "Cancel",
            actionTitle: "Confirm"
        ) { [weak self] confirmed in
            dispatchPrecondition(condition: .onQueue(.main))
            guard let self = self, confirmed else { return }

            model.train { [weak self] error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let error = error {
                        self.interactor?.presentErrorAlert(
                            title: "Train Model Failed",
                            message: error.localizedDescription,
                            completion: nil
                        )
                        return
                    }
                    self.interactor?.presentPending()
                }
            }
        }
    }

    func addCollectedFeatures(completion: ((Error) -> Void)? = nil) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard featureCollectionCount >= Self.minFeaturesToAdd else {
            interactor?.presentErrorAlert(
                title: "More features required",
                message: "Please collect at least \(Self.minFeaturesToAdd) features before adding.",
                completion: nil)
            return
        }

        self.featureCollectionCount = 0

        featureBuffer.flush { [weak self] items, flushComplete in
            print("added \(items.count) collected features")

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.model?.add(items) {
                    if let error = $0 {
                        completion?(error)
                        flushComplete(false)
                        return
                    }
                    flushComplete(true)
                    self.featureBuffer.getCount { _ in
                        DispatchQueue.main.async {
                            self.featureCollectionCount = 0
                        }
                    }
                }
            }
        }
    }

    func scoreCollectedFeatures(withConfirmation: Bool) {
        guard let model = self.model else {
            interactor?.presentErrorAlert(
                title: "Feature Scoring Failed",
                message: "Model is not initialized",
                completion: nil
            )
            return
        }

        featureBuffer.flush { items, completion in
            print("scoring \(items.count) collected features")

            model.score(items) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.interactor?.presentErrorAlert(
                        title: "Feature Scoring Failed",
                        message: error.localizedDescription,
                        completion: nil
                    )
                    completion(false)
                    return
                case .success(let scores):
                    completion(true)
                    self.featureBuffer.getCount { _ in
                        DispatchQueue.main.async {
                            self.featureCollectionCount = 0
                            self.interactor?.presentScores(scores.map { (date: $0.date, score: $0.value) })
                        }
                    }
                }
            }
        }
    }
}
