//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

protocol ModelTrainer: class {
    var featureCollectionCount: Int { get }
    var isCollectingFeatures: Bool { get set }
    func trainModel()
    func addCollectedFeatures(completion: ((Error) -> Void)?)
}

extension ModelTrainer {
    func addCollectedFeatures() {
        self.addCollectedFeatures(completion: nil)
    }
}
